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

@class CRCRequest;
@class CRCDrawerView;
@class MainWindowController;
@class SavedRequestsDataSource;

@interface CocoaRestClientAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource> {
    ExportRequestsController *exportRequestsController;
    PreferencesController *preferencesController;
    FastSearchSavedRequestsController *fastSearchSavedRequestsController;
    
    MainWindowController *currentWindowController;
    
    id eventMonitor;
    id lastSelectedSavedOutlineViewItem;
}

// Reference to WindowControllers of all windows that are open
@property (retain) NSMutableArray *mainWindowControllers;

// Manages saved request outline view data across all windows
@property (strong) SavedRequestsDataSource *savedRequestsDataSource;

// Used throughout by all application windows
@property (strong) NSSet *requestMethodsWithoutBody;
@property (atomic) BOOL allowSelfSignedCerts;
@property (atomic) NSUInteger aceViewFontSize;

// Menu Items that need to be checked, unchecked, enabled, or disabled
@property (weak) IBOutlet NSMenuItem *syntaxHighlightingMenuItem;
@property (weak) IBOutlet NSMenuItem *reGetResponseMenuItem;
@property (weak) IBOutlet NSMenuItem *showLineNumbersMenuItem;
@property (weak) IBOutlet NSMenuItem *themeMenuItem;

// Window management methods
- (void) addTabFromWindow:(NSWindow *)window;
- (void) tabWasRemoved:(NSWindowController *)windowController;
- (void) setCurrentMainWindowController:(MainWindowController *)mainWindowController;
- (void) applicationWillTerminate: (NSNotification *)note;

// Saved requests management
- (void) redrawRequestViews;
- (void) deselectSavedRequest:(NSNotification *)notification;
- (void) importRequestsFromArray:(NSArray *)requests;
- (void) deleteSavedRequest: (NSNotification *) notification;

// Utility Methods
- (void) invalidFileAlert;
- (NSString *) saveResponseToTempFile;

//
// Actions driven from Menu Items
//

/* Application Menu */
- (IBAction)showPreferences:(id)sender;

/* File Menu */
- (IBAction) handleOpenWindow:(id)sender;
- (IBAction) handleCloseWindow:(id)sender;
- (IBAction) newTab:(id)sender;
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
- (IBAction) showLineNumbersToggled:(id)sender;
- (IBAction) openFastSearchSavedRequestsPanel:(id)sender;
- (IBAction) zoomDefault:(id)sender;
- (IBAction) zoomIn:(id)sender;
- (IBAction) zoomOut:(id)sender;
- (IBAction) themeMenuItemSelected:(id)sender;

/* Content Type Menu */
- (IBAction) contentTypeMenuItemSelected:(id)sender;

/* Help Menu */
- (IBAction) helpInfo:(id)sender;
- (IBAction) licenseInfo:(id)sender;

// Called for all menu enabled/disabled status
- (BOOL)validateMenuItem:(NSMenuItem *)item;

// ??

// Whatever happened to this menu item?
- (IBAction) allowSelfSignedCerts:(id)sender;


- (void)syntaxHighlightingPreferenceChanged;
//- (void) setHighlightSyntaxForMIME:(NSString*) mimeType;


@end
