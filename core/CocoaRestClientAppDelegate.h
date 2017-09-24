//
//  CocoaRestClientAppDelegate.h
//  CocoaRestClient
//
//  Created by mmattozzi on 1/5/10.
//  Copyright 2012 Michael Mattozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "ExportRequestsController.h"
#import "CRCDrawerView.h"
#import "TabbingTableView.h"
#import "PreferencesController.h"
#import "WelcomeController.h"
#import "TableRowAndColumn.h"
#import "ACEView/ACEView.h"
#import "HighlightingTypeManager.h"
#import <SBJson4.h>
#import "CRCConstants.h"
#import "DMSlidingTabView.h"
#import "DMSlidingTabItemView.h"
#import "FastSearchSavedRequestsController.h"
#import "DiffWindowController.h"

@class CRCRequest;
@class CRCDrawerView;
@class MainWindowController;
@class SavedRequestsDataSource;

@interface CocoaRestClientAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource> {
    ExportRequestsController *exportRequestsController;
    PreferencesController *preferencesController;
    FastSearchSavedRequestsController *fastSearchSavedRequestsController;
    DiffWindowController *diffWindowController;
    
    MainWindowController *currentWindowController;
    
    id eventMonitor;
    id lastSelectedSavedOutlineViewItem;
    NSUInteger windowNumber;
}

// Reference to WindowControllers of all windows that are open
@property (retain) NSMutableArray *mainWindowControllers;

// Manages saved request outline view data across all windows
@property (strong) SavedRequestsDataSource *savedRequestsDataSource;

// Used throughout by all application windows
@property (strong) NSSet *requestMethodsWithoutBody;
@property (atomic) NSUInteger aceViewFontSize;

// Menu Items that need to be checked, unchecked, enabled, or disabled
@property (weak) IBOutlet NSMenuItem *syntaxHighlightingMenuItem;
@property (weak) IBOutlet NSMenuItem *reGetResponseMenuItem;
@property (weak) IBOutlet NSMenuItem *showLineNumbersMenuItem;
@property (weak) IBOutlet NSMenuItem *themeMenuItem;
@property (weak) IBOutlet NSMenuItem *showSavedRequestsMenuItem;

// Window management methods
- (void) addTabFromWindow:(NSWindow *)window;
- (void) tabWasRemoved:(NSWindowController *)windowController;
- (void) setCurrentMainWindowController:(MainWindowController *)mainWindowController;
- (void) applicationWillTerminate: (NSNotification *)note;
- (void) windowSubmittedRequest:(MainWindowController *)mainWindowController;
- (void) setWindowTitle:(MainWindowController *)mainWindowController withBaseTitle:(NSString *)title;
- (void) setWindowTitle:(MainWindowController *)mainWindowController withBaseTitle:(NSString *)title index:(NSUInteger)index;

// Saved requests management
- (void) redrawRequestViews;
- (void) deselectSavedRequest:(NSNotification *)notification;
- (void) importRequestsFromArray:(NSArray *)requests;
- (void) deleteSavedRequest: (NSNotification *) notification;

// Utility Methods
- (void) invalidFileAlert;
- (IBAction) restartRequiredAlert:(id)sender;
- (NSString *) saveResponseToTempFile;
+ (NSString *) nameForRequest:(id)object;
+ (void) addBorderToView:(NSView *)view;

//
// Actions driven from Menu Items
//

/* Application Menu */
- (IBAction)showPreferences:(id)sender;

/* File Menu */
- (IBAction) handleOpenWindow:(id)sender;
- (IBAction) handleCloseWindow:(id)sender;
- (IBAction) newTab:(id)sender;
- (IBAction) submitRequest:(id)sender;
- (IBAction) reloadLastRequest:(id)sender;
- (IBAction) overwriteRequest:(id) sender; // Save
- (IBAction) saveRequest:(id) sender; // Save As...
- (IBAction) deleteSavedRequestFromMenu:(id) sender;
- (IBAction) importRequests:(id)sender;
- (IBAction) exportRequests:(id)sender;
- (IBAction) reloadRequestsDrawer:(id)sender;
- (IBAction) exportResponse:(id)sender;
- (IBAction) viewResponseInBrowser:(id)sender;
- (IBAction) viewResponseInDefaultApplication:(id)sender;
- (IBAction) reGetResponseInBrowser:(id)sender;

/* Edit Menu */
- (IBAction) copyCurlCommand:(id)sender;
- (IBAction) findMenuItem:(id)sender;
- (IBAction) replaceMenuItem:(id)sender;
- (IBAction) findNextMenuItem:(id)sender;
- (IBAction) findPreviousMenuItem:(id)sender;

/* Options Menu */
- (IBAction) openTimeoutDialog:(id) sender;
// Rest of Option MenuItems just set SharedUserDefaults in IB

/* View Menu */
- (IBAction) toggleVerticalSplitView:(id)sender;
- (IBAction) syntaxHighlightingToggled:(id)sender;
- (IBAction) showLineNumbersToggled:(id)sender;
- (IBAction) openFastSearchSavedRequestsPanel:(id)sender;
- (IBAction) zoomDefault:(id)sender;
- (IBAction) zoomIn:(id)sender;
- (IBAction) zoomOut:(id)sender;
- (IBAction) themeMenuItemSelected:(id)sender;
- (IBAction) diffTwoResponses:(id)sender;

/* Content Type Menu */
- (IBAction) contentTypeMenuItemSelected:(id)sender;

/* Help Menu */
- (IBAction) helpInfo:(id)sender;
- (IBAction) licenseInfo:(id)sender;

// Called for all menu enabled/disabled status
- (BOOL)validateMenuItem:(NSMenuItem *)item;

@end
