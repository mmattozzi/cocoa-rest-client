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

@implementation CocoaRestClientAppDelegate

@synthesize mainWindowControllers;
@synthesize syntaxHighlightingMenuItem;
@synthesize reGetResponseMenuItem;
@synthesize themeMenuItem;
@synthesize showLineNumbersMenuItem;
@synthesize aceViewFontSize;
@synthesize showSavedRequestsMenuItem;

#pragma mark -
#pragma mark Window Management

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
    [defaults setValue:[NSNumber numberWithBool:YES] forKey:ALLOW_SELF_SIGNED_CERTS];
    [defaults setValue:@"application/x-www-form-urlencoded" forKey:DEFAULT_CONTENT_TYPE];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    self.savedRequestsDataSource = [[SavedRequestsDataSource alloc] init];
    [self.savedRequestsDataSource loadDataFromDisk];
    
    // Register a key listener: Command-L highlights contents of URL box in current window
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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // Sync default params from defaults.plist
    [[NSUserDefaults standardUserDefaults]registerDefaults:[NSDictionary dictionaryWithContentsOfFile:@"defaults.plist"]];
    
    // Used by all windows of application
    self.requestMethodsWithoutBody = [NSSet setWithObjects:@"GET", @"HEAD", @"OPTIONS", nil];
    
    exportRequestsController = [[ExportRequestsController alloc] initWithWindowNibName:@"ExportRequests"];
    exportRequestsController.savedRequestsArray = SavedRequestsDataSource.savedRequestsArray;
    fastSearchSavedRequestsController = [[FastSearchSavedRequestsController alloc] initWithWindowNibName:@"FastSearchSavedRequests"];
    diffWindowController = [[DiffWindowController alloc] initWithWindowNibName:@"DiffWindow"];
    
    [reGetResponseMenuItem setEnabled:NO];
    
    [showLineNumbersMenuItem setState:[[NSUserDefaults standardUserDefaults] boolForKey:SHOW_LINE_NUMBERS]];
    [syntaxHighlightingMenuItem setState:[[NSUserDefaults standardUserDefaults] boolForKey:SYNTAX_HIGHLIGHT]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deleteSavedRequest:)
                                                 name:@"deleteDrawerRow"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deselectSavedRequest:)
                                                 name:@"deselectSavedRequest"
                                               object:nil];

    windowNumber = 0;
    [self addTabFromWindow:nil];
}

- (void) addTabFromWindow:(NSWindow *)window {
    MainWindowController *mainWindowController = [[MainWindowController alloc] initWithWindowNibName:@"MainWindow"];
    mainWindowController.appDelegate = self;
    mainWindowController.savedRequestsDataSource = self.savedRequestsDataSource;
    mainWindowController.window.title = @"CocoaRestClient";
    if (window) {
        [window addTabbedWindow:[mainWindowController window] ordered:NSWindowAbove];
        [mainWindowController.window orderFront:window];
        [mainWindowController.window makeKeyWindow];
    } else {
        if (windowNumber == 0) {
            [mainWindowController.window setFrameUsingName:@"CRCMainWindow"];
            [[mainWindowController.window windowController] setShouldCascadeWindows:NO];
            [mainWindowController.window setFrameAutosaveName:@"CRCMainWindow"];
        } else {
            CGPoint currentOrigin = [currentWindowController.window frame].origin;
            currentOrigin.x += 20;
            currentOrigin.y -= 20;
            [mainWindowController.window setFrameOrigin:currentOrigin];
        }
        windowNumber++;
        
        [mainWindowController showWindow:self];
    }
    [self.mainWindowControllers addObject:mainWindowController];
    NSLog(@"Managing %lu window controllers", (unsigned long)[self.mainWindowControllers count]);
}

- (void) tabWasRemoved:(NSWindowController *)windowController {
    [self.mainWindowControllers removeObject:windowController];
    NSLog(@"Managing %lu window controllers", (unsigned long)[self.mainWindowControllers count]);
}

- (void) setCurrentMainWindowController:(MainWindowController *)mainWindowController {
    currentWindowController = mainWindowController;
    if ([currentWindowController.savedRequestsOuterView isHidden]) {
        [self.showSavedRequestsMenuItem setTitle:SHOW_SAVED_REQUESTS_MENU_TITLE];
    }
    else {
        [self.showSavedRequestsMenuItem setTitle:HIDE_SAVED_REQUESTS_MENU_TITLE];
    }
}

- (void) applicationWillTerminate: (NSNotification *)note {
    [self.savedRequestsDataSource saveDataToDisk];
    [NSEvent removeMonitor:eventMonitor];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    return !(flag || ([currentWindowController.window makeKeyAndOrderFront: self], 0));
}

#pragma mark -
#pragma mark Saved Requests Management

- (void) redrawRequestViews {
    for (id mainWindowController in mainWindowControllers) {
        [((MainWindowController *)mainWindowController).savedOutlineView reloadItem:nil reloadChildren:YES];
    }
}

- (void) deselectSavedRequest:(NSNotification *)notification {
    [currentWindowController.savedOutlineView deselectAll:nil];
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

- (void) deleteSavedRequest: (NSNotification *) notification {
    [currentWindowController deleteSavedRequestFromButton:nil];
}

#pragma mark -
#pragma mark Utility Methods

- (void) invalidFileAlert {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Invalid file"];
    [alert setInformativeText:@"Unable to read stored requests from file."];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert beginSheetModalForWindow:currentWindowController.window completionHandler:nil];
}

- (IBAction) restartRequiredAlert:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Restart Required"];
    if ([[sender identifier] isEqualToString:@"allowSelfSignedCerts"]) {
        [alert setInformativeText:@"Restart the app for changes to take effect for hosts that have already been visted."];
    }
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert beginSheetModalForWindow:currentWindowController.window completionHandler:nil];
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
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert runModal];
        return nil;
    } else {
        return path;
    }
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

+ (void) addBorderToView:(NSView *)view {
    CGColorRef borderColor = (CGColorRef) CGColorCreateGenericRGB(0.745f, 0.745f, 0.745f, 1.0f);
    CALayer *layer = [CALayer layer];
    layer.borderColor = borderColor;
    [view setWantsLayer:YES];
    view.layer = layer;
    view.layer.borderWidth = 1.0f;
}

#pragma mark -
#pragma mark Application Menu

- (IBAction) showPreferences:(id)sender {
    NSLog(@"Check for updates: %d", [[SUUpdater sharedUpdater] automaticallyChecksForUpdates]);
    NSLog(@"Downloads updates: %d", [[SUUpdater sharedUpdater] automaticallyDownloadsUpdates]);
    NSLog(@"Update check freq: %f", [[SUUpdater sharedUpdater] updateCheckInterval]);
    
    if(! preferencesController)
        preferencesController = [[PreferencesController alloc] initWithWindowNibName:@"Preferences"];
    
    [preferencesController showWindow:self];
}

#pragma mark -
#pragma mark File Menu

- (IBAction) handleOpenWindow:(id)sender {
    if (currentWindowController.window.screen) {
        [self addTabFromWindow:nil];
    } else {
        [currentWindowController.window makeKeyAndOrderFront:self];
    }
}

- (IBAction) handleCloseWindow:(id)sender {
    [currentWindowController.window close];
}

- (IBAction) newTab:(id)sender {
    if (currentWindowController) {
        [self addTabFromWindow:[currentWindowController window]];
    }
}

- (IBAction) submitRequest:(id)sender {
    [currentWindowController runSubmit:sender];
}

- (IBAction) reloadLastRequest:(id)sender {
    if (currentWindowController.lastRequest != nil) {
        [currentWindowController loadSavedCRCRequest:(CRCRequest *)currentWindowController.lastRequest];
        [currentWindowController runSubmit: self];
    }
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
            [alert setAlertStyle:NSAlertStyleWarning];
            
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

- (IBAction) deleteSavedRequestFromMenu:(id) sender {
    [self deleteSavedRequest:nil];
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

- (IBAction) reloadRequestsDrawer:(id)sender {
    [self.savedRequestsDataSource loadDataFromDisk];
    exportRequestsController.savedRequestsArray = SavedRequestsDataSource.savedRequestsArray;
    [self redrawRequestViews];
}

- (IBAction) exportResponse:(id)sender {
    NSSavePanel* picker = [NSSavePanel savePanel];
    
    if ( [picker runModal] == NSModalResponseOK ) {
        NSString* path = [[picker URL] path];
        NSLog(@"Saving requests to %@", path);
        
        NSError *error;
        BOOL savedOK = [[currentWindowController getResponseText] writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        if (! savedOK) {
            NSLog(@"Error writing file at %@\n%@", path, [error localizedFailureReason]);
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Unable to save response"];
            [alert setInformativeText:[error localizedFailureReason]];
            [alert setAlertStyle:NSAlertStyleWarning];
            [alert runModal];
        }
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

- (IBAction) viewResponseInDefaultApplication:(id)sender {
    NSString *path = [self saveResponseToTempFile];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@", path]]];
}

- (IBAction) reGetResponseInBrowser:(id)sender {
    if (currentWindowController.lastRequest != nil && [currentWindowController.lastRequest.method isEqualToString:@"GET"]) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:currentWindowController.lastRequest.url]];
    }
}

#pragma mark -
#pragma mark Edit Menu

- (IBAction) copyCurlCommand:(id)sender {
    CRCRequest * request = [CRCRequest requestWithWindow:currentWindowController named:nil];
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
    NSString *curlCommand = [request generateCurlCommand:[[NSUserDefaults standardUserDefaults] boolForKey:FOLLOW_REDIRECTS]];
    NSLog(@"Generated curl command: %@", curlCommand);
    [pasteBoard setString:curlCommand forType:NSStringPboardType];
}

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

- (IBAction) replaceMenuItem:(id)sender {
    NSResponder *responder = [currentWindowController.window firstResponder];
    // Replace only makes sense for the requestView
    if ([currentWindowController.requestView ancestorSharedWithView:(NSView *)responder] == currentWindowController.requestView) {
        [currentWindowController.requestView showReplaceInterface];
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

#pragma mark -
#pragma mark Options Menu

- (IBAction) openTimeoutDialog:(id) sender {
    [currentWindowController.timeoutField setIntValue:[[NSUserDefaults standardUserDefaults] integerForKey:RESPONSE_TIMEOUT]];
    [currentWindowController.window beginSheet:currentWindowController.timeoutSheet completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSModalResponseOK) {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:[currentWindowController.timeoutField intValue]] forKey:RESPONSE_TIMEOUT];
        }
    }];
}

#pragma mark -
#pragma mark View Menu

- (IBAction) toggleVerticalSplitView:(id)sender {
    if ([currentWindowController.savedRequestsOuterView isHidden]) {
        [currentWindowController.savedRequestsOuterView setHidden:NO];
        [currentWindowController.verticalSplitView
         setPosition:currentWindowController.lastSavedRequestsViewWidth
         ofDividerAtIndex:0];
        [self.showSavedRequestsMenuItem setTitle:HIDE_SAVED_REQUESTS_MENU_TITLE];
    }
    else {
        currentWindowController.lastSavedRequestsViewWidth = [currentWindowController.savedRequestsOuterView frame].size.width;
        [currentWindowController.savedRequestsOuterView setHidden:YES];
        [self.showSavedRequestsMenuItem setTitle:SHOW_SAVED_REQUESTS_MENU_TITLE];
    }
    [currentWindowController.verticalSplitView adjustSubviews];
}

- (IBAction) syntaxHighlightingToggled:(id)sender {
    NSInteger state = [((NSMenuItem *) sender) state];
    if (state == NSOnState) {
        [((NSMenuItem *) sender) setState:NO];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SYNTAX_HIGHLIGHT];
    } else if (state == NSOffState) {
        [((NSMenuItem *) sender) setState:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SYNTAX_HIGHLIGHT];
    }
    for (id mainWindowController in mainWindowControllers) {
        [((MainWindowController *)mainWindowController) syntaxHighlightingPreferenceChanged];
    }
}

- (void) showLineNumbersToggled:(id)sender {
    NSInteger state = [((NSMenuItem *) sender) state];
    BOOL lineNumberState;
    if (state == NSOnState) {
        lineNumberState = NO;
    } else if (state == NSOffState) {
        lineNumberState = YES;
    }
    
    [((NSMenuItem *) sender) setState:lineNumberState];
    [[NSUserDefaults standardUserDefaults] setBool:lineNumberState forKey:SHOW_LINE_NUMBERS];
    
    for (id mainWindowController in mainWindowControllers) {
        [((MainWindowController *)mainWindowController) applyShowLineNumbers:lineNumberState];
    }
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

- (IBAction) zoomDefault:(id)sender {
    aceViewFontSize = DEFAULT_FONT_SIZE;
    for (id mainWindowController in mainWindowControllers) {
        [((MainWindowController *)mainWindowController).responseView setFontSize:DEFAULT_FONT_SIZE];
        [((MainWindowController *)mainWindowController).requestView setFontSize:DEFAULT_FONT_SIZE];
    }
}

- (IBAction)zoomIn:(id)sender {
    aceViewFontSize += 2;
    for (id mainWindowController in mainWindowControllers) {
        [((MainWindowController *)mainWindowController).responseView setFontSize:aceViewFontSize];
        [((MainWindowController *)mainWindowController).requestView setFontSize:aceViewFontSize];
    }
}

- (IBAction)zoomOut:(id)sender{
    aceViewFontSize -= 2;
    for (id mainWindowController in mainWindowControllers) {
        [((MainWindowController *)mainWindowController).responseView setFontSize:aceViewFontSize];
        [((MainWindowController *)mainWindowController).requestView setFontSize:aceViewFontSize];
    }
}

- (IBAction) themeMenuItemSelected:(id)sender {
    // Update theme in all open windows
    for (id mainWindowController in mainWindowControllers) {
        [((MainWindowController *)mainWindowController).responseView setTheme:[sender tag]];
        [((MainWindowController *)mainWindowController).requestView setTheme:[sender tag]];
    }
    
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

- (IBAction) diffTwoResponses:(id)sender {
    [diffWindowController showWindow:self];
}

#pragma mark -
#pragma mark Content Type Menu

- (IBAction) contentTypeMenuItemSelected:(id)sender {
    [currentWindowController contentTypeMenuItemSelected:sender];
}

#pragma mark -
#pragma mark Help Menu

- (IBAction) helpInfo:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://mmattozzi.github.io/cocoa-rest-client/"]];
}

- (IBAction) licenseInfo:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/mmattozzi/cocoa-rest-client/master/LICENSE.txt"]];
}

// Including this to disable Open Window menu item when window is already open
- (BOOL)validateMenuItem:(NSMenuItem *)item
{
    //check to see if the Main Menu NSMenuItem is
    //being validcated
    if([item tag] == MAIN_WINDOW_MENU_TAG) {
        //return ![currentWindowController.window isVisible];
    } else if ([item tag] == REGET_MENU_TAG) {
        return (currentWindowController.lastRequest != nil && [currentWindowController.lastRequest.method isEqualToString:@"GET"]);
    }
    
    return TRUE;
}

@end
