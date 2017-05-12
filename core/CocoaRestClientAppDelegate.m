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

#define MAIN_WINDOW_MENU_TAG 150
#define REGET_MENU_TAG 151

#define APPLICATION_NAME @"CocoaRestClient"
#define DATAFILE_NAME @"CocoaRestClient.savedRequests"
#define BACKUP_DATAFILE_1_3_8 @"CocoaRestClient.savedRequests.backup-1.3.8"

@interface CocoaRestClientAppDelegate(Private)
- (void)loadSavedDictionary:(NSDictionary *)request;
- (void)loadSavedCRCRequest:(CRCRequest *)request;

@end

@implementation CocoaRestClientAppDelegate

@synthesize mainWindowControllers;
@synthesize preemptiveBasicAuth;
@synthesize savedOutlineView;
@synthesize saveRequestSheet;
@synthesize saveRequestTextField;
@synthesize savedRequestsDrawer;
@synthesize headersTab;
@synthesize timeoutSheet;
@synthesize timeoutField;
@synthesize plusParam, minusParam;
@synthesize tabView;
@synthesize reqHeadersTab;
@synthesize status;
@synthesize requestHeadersSentText;
@synthesize progressIndicator;
@synthesize drawerView;
@synthesize preferencesController;
@synthesize responseTextPlain;
@synthesize requestTextPlain;
@synthesize responseTextPlainView;
@synthesize requestTextPlainView;
@synthesize syntaxHighlightingMenuItem;
@synthesize reGetResponseMenuItem;
@synthesize welcomeController;
@synthesize themeMenuItem;
@synthesize jsonWriter;
@synthesize showLineNumbersMenuItem;
@synthesize rawInputButton;
@synthesize fieldInputButton;
@synthesize fileInputButton;
@synthesize fastSearchSavedRequestsController;
@synthesize savedRequestsArray;
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
    
	
    [self loadDataFromDisk];
    
    
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
	
	
    NSSize drawerSize;
    drawerSize.width = 200;
    drawerSize.height = 0;    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:SAVED_DRAWER_SIZE]) {
        drawerSize.width = [[NSUserDefaults standardUserDefaults] integerForKey:SAVED_DRAWER_SIZE];
    }
    [savedRequestsDrawer setContentSize:drawerSize];
    [savedRequestsDrawer open];
    
    exportRequestsController.savedOutlineView = savedOutlineView;
    
    drawerView.cocoaRestClientAppDelegate = self;
    [drawerView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    
    
    [reGetResponseMenuItem setEnabled:NO];
    
    
    //[self syntaxHighlightingPreferenceChanged];
    
    
    // Enable Drag and Drop for outline view of saved requests
    [self.savedOutlineView registerForDraggedTypes: [NSArray arrayWithObject: @"public.text"]];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deleteSavedRequest:)
                                                 name:@"deleteDrawerRow"
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


#pragma mark OutlineViewDataSource methods
- (NSInteger) outlineView: (NSOutlineView *)outlineView numberOfChildrenOfItem: (id)item {
	if (item == nil) {
		return [savedRequestsArray count];
	} else {
		return [item count];
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if (item == nil) return NO;
    return [item isKindOfClass:[CRCSavedRequestFolder class]];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil) {
        return [savedRequestsArray objectAtIndex:index];
    } else {
        return [item objectAtIndex:index];
    }
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if ([item isKindOfClass:[CRCRequest class]])
	{
		CRCRequest * req = (CRCRequest *)item;
		return req.name;
	}
	else if ([item isKindOfClass:[CRCSavedRequestFolder class]])
	{
		return ((CRCSavedRequestFolder *)item).name;
	}
	else if (item == savedRequestsArray) {
		return savedRequestsArray;
    }
    
    return nil;
}

- (void) outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if ([item isKindOfClass:[CRCRequest class]]) {
		CRCRequest * req = (CRCRequest *)item;
		req.name = object;
	}
	else if ([item isKindOfClass:[CRCSavedRequestFolder class]]) {
		((CRCSavedRequestFolder *)item).name = object;
	}
}

#pragma mark OutlineView drag and drop methods
- (id <NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView pasteboardWriterForItem:(id)item{
    // No dragging if <some condition isn't met>
    BOOL dragAllowed = YES;
    if (!dragAllowed)  {
        return nil;
    }
    
    NSPasteboardItem *pboardItem = [[NSPasteboardItem alloc] init];
    NSString *idStr = [NSString stringWithFormat:@"%ld", (long) item];
    [pboardItem setString:idStr forType: @"public.text"];
    NSLog(@"%@", idStr);
    
    return pboardItem;
}


- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id < NSDraggingInfo >)info proposedItem:(id)targetItem proposedChildIndex:(NSInteger)index{
    
    if (index >= 0) {
        return NSDragOperationMove;
    } else {
        return NSDragOperationNone;
    }
}


- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id < NSDraggingInfo >)info item:(id)targetItem childIndex:(NSInteger)targetIndex{
    
    NSPasteboard *p = [info draggingPasteboard];
    NSString *objId = [p stringForType:@"public.text"];
    NSLog(@"Pasteboad item = %@", objId);
    
    id sourceItem = nil;
    CRCSavedRequestFolder *sourceParentFolder = nil;
    int sourceIndex = -1;
    
    for (id entry in savedRequestsArray) {
        if ([[NSString stringWithFormat:@"%ld", (long) entry] isEqualToString:objId]) {
            sourceItem = entry;
            sourceIndex = [savedRequestsArray indexOfObject:sourceItem];
        } else if ([entry isKindOfClass:[CRCSavedRequestFolder class]]) {
            id recursiveParent = [((CRCSavedRequestFolder *)entry) findParentOfObjectWith:objId];
            if (recursiveParent) {
                sourceParentFolder = recursiveParent;
                sourceItem = [((CRCSavedRequestFolder *)sourceParentFolder) findObjectWith:objId];
                sourceIndex = [((CRCSavedRequestFolder *)sourceParentFolder) findIndexOfObject:sourceItem];
            }
        }
    }
    
    // Unclear how this would happen, but we don't know what we are moving
    if (! sourceItem) {
        NSLog(@"Unable to find source item dropped into list");
        return NO;
    }
    
    if (sourceIndex == -1) {
        NSLog(@"Unable to find index of moving item");
        return NO;
    }
    
    if (targetItem == sourceItem) {
        return NO;
    }
        
    if (sourceParentFolder) {
        [((CRCSavedRequestFolder *) sourceParentFolder) removeObject:sourceItem];
    } else {
        [savedRequestsArray removeObject:sourceItem];
    }    
    
    NSLog(@"Found source item of drop: %@ with parent %@", sourceItem, sourceParentFolder);
    
    if (! targetItem) {
        // Saving into the top level array
        if (sourceParentFolder == nil && (targetIndex > sourceIndex)) {
            targetIndex--;
        }
        [savedRequestsArray insertObject:sourceItem atIndex:targetIndex];
        [savedOutlineView reloadItem:nil reloadChildren:YES];
        [self saveDataToDisk];
        return YES;
    } else {
        // Saving into a sub-folder
        NSLog(@"TargetIndex = %ld and sourceIndex = %d", targetIndex, sourceIndex);
        if (sourceParentFolder == targetItem && (targetIndex > sourceIndex)) {
            targetIndex--;
        }
        [((CRCSavedRequestFolder *) targetItem) insertObject:sourceItem atIndex:targetIndex];
        [savedOutlineView reloadItem:nil reloadChildren:YES];
        [self saveDataToDisk];
        return YES;
    }
    
}


- (IBAction) createNewSavedFolder:(id)sender {
    CRCSavedRequestFolder *folder = [[CRCSavedRequestFolder alloc] init];
    folder.name = @"New folder";
    // [savedRequestsArray addObject:folder];
    
    id selectedSavedOutlineViewItem = [savedOutlineView itemAtRow:[savedOutlineView selectedRow]];
    if ([selectedSavedOutlineViewItem isKindOfClass:[CRCSavedRequestFolder class]]) {
        [selectedSavedOutlineViewItem addObject:folder];
    } else {
        [savedRequestsArray addObject:folder];
    }
    
    [savedOutlineView reloadItem:nil reloadChildren:YES];
    [savedOutlineView expandItem:folder expandChildren:YES];
    [savedOutlineView editColumn:0 row:[savedOutlineView rowForItem:folder] withEvent:nil select:YES];
}

// Respond to click on a row of the saved requests outline view
- (IBAction) outlineClick:(id)sender {
	[self loadSavedRequest:[savedOutlineView itemAtRow:[savedOutlineView selectedRow]]];
}

- (void) deleteSavedRequest:(NSNotification *) notification  {
    id object = [savedOutlineView itemAtRow:[savedOutlineView selectedRow]];
    if ([savedRequestsArray containsObject:object]) {
        [savedRequestsArray removeObject:object];
    } else {
        for (id entry in savedRequestsArray) {
            if ([entry isKindOfClass:[CRCSavedRequestFolder class]]) {
                [entry removeObject:object];
            }
        }
    }
    [savedOutlineView reloadItem:nil reloadChildren:YES];
    [self saveDataToDisk];
}

// Save an HTTP request into the request drawer
// This is the Save As menu option because the user will always have a chance to name the request.
- (IBAction) saveRequest:(id) sender {
    lastSelectedSavedOutlineViewItem = [savedOutlineView itemAtRow:[savedOutlineView selectedRow]];
    [savedOutlineView deselectAll:nil];
	[NSApp beginSheet:saveRequestSheet modalForWindow:currentWindowController.window
        modalDelegate:self didEndSelector:NULL contextInfo:nil];
}

// Dispose of save request sheet
- (IBAction) doneSaveRequest:(id) sender {
	if ([sender isKindOfClass:[NSTextField class]] || ! [[sender title] isEqualToString:@"Cancel"]) {
		CRCRequest * request = [CRCRequest requestWithWindow:currentWindowController];
		
        if ([lastSelectedSavedOutlineViewItem isKindOfClass:[CRCSavedRequestFolder class]]) {
            [lastSelectedSavedOutlineViewItem addObject:request];
        } else {
            [savedRequestsArray addObject:request];
        }
		[savedOutlineView reloadItem:nil reloadChildren:YES];
	}
	[saveRequestSheet orderOut:nil];
    [NSApp endSheet:saveRequestSheet];
    [self saveDataToDisk];
}

- (IBAction) openFastSearchSavedRequestsPanel:(id)sender {
    [savedOutlineView deselectAll:nil];
    [fastSearchSavedRequestsController setupWindow:savedRequestsArray];
    [currentWindowController.window beginSheet:[fastSearchSavedRequestsController window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSModalResponseOK) {
            if (fastSearchSavedRequestsController.selectedRequest) {
                [self loadSavedRequest:fastSearchSavedRequestsController.selectedRequest];
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
    int row = [savedOutlineView selectedRow];
    if (row > -1) {
        CRCRequest * request = [CRCRequest requestWithWindow:currentWindowController];
        
        id selectedSavedOutlineViewItem = [savedOutlineView itemAtRow:[savedOutlineView selectedRow]];
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
                [savedOutlineView reloadItem:nil reloadChildren:YES];
                [self saveDataToDisk];
            }
        }
    } else {
        return [self saveRequest:sender];
    }
}

- (IBAction) openTimeoutDialog:(id) sender {
	[timeoutField setIntValue:[[NSUserDefaults standardUserDefaults] integerForKey:RESPONSE_TIMEOUT]];
	[NSApp beginSheet:timeoutSheet modalForWindow:currentWindowController.window modalDelegate:self didEndSelector:NULL contextInfo:nil];
}

- (IBAction) closeTimoutDialog:(id) sender {
	if ([sender isKindOfClass:[NSTextField class]] || ! [[sender title] isEqualToString:@"Cancel"]) {
		[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:[timeoutField intValue]] forKey:RESPONSE_TIMEOUT];
	}
	[timeoutSheet orderOut:nil];
    [NSApp endSheet:timeoutSheet];
}

- (void)loadSavedRequest:(id)request {
	
	if([request isKindOfClass:[NSDictionary class]]) {
		[self loadSavedDictionary:(NSDictionary *)request];
	}
	else if([request isKindOfClass:[CRCRequest class]]) {
		[self loadSavedCRCRequest:(CRCRequest *)request];
        if ([CRCFileRequest currentRequestIsCRCFileRequest:currentWindowController]) {
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:FILE_REQUEST_BODY];
        } else {
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:FILE_REQUEST_BODY];
        }
	}
    
    [currentWindowController selectRequestBodyInputMode];
}

- (NSString *) pathForDataFile {
    if (!appDataFilePath) {
        NSArray *allPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSString *dir = [[allPaths objectAtIndex: 0] stringByAppendingPathComponent: APPLICATION_NAME];
        if (!dir) {
            NSLog(@"Can not locate the Application Support directory. Weird.");
            return nil;
        }
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        BOOL success = [fileManager createDirectoryAtPath: dir withIntermediateDirectories: YES
                                               attributes: nil error: &error];
        if (!success) {
            NSLog(@"Can not create a support directory.\n%@", [error localizedDescription]);
            return nil;
        }
        appDataFilePath = [dir stringByAppendingPathComponent: DATAFILE_NAME];
        
        // On first time startup of version 1.3.8 of the app, backup the data file since the format
        // will make it backwards incompatible.
        NSString *backupDataFilePath = [dir stringByAppendingPathComponent:BACKUP_DATAFILE_1_3_8];
        if (! [fileManager fileExistsAtPath:backupDataFilePath]) {
            NSError *error = nil;
            [fileManager copyItemAtPath:appDataFilePath toPath:backupDataFilePath error:&error];
            if (! error) {
                NSLog(@"Successfully backed up 1.3.8 datafile as: %@", backupDataFilePath);
            } else {
                NSLog(@"Error backing up old data file: %@", [error localizedDescription]);
            }
        }
    }
    return appDataFilePath;  
}

- (void) saveDataToDisk {
	NSString *path = [self pathForDataFile];
	[NSKeyedArchiver archiveRootObject:savedRequestsArray toFile:path];
}

- (void) loadDataFromDisk {
	NSString *path = [self pathForDataFile];
	savedRequestsArray = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:path]];
}

- (IBAction) reloadRequestsDrawer:(id)sender {
    [self loadDataFromDisk];
    [self.savedOutlineView reloadData];
}

- (void) importRequestsFromArray:(NSArray *)requests {
    [exportRequestsController prepareToDisplayImports:requests];
    [NSApp beginSheet: [exportRequestsController window]
       modalForWindow: currentWindowController.window
        modalDelegate: exportRequestsController
       didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
          contextInfo: nil];
}

- (void) invalidFileAlert {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Invalid file"];
    [alert setInformativeText:@"Unable to read stored requests from file."];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:currentWindowController.window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (IBAction) importRequests:(id)sender {
    
    NSOpenPanel* picker = [NSOpenPanel openPanel];
	
	[picker setCanChooseFiles:YES];
	[picker setCanChooseDirectories:NO];
	[picker setAllowsMultipleSelection:NO];
    
    NSMutableArray *loadedRequests = [[NSMutableArray alloc] init];
    [picker beginSheetModalForWindow:currentWindowController.window
                   completionHandler:^(NSInteger result) {
                       if (result == NSFileHandlingPanelOKButton) {
                           @try {
                               for(NSURL* url in [picker URLs]) {
                                   NSString *path = [url path];
                                   NSLog(@"Loading requests from %@", path);
                                   [loadedRequests addObjectsFromArray:[NSKeyedUnarchiver unarchiveObjectWithFile:path]];
                                   
                                   if ([loadedRequests count] > 0) {
                                       [self importRequestsFromArray:loadedRequests];
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
    [exportRequestsController prepareToDisplayExports];
    [NSApp beginSheet: [exportRequestsController window]
       modalForWindow: currentWindowController.window
        modalDelegate: exportRequestsController
       didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
          contextInfo: nil];
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
	[self saveDataToDisk];
    [[NSUserDefaults standardUserDefaults] setInteger:[savedRequestsDrawer contentSize].width forKey:SAVED_DRAWER_SIZE];
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
    CRCRequest * request = [CRCRequest requestWithWindow:currentWindowController];
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
    NSString *curlCommand = [request generateCurlCommand:[[NSUserDefaults standardUserDefaults] boolForKey:FOLLOW_REDIRECTS]];
    NSLog(@"Generated curl command: %@", curlCommand);
    [pasteBoard setString:curlCommand forType:NSStringPboardType];
}

- (IBAction)requestBodyInputMode:(id)sender {
    NSLog(@"Sender: %@", [sender identifier]);
    if ([[sender identifier] isEqualToString:@"rawInput"]) {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:RAW_REQUEST_BODY];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:FILE_REQUEST_BODY];
    } else if ([[sender identifier] isEqualToString:@"fieldInput"]) {
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:RAW_REQUEST_BODY];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:FILE_REQUEST_BODY];
    } else if ([[sender identifier] isEqualToString:@"fileInput"]) {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:RAW_REQUEST_BODY];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:FILE_REQUEST_BODY];
    }
    
    [currentWindowController selectRequestBodyInputMode];
}


@end
