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
    WelcomeController *welcomeController;
    FastSearchSavedRequestsController *fastSearchSavedRequestsController;
    
    MainWindowController *currentWindowController;
    
    @private HighlightingTypeManager *responseTypeManager;
    @private HighlightingTypeManager *requestTypeManager;
    
    
    
    id eventMonitor;
    id lastSelectedSavedOutlineViewItem;
}

@property (strong) SBJson4Writer *jsonWriter;

@property (strong) SavedRequestsDataSource *savedRequestsDataSource;

@property (strong) NSSet *requestMethodsWithoutBody;
@property (atomic) BOOL allowSelfSignedCerts;
@property (atomic) NSUInteger aceViewFontSize;


@property (retain) NSMutableArray *mainWindowControllers;

@property (assign) BOOL preemptiveBasicAuth;

@property (strong) PreferencesController *preferencesController;
@property (weak) IBOutlet NSMenuItem *syntaxHighlightingMenuItem;
@property (weak) IBOutlet NSMenuItem *reGetResponseMenuItem;
@property (weak) IBOutlet NSMenuItem *showLineNumbersMenuItem;
@property (strong) WelcomeController *welcomeController;
@property (weak) IBOutlet NSMenuItem *themeMenuItem;


// Fast saved request search
@property (strong) FastSearchSavedRequestsController *fastSearchSavedRequestsController;

- (void) addTabFromWindow:(NSWindow *)window;
- (void) tabWasRemoved:(NSWindowController *)windowController;
- (void) setCurrentMainWindowController:(MainWindowController *)mainWindowController;

- (IBAction) outlineClick:(id)sender;
- (IBAction) saveRequest:(id) sender;
- (IBAction) overwriteRequest:(id) sender;
- (IBAction) doneSaveRequest:(id) sender;
- (IBAction) createNewSavedFolder:(id)sender;
- (void) loadSavedRequest:(NSDictionary *) request;
- (void) deleteSavedRequest: (NSNotification *) notification;
- (IBAction) reloadRequestsDrawer:(id)sender;

- (void) redrawRequestViews;

- (void) applicationWillTerminate: (NSNotification *)note;
- (IBAction) openTimeoutDialog:(id) sender;
- (IBAction) closeTimoutDialog:(id) sender;
- (IBAction) doubleClickedFileRow:(id)sender;
- (IBAction) plusFileRow:(id)sender;
- (IBAction) minusFileRow:(id)sender;
- (void) addFileToFilesTable: (NSURL*) fileUrl;
- (IBAction) doubleClickedParamsRow:(id)sender;
- (IBAction) plusParamsRow:(id)sender;
- (IBAction) minusParamsRow:(id)sender;
- (IBAction) contentTypeMenuItemSelected:(id)sender;
- (IBAction) themeMenuItemSelected:(id)sender;
- (IBAction) handleOpenWindow:(id)sender;
- (IBAction) handleCloseWindow:(id)sender;
- (BOOL)validateMenuItem:(NSMenuItem *)item;
- (IBAction) helpInfo:(id)sender;
- (IBAction) licenseInfo:(id)sender;
- (IBAction) reloadLastRequest:(id)sender;
- (IBAction) allowSelfSignedCerts:(id)sender;
- (IBAction) importRequests:(id)sender;
- (IBAction) exportRequests:(id)sender;
- (void) importRequestsFromArray:(NSArray *)requests;
- (void) invalidFileAlert;
- (void) deleteTableRow:(NSNotification *) notification;
- (IBAction)showPreferences:(id)sender;
- (void)syntaxHighlightingPreferenceChanged;
- (IBAction) zoomIn:(id)sender;
- (IBAction) zoomOut:(id)sender;
- (IBAction) zoomDefault:(id)sender;
- (NSString *) saveResponseToTempFile;
- (IBAction) exportResponse:(id)sender;
- (IBAction) viewResponseInBrowser:(id)sender;
- (IBAction) reGetResponseInBrowser:(id)sender;
- (IBAction) viewResponseInDefaultApplication:(id)sender;

- (IBAction) findMenuItem:(id)sender;
- (IBAction) findNextMenuItem:(id)sender;
- (IBAction) findPreviousMenuItem:(id)sender;
- (IBAction) replaceMenuItem:(id)sender;

- (void) deleteSavedRequest: (NSNotification *) notification;
- (void) deselectSavedRequest:(NSNotification *)notification;

//- (void) setHighlightSyntaxForMIME:(NSString*) mimeType;
- (IBAction) showLineNumbersToggled:(id)sender;

- (IBAction) copyCurlCommand:(id)sender;

// For opening fast saved request search
- (IBAction) openFastSearchSavedRequestsPanel:(id)sender;

@end
