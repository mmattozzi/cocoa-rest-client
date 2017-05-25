//
//  CocoaRestClientAppDelegate.m
//  CocoaRestClient
//
//  Created by mmattozzi on 1/5/10.
//

#import "CocoaRestClientAppDelegate.h"
#import "CRCMultipartRequest.h"
#import "CRCFormEncodedRequest.h"
#import "CRCRawRequest.h"
#import "CRCFileRequest.h"
#import "CRCRequest.h"
#import <Foundation/Foundation.h>
#import <SBJson4.h>
#import <Sparkle/SUUpdater.h>
#import "MsgPackSerialization.h"
#import "MF_Base64Additions.h"
#import "TableRowAndColumn.h"
#import "CRCSavedRequestFolder.h"
#import "ContentTypes.h"
#import "MainWindowController.h"
#import "SavedRequestsDataSource.h"
#import "SaveRequestPanelController.h"

#define MAIN_WINDOW_MENU_TAG 150
#define REGET_MENU_TAG 151


@interface CocoaRestClientAppDelegate(Private)
- (void)loadSavedDictionary:(NSDictionary *)request;
- (void)loadSavedCRCRequest:(CRCRequest *)request;

@end

@implementation CocoaRestClientAppDelegate

@synthesize mainWindowControllers;
@synthesize preemptiveBasicAuth;
@synthesize preferencesController;
@synthesize syntaxHighlightingMenuItem;
@synthesize reGetResponseMenuItem;
@synthesize themeMenuItem;
@synthesize jsonWriter;
@synthesize showLineNumbersMenuItem;
@synthesize fastSearchSavedRequestsController;
@synthesize allowSelfSignedCerts;
@synthesize aceViewFontSize;

- (id) init {
	self = [super init];
    
    self.mainWindowControllers = [[NSMutableArray alloc] init];
	
    NSDictionary *defaults = [[NSMutableDictionary alloc] init];
    [defaults setValue:[NSNumber numberWithInt:30] forKey:RESPONSE_TIMEOUT];
    [defaults setValue:[NSNumber numberWithBool:YES] forKey:FOLLOW_REDIRECTS];
    [defaults setValue:[NSNumber numberWithBool:YES] forKey:SYNTAX_HIGHLIGHT];
    [defaults setValue:[NSNumber numberWithInteger:ACEThemeChrome] forKey:THEME];
    [defaults setValue:[NSNumber numberWithBool:YES] forKey:SHOW_LINE_NUMBERS];
    [defaults setValue:[NSNumber numberWithBool:YES] forKey:DISABLE_COOKIES];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
	allowSelfSignedCerts = YES;
    preemptiveBasicAuth = NO;
    
    self.savedRequestsDataSource = [[SavedRequestsDataSource alloc] init];
    [self.savedRequestsDataSource loadDataFromDisk];
    
    
    // Register a key listener
    NSEvent * (^monitorHandler)(NSEvent *);
    monitorHandler = ^NSEvent * (NSEvent * theEvent) {
        
        if (([theEvent modifierFlags] & NSCommandKeyMask) && [[theEvent characters] isEqualToString:@"l"]) {
            [currentWindowController.urlBox selectText:nil];
            return nil;
        } else {
            return theEvent;
        }
    };
    
    eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:monitorHandler];
    lastSelectedSavedOutlineViewItem = nil;
    
	return self;
}

- (void) addTabFromWindow:(NSWindow *)window {
    MainWindowController *mainWindowController = [[MainWindowController alloc] initWithWindowNibName:@"MainWindow"];
    mainWindowController.appDelegate = self;
    mainWindowController.savedRequestsDataSource = self.savedRequestsDataSource;
    if (window) {
        [window addTabbedWindow:[mainWindowController window] ordered:NSWindowAbove];
        [mainWindowController.window orderFront:window];
        [mainWindowController.window makeKeyWindow];
    } else {
        [mainWindowController showWindow:self];
    }
    [self.mainWindowControllers addObject:mainWindowController];
    NSLog(@"Managing %lu window controllers", (unsigned long)[self.mainWindowControllers count]);
}

- (void) tabWasRemoved:(NSWindowController *)windowController {
    [self.mainWindowControllers removeObject:windowController];
    NSLog(@"Managing %lu window controllers", (unsigned long)[self.mainWindowControllers count]);
}

- (IBAction) newTab:(id)sender {
    if (currentWindowController) {
        [self addTabFromWindow:[currentWindowController window]];
    }
}

- (void) setCurrentMainWindowController:(MainWindowController *)mainWindowController {
    currentWindowController = mainWindowController;
}

+ (void) addBorderToView:(NSView *)view {
    CGColorRef borderColor = (CGColorRef) CGColorCreateGenericRGB(0.745f, 0.745f, 0.745f, 1.0f);
    CALayer *layer = [CALayer layer];
    layer.borderColor = borderColor;
    [view setWantsLayer:YES];
    view.layer = layer;
    view.layer.borderWidth = 1.0f;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // [window setFrameUsingName:@"CRCMainWindow"];
    // [[window windowController] setShouldCascadeWindows:NO];
    // [window setFrameAutosaveName:@"CRCMainWindow"];
    
    
    
    // Sync default params from defaults.plist
    [[NSUserDefaults standardUserDefaults]registerDefaults:[NSDictionary dictionaryWithContentsOfFile:@"defaults.plist"]];
    
    
    
    
    
	self.requestMethodsWithoutBody = [NSSet setWithObjects:@"GET", @"HEAD", @"OPTIONS", nil];
	
	
    
    // TODO
    
    exportRequestsController = [[ExportRequestsController alloc] initWithWindowNibName:@"ExportRequests"];
    exportRequestsController.savedRequestsArray = SavedRequestsDataSource.savedRequestsArray;
    
    self.fastSearchSavedRequestsController = [[FastSearchSavedRequestsController alloc] initWithWindowNibName:@"FastSearchSavedRequests"];
    
    // TODO
    // drawerView.cocoaRestClientAppDelegate = self;
    // [drawerView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    
    
    [reGetResponseMenuItem setEnabled:NO];
    
    
    //[self syntaxHighlightingPreferenceChanged];
    
    
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deleteSavedRequest:)
                                                 name:@"deleteDrawerRow"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deselectSavedRequest:)
                                                 name:@"deselectSavedRequest"
                                               object:nil];
    
    [self addTabFromWindow:nil];
    
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    return !(flag || ([currentWindowController.window makeKeyAndOrderFront: self], 0));
}


- (void)syntaxHighlightingPreferenceChanged {
    BOOL syntaxHighlighting = [[NSUserDefaults standardUserDefaults] boolForKey:SYNTAX_HIGHLIGHT];
    syntaxHighlightingMenuItem.state = syntaxHighlighting;
}





#pragma mark -
#pragma mark Highlighted Text Views


- (void) showLineNumbersToggled:(id)sender {
    NSInteger state = [((NSMenuItem *) sender) state];
    if (state == NSOnState) {
        [currentWindowController applyShowLineNumbers:NO];
        [((NSMenuItem *) sender) setState:NO];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SHOW_LINE_NUMBERS];
    } else if (state == NSOffState) {
        [currentWindowController applyShowLineNumbers:YES];
        [((NSMenuItem *) sender) setState:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SHOW_LINE_NUMBERS];
    }
}

#pragma mark -
#pragma mark Find Menu items

-(IBAction) findMenuItem:(id)sender {
    NSResponder *responder = [currentWindowController.window firstResponder];
    // Assume that in most cases the user wants to search in the response, unless they explicitly
    // have their focus on the request.
    if ([currentWindowController.requestView ancestorSharedWithView:(NSView *)responder] == currentWindowController.requestView) {
        [currentWindowController.requestView showFindInterface];
    } else {
        [currentWindowController.responseView showFindInterface];
    }
}

- (IBAction) findNextMenuItem:(id)sender {
    NSResponder *responder = [currentWindowController.window firstResponder];
    // Assume that in most cases the user wants to search in the response, unless they explicitly
    // have their focus on the request.
    if ([currentWindowController.requestView ancestorSharedWithView:(NSView *)responder] == currentWindowController.requestView) {
        [currentWindowController.requestView findNextMatch];
    } else {
        [currentWindowController.responseView findNextMatch];
    }
}

- (IBAction) findPreviousMenuItem:(id)sender {
    NSResponder *responder = [currentWindowController.window firstResponder];
    // Assume that in most cases the user wants to search in the response, unless they explicitly
    // have their focus on the request.
    if ([currentWindowController.requestView ancestorSharedWithView:(NSView *)responder] == currentWindowController.requestView) {
        [currentWindowController.requestView findPreviousMatch];
    } else {
        [currentWindowController.responseView findPreviousMatch];
    }
}

- (IBAction) replaceMenuItem:(id)sender {
    NSResponder *responder = [currentWindowController.window firstResponder];
    // Replace only makes sense for the requestView
    if ([currentWindowController.requestView ancestorSharedWithView:(NSView *)responder] == currentWindowController.requestView) {
        [currentWindowController.requestView showReplaceInterface];
    }
}



#pragma mark Menu methods
- (IBAction) contentTypeMenuItemSelected:(id)sender {
    [currentWindowController contentTypeMenuItemSelected:sender];
}

- (IBAction) themeMenuItemSelected:(id)sender {
    [currentWindowController.responseView setTheme:[sender tag]];
    [currentWindowController.requestView setTheme:[sender tag]];
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:[sender tag]] forKey:THEME];
    
    // Unselect all theme MenuItems
    NSMenuItem *themeMenu = [((NSMenuItem *) sender) parentItem];
    NSArray *allThemeMenuItems = [themeMenu.submenu itemArray];
    for (id menuItem in allThemeMenuItems) {
        [((NSMenuItem *)menuItem) setState:NSOffState];
    }
    
    // Enable the relevant theme MenuItem
    [((NSMenuItem *) sender) setState:NSOnState];
}

// TODO
- (IBAction) allowSelfSignedCerts:(id)sender {
    NSMenuItem* menuItemSender = (NSMenuItem *) sender;
    if ([menuItemSender state] == NSOnState) {
        allowSelfSignedCerts = NO;
        [menuItemSender setState:NSOffState];
    } else {
        allowSelfSignedCerts = YES;
        [menuItemSender setState:NSOnState];
    }
}






// Save an HTTP request into the request drawer
// This is the Save As menu option because the user will always have a chance to name the request.
- (IBAction) saveRequest:(id) sender {
    lastSelectedSavedOutlineViewItem = [currentWindowController.savedOutlineView itemAtRow:[currentWindowController.savedOutlineView selectedRow]];
    [currentWindowController.savedOutlineView deselectAll:nil];
	[currentWindowController.window beginSheet:currentWindowController.saveRequestSheet completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSModalResponseOK) {
            SaveRequestPanelController *panelController = (SaveRequestPanelController *) [currentWindowController.saveRequestSheet delegate];
            CRCRequest * request = [CRCRequest requestWithWindow:currentWindowController
                                                           named:[panelController.saveRequestTextField stringValue]];
            
            if ([lastSelectedSavedOutlineViewItem isKindOfClass:[CRCSavedRequestFolder class]]) {
                [lastSelectedSavedOutlineViewItem addObject:request];
            } else {
                [SavedRequestsDataSource.savedRequestsArray addObject:request];
            }
            [self redrawRequestViews];
            [self.savedRequestsDataSource saveDataToDisk];
        }
    }];
}

- (IBAction) openFastSearchSavedRequestsPanel:(id)sender {
    fastSearchSavedRequestsController.parent = [currentWindowController window];
    [currentWindowController.savedOutlineView deselectAll:nil];
    [fastSearchSavedRequestsController setupWindow:SavedRequestsDataSource.savedRequestsArray];
    [currentWindowController.window beginSheet:[fastSearchSavedRequestsController window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSModalResponseOK) {
            if (fastSearchSavedRequestsController.selectedRequest) {
                [currentWindowController loadSavedRequest:fastSearchSavedRequestsController.selectedRequest];
            }
        }
    }];
}

//
// Find the name attribute of the given request, assuming the input object is a request.
// On unknown input type, return "Unnamed". 
//
+ (NSString *) nameForRequest:(id)object {
    // Handle current request model
    if ([object isKindOfClass:[CRCRequest class]])
    {
        CRCRequest *crcRequest = (CRCRequest *) object;
        return crcRequest.name;
    }
    // Handle older version of requests
    else if([object isKindOfClass:[NSDictionary class]] )
    {
        return [object objectForKey:@"name"];
    }
    return @"Unnamed";
}

//
// Save menu option
// Overwrite the selected request with the settings currently in the Application window, using the 
// same name as the selected request. Presents a confirmation. If no request is selected or if a
// folder is selected, default to Save As behavior.
//
- (IBAction) overwriteRequest:(id)sender {
    int row = [currentWindowController.savedOutlineView selectedRow];
    if (row > -1) {
        CRCRequest * request = [CRCRequest requestWithWindow:currentWindowController named:nil];
        
        id selectedSavedOutlineViewItem = [currentWindowController.savedOutlineView itemAtRow:[currentWindowController.savedOutlineView selectedRow]];
        if ([selectedSavedOutlineViewItem isKindOfClass:[CRCSavedRequestFolder class]]) {
            return [self saveRequest:sender];
        } else {
            NSString *nameOfRequest = [selectedSavedOutlineViewItem name];
            
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"Cancel"];
            [alert addButtonWithTitle:@"Replace"];
            [alert setMessageText:@"Overwrite request?"];
            [alert setInformativeText:[NSString stringWithFormat:@"Would you like to overwrite the request '%@'?", nameOfRequest]];
            [alert setAlertStyle:NSWarningAlertStyle];
            
            if ([alert runModal] == NSAlertSecondButtonReturn) {
                [((CRCRequest *) selectedSavedOutlineViewItem) overwriteContentsWith:request];
                [currentWindowController.savedOutlineView reloadItem:nil reloadChildren:YES];
                [self.savedRequestsDataSource saveDataToDisk];
            }
        }
    } else {
        return [self saveRequest:sender];
    }
}

- (IBAction) openTimeoutDialog:(id) sender {
	[currentWindowController.timeoutField setIntValue:[[NSUserDefaults standardUserDefaults] integerForKey:RESPONSE_TIMEOUT]];
	[currentWindowController.window beginSheet:currentWindowController.timeoutSheet completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSModalResponseOK) {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:[currentWindowController.timeoutField intValue]] forKey:RESPONSE_TIMEOUT];
        }
    }];
}

- (IBAction) reloadRequestsDrawer:(id)sender {
    [self.savedRequestsDataSource loadDataFromDisk];
    [self redrawRequestViews];
}

- (void) importRequestsFromArray:(NSArray *)requests {
    exportRequestsController.parent = currentWindowController.window;
    [exportRequestsController prepareToDisplayImports:requests];
    [currentWindowController.window beginSheet:[exportRequestsController window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSModalResponseOK) {
            NSLog(@"Import request sheet ended with OK");
            [self redrawRequestViews];
        }
    }];
}

- (void) invalidFileAlert {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Invalid file"];
    [alert setInformativeText:@"Unable to read stored requests from file."];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:currentWindowController.window completionHandler:nil];
}

- (IBAction) importRequests:(id)sender {
    NSOpenPanel* picker = [NSOpenPanel openPanel];
	
	[picker setCanChooseFiles:YES];
	[picker setCanChooseDirectories:NO];
	[picker setAllowsMultipleSelection:NO];
    
    NSMutableArray *loadedRequests = [[NSMutableArray alloc] init];
    [picker beginSheetModalForWindow:currentWindowController.window completionHandler:^(NSInteger result) {
       if (result == NSFileHandlingPanelOKButton) {
           @try {
               for(NSURL* url in [picker URLs]) {
                   NSString *path = [url path];
                   NSLog(@"Loading requests from %@", path);
                   [loadedRequests addObjectsFromArray:[NSKeyedUnarchiver unarchiveObjectWithFile:path]];
                   
                   if ([loadedRequests count] > 0) {
                       [self importRequestsFromArray:loadedRequests];
                   } else {
                       [self invalidFileAlert];
                   }
               }
           }
           @catch (NSException *exception) {
               [self invalidFileAlert];
           }
       }
   }];
}

- (IBAction) exportRequests:(id)sender {
    exportRequestsController.parent = currentWindowController.window;
    [exportRequestsController prepareToDisplayExports];
    [currentWindowController.window beginSheet:[exportRequestsController window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSModalResponseOK) {
            NSLog(@"Export request sheet ended with OK");
        }
    }];
}

- (IBAction) handleOpenWindow:(id)sender {
	[currentWindowController.window makeKeyAndOrderFront:self];
}

- (IBAction) handleCloseWindow:(id)sender {
    [currentWindowController.window close];
}

// Including this to disable Open Window menu item when window is already open
- (BOOL)validateMenuItem:(NSMenuItem *)item
{
	//check to see if the Main Menu NSMenuItem is
	//being validcated
	if([item tag] == MAIN_WINDOW_MENU_TAG) {
		return ![currentWindowController.window isVisible];
	} else if ([item tag] == REGET_MENU_TAG) {
        return (currentWindowController.lastRequest != nil && [currentWindowController.lastRequest.method isEqualToString:@"GET"]);
    }
	
	return TRUE;
}

- (void) applicationWillTerminate: (NSNotification *)note {
	[self.savedRequestsDataSource saveDataToDisk];
    [NSEvent removeMonitor:eventMonitor];
}

- (IBAction) helpInfo:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://mmattozzi.github.io/cocoa-rest-client/"]]; 
}

- (IBAction) licenseInfo:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/mmattozzi/cocoa-rest-client/master/LICENSE.txt"]];
}

- (IBAction) reloadLastRequest:(id)sender {
	if (currentWindowController.lastRequest != nil) {
		[currentWindowController loadSavedCRCRequest:(CRCRequest *)currentWindowController.lastRequest];
		[currentWindowController runSubmit: self];
	}
}

/*
- (void)deleteTableRow:(NSNotification *)notification {
    BOOL rawRequestBody = [[NSUserDefaults standardUserDefaults]boolForKey:RAW_REQUEST_BODY];
    
    NSString *currentTabLabel = [[notification userInfo] valueForKey:@"identifier"];
    if ([currentTabLabel isEqualToString:@"RequestHeaders"] && [headersTableView selectedRow] > -1) {
        [self minusHeaderRow:nil];
    } else if ([currentTabLabel isEqualToString:@"RequestBody"] && [paramsTableView selectedRow] > -1 && ! rawRequestBody) {
        [self minusParamsRow:nil];
    } else if ([currentTabLabel isEqualToString:@"Files"] && [filesTableView selectedRow] > -1) {
        [self minusFileRow:nil];
    }
}
 */

- (IBAction) showPreferences:(id)sender {
    NSLog(@"Check for updates: %d", [[SUUpdater sharedUpdater] automaticallyChecksForUpdates]);
    NSLog(@"Downloads updates: %d", [[SUUpdater sharedUpdater] automaticallyDownloadsUpdates]);
    NSLog(@"Update check freq: %f", [[SUUpdater sharedUpdater] updateCheckInterval]);
    
    if(!self.preferencesController)
        self.preferencesController = [[PreferencesController alloc] initWithWindowNibName:@"Preferences"];
    
    [self.preferencesController showWindow:self];
}

- (IBAction)zoomIn:(id)sender {
    aceViewFontSize += 2;
    [currentWindowController.responseView setFontSize:aceViewFontSize];
    [currentWindowController.requestView setFontSize:aceViewFontSize];
}

- (IBAction)zoomOut:(id)sender{
    aceViewFontSize -= 2;
    [currentWindowController.responseView setFontSize:aceViewFontSize];
    [currentWindowController.requestView setFontSize:aceViewFontSize];
}

- (IBAction) zoomDefault:(id)sender {
    [currentWindowController.responseView setFontSize:DEFAULT_FONT_SIZE];
    [currentWindowController.requestView setFontSize:DEFAULT_FONT_SIZE];
}

- (IBAction) exportResponse:(id)sender {
    NSSavePanel* picker = [NSSavePanel savePanel];
	
    if ( [picker runModal] == NSOKButton ) {
		NSURL* path = [picker URL];
        NSLog(@"Saving requests to %@", path.absoluteString);
        
        NSError *error;
        BOOL savedOK = [[currentWindowController getResponseText] writeToFile:path.absoluteString atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        if (! savedOK) {
            NSLog(@"Error writing file at %@\n%@", path.absoluteString, [error localizedFailureReason]);
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Unable to save response"];
            [alert setInformativeText:[error localizedFailureReason]];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
        }
    }
}

- (NSString *) saveResponseToTempFile {
    NSString *tempDir = NSTemporaryDirectory();
    
    static int sequenceNumber = 0;
    NSString *path;
    do {
        sequenceNumber++;
        path = [NSString stringWithFormat:@"%d-%d-%d.txt", [[NSProcessInfo processInfo] processIdentifier],
                (int)[NSDate timeIntervalSinceReferenceDate], sequenceNumber];
        path = [tempDir stringByAppendingPathComponent:path];
    } while ([[NSFileManager defaultManager] fileExistsAtPath:path]);
    
    NSLog(@"Saving to %@", path);
    NSError *error;
    BOOL savedOK = [[currentWindowController getResponseText] writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (! savedOK) {
        NSLog(@"Error writing file at %@\n%@", path, [error localizedFailureReason]);
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Unable to save response as temp file"];
        [alert setInformativeText:[error localizedFailureReason]];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        return nil;
    } else {
        return path;
    }
}

- (IBAction) viewResponseInBrowser:(id)sender {
    NSString *path = [self saveResponseToTempFile];
    if (path) {
        NSURL *defaultBrowserURL =
        [[NSWorkspace sharedWorkspace]URLForApplicationToOpenURL:[NSURL URLWithString:@"http://google.com"]];
        [[NSWorkspace sharedWorkspace]openFile:path.stringByStandardizingPath
                               withApplication:defaultBrowserURL.absoluteString.lastPathComponent.stringByRemovingPercentEncoding];
    }
}

- (IBAction) reGetResponseInBrowser:(id)sender {
    if (currentWindowController.lastRequest != nil && [currentWindowController.lastRequest.method isEqualToString:@"GET"]) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:currentWindowController.lastRequest.url]];
    }
}

- (IBAction) viewResponseInDefaultApplication:(id)sender {
    NSString *path = [self saveResponseToTempFile];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@", path]]];
}

- (IBAction) copyCurlCommand:(id)sender {
    CRCRequest * request = [CRCRequest requestWithWindow:currentWindowController named:nil];
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
    NSString *curlCommand = [request generateCurlCommand:[[NSUserDefaults standardUserDefaults] boolForKey:FOLLOW_REDIRECTS]];
    NSLog(@"Generated curl command: %@", curlCommand);
    [pasteBoard setString:curlCommand forType:NSStringPboardType];
}

- (void) redrawRequestViews {
    for (id mainWindowController in mainWindowControllers) {
        [((MainWindowController *)mainWindowController).savedOutlineView reloadItem:nil reloadChildren:YES];
    }
}

- (void) deleteSavedRequest: (NSNotification *) notification {
    [currentWindowController deleteSavedRequestFromButton:nil];
}

- (void) deselectSavedRequest:(NSNotification *)notification {
    [currentWindowController.savedOutlineView deselectAll:nil];
}

@end
