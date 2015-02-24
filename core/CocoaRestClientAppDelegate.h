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

extern NSString* const FOLLOW_REDIRECTS;
extern NSString* const RESPONSE_TIMEOUT;

@class CRCRequest;
@class CRCDrawerView;

@interface CocoaRestClientAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource> {
    
    BOOL preemptiveBasicAuth;
	
	NSMutableData *receivedData;
	NSString *contentType;
    NSString *charset;
	
	NSMutableArray *headersTable;
	NSMutableArray *filesTable;
	NSMutableArray *paramsTable;
	
	NSMutableArray *savedRequestsArray;
	
	ExportRequestsController *exportRequestsController;
    PreferencesController *preferencesController;
    WelcomeController *welcomeController;
    
    BOOL allowSelfSignedCerts;
    NSURLRequest *currentRequest;
    
	BOOL rawRequestInput;
	NSDate *startDate;
	
    @private CRCRequest *lastRequest;
    @private NSSet *requestMethodsWithoutBody;
    
    @private NSArray *xmlContentTypes;
    @private NSArray *jsonContentTypes;
    @private NSArray *msgPackContentTypes;
    @private HighlightingTypeManager *responseTypeManager;
    @private HighlightingTypeManager *requestTypeManager;
    
    @private NSString *appDataFilePath;
    @private NSUInteger aceViewFontSize;
    
    id eventMonitor;	
}

@property (strong) SBJson4Writer *jsonWriter;

@property (nonatomic, readonly) NSMutableArray *headersTable;
@property (nonatomic, readonly) NSMutableArray *filesTable;
@property (nonatomic, readonly) NSMutableArray *paramsTable;

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSComboBox *urlBox;
@property (weak) IBOutlet NSButton *submitButton;

@property (weak) IBOutlet WebView *responseWebView;
@property (weak) IBOutlet ACEView *responseView;
@property (weak) IBOutlet ACEView *requestView;
@property (unsafe_unretained) IBOutlet NSTextView *responseTextHeaders;
@property (weak) IBOutlet NSComboBox *methodButton;
@property (weak) IBOutlet TabbingTableView *headersTableView;
@property (weak) IBOutlet TabbingTableView *filesTableView;
@property (weak) IBOutlet TabbingTableView *paramsTableView;
@property (weak) IBOutlet NSTextField *username;
@property (weak) IBOutlet NSTextField *password;
@property (assign) BOOL preemptiveBasicAuth;
@property (weak) IBOutlet NSOutlineView *savedOutlineView;
@property (weak) IBOutlet NSPanel *saveRequestSheet;
@property (weak) IBOutlet NSTextField *saveRequestTextField;
@property (weak) IBOutlet NSDrawer *savedRequestsDrawer;
@property (weak) IBOutlet NSTabViewItem *headersTab;
@property (weak) IBOutlet NSPanel *timeoutSheet;
@property (weak) IBOutlet NSTextField *timeoutField;
@property (weak) IBOutlet NSButton *plusParam;
@property (weak) IBOutlet NSButton *minusParam;
@property (assign) BOOL rawRequestInput;
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSTabViewItem *reqHeadersTab;
@property (weak) IBOutlet NSTextField *status;
@property (unsafe_unretained) IBOutlet NSTextView *requestHeadersSentText;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet CRCDrawerView *drawerView;
@property (strong) PreferencesController *preferencesController;
@property (unsafe_unretained) IBOutlet NSTextView *requestTextPlain;
@property (unsafe_unretained) IBOutlet NSTextView *responseTextPlain;
@property (weak) IBOutlet NSScrollView *responseTextPlainView;
@property (weak) IBOutlet NSScrollView *requestTextPlainView;
@property (weak) IBOutlet NSMenuItem *syntaxHighlightingMenuItem;
@property (weak) IBOutlet NSMenuItem *reGetResponseMenuItem;
@property (strong) WelcomeController *welcomeController;
@property (weak) IBOutlet NSMenuItem *themeMenuItem;

- (IBAction) runSubmit:(id)sender;
- (void) setResponseText:(NSString *)response;
- (NSString *) getResponseText;
- (void) setRequestText:(NSString *)request;
- (NSString *) getRequestText;
- (IBAction) doubleClickedHeaderRow:(id)sender;
- (IBAction) plusHeaderRow:(id)sender;
- (IBAction) minusHeaderRow:(id)sender;
- (IBAction) clearAuth:(id)sender;
- (IBAction) outlineClick:(id)sender;
- (IBAction) saveRequest:(id) sender;
- (IBAction) overwriteRequest:(id) sender;
- (IBAction) doneSaveRequest:(id) sender;
- (IBAction) createNewSavedFolder:(id)sender;
- (void) loadSavedRequest:(NSDictionary *) request;
- (IBAction) deleteSavedRequest:(id) sender;
- (NSString *) pathForDataFile;
- (void) loadDataFromDisk;
- (void) saveDataToDisk;
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
- (IBAction)deleteRow:(id)sender;
- (IBAction)showPreferences:(id)sender;
- (void)syntaxHighlightingPreferenceChanged;
- (IBAction) toggleSyntaxHighlighting:(id)sender;
- (IBAction) zoomIn:(id)sender;
- (IBAction) zoomOut:(id)sender;
- (IBAction) zoomDefault:(id)sender;
- (NSString *) saveResponseToTempFile;
- (IBAction) exportResponse:(id)sender;
- (IBAction) viewResponseInBrowser:(id)sender;
- (IBAction) reGetResponseInBrowser:(id)sender;
- (IBAction) viewResponseInDefaultApplication:(id)sender;
- (void) doneEditingHeaderRow:(TableRowAndColumn *)tableRowAndColumn;
- (void) doneEditingParamsRow:(TableRowAndColumn *)tableRowAndColumn;

- (void)setRawRequestInput:(BOOL)value;

- (void) initHighlightedViews;
- (void) setHighlightSyntaxForMIME:(NSString*) mimeType;

@end
