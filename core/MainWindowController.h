//
//  MainWindowController.h
//  CocoaRestClient
//
//  Created by Mike Mattozzi on 5/7/17.
//
//

#import <Cocoa/Cocoa.h>
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
#import "CRCRequest.h"

@class CocoaRestClientAppDelegate;

@interface MainWindowController : NSWindowController <NSTableViewDelegate, NSTableViewDataSource> {
    
    CocoaRestClientAppDelegate *appDelegate;
    
    NSMutableData *receivedData;
    NSString *contentType;
    NSString *charset;
    
    NSURLRequest *currentRequest;
    
    NSDate *startDate;
    
    @private HighlightingTypeManager *responseTypeManager;
    @private HighlightingTypeManager *requestTypeManager;
    
    id eventMonitor;
    id lastSelectedSavedOutlineViewItem;
}

@property (retain) CocoaRestClientAppDelegate *appDelegate;
@property (strong) SBJson4Writer *jsonWriter;

@property (nonatomic) NSMutableArray *headersTable;
@property (nonatomic) NSMutableArray *filesTable;
@property (nonatomic) NSMutableArray *paramsTable;

@property (nonatomic) BOOL preemptiveBasicAuth;

@property (retain) CRCRequest *lastRequest;

// Request Outlets
@property IBOutlet DMSlidingTabView             *requestTabView;
@property IBOutlet DMSlidingTabItemView         *requestBodyItemView;
@property IBOutlet DMSlidingTabItemView         *requestAuthItemView;
@property IBOutlet DMSlidingTabItemView         *requestFilesItemView;
@property IBOutlet DMSlidingTabItemView         *requestHeadersItemView;

// Response Outlets
@property IBOutlet DMSlidingTabView             *responseTabView;
@property IBOutlet DMSlidingTabItemView         *responseBodyItemView;
@property IBOutlet DMSlidingTabItemView         *responseHeadersItemView;
@property IBOutlet DMSlidingTabItemView         *responseHeadersSentItemView;


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
@property (weak) IBOutlet NSPanel *saveRequestSheet;
@property (weak) IBOutlet NSTextField *saveRequestTextField;
@property (weak) IBOutlet NSTabViewItem *headersTab;
@property (weak) IBOutlet NSPanel *timeoutSheet;
@property (weak) IBOutlet NSTextField *timeoutField;
@property (weak) IBOutlet NSButton *plusParam;
@property (weak) IBOutlet NSButton *minusParam;
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSTabViewItem *reqHeadersTab;
@property (weak) IBOutlet NSTextField *status;
@property (unsafe_unretained) IBOutlet NSTextView *requestHeadersSentText;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@property (unsafe_unretained) IBOutlet NSTextView *requestTextPlain;
@property (unsafe_unretained) IBOutlet NSTextView *responseTextPlain;
@property (weak) IBOutlet NSScrollView *responseTextPlainView;
@property (weak) IBOutlet NSScrollView *requestTextPlainView;
@property (strong) WelcomeController *welcomeController;

@property (weak) IBOutlet NSButton *rawInputButton;
@property (weak) IBOutlet NSButton *fieldInputButton;
@property (weak) IBOutlet NSButton *fileInputButton;

// Fast saved request search
@property (strong) FastSearchSavedRequestsController *fastSearchSavedRequestsController;

- (IBAction) runSubmit:(id)sender;
- (void) setResponseText:(NSString *)response;
- (NSString *) getResponseText;
- (void) setRequestText:(NSString *)request;
- (NSString *) getRequestText;
- (IBAction) doubleClickedHeaderRow:(id)sender;
- (IBAction) plusHeaderRow:(id)sender;
- (IBAction) minusHeaderRow:(id)sender;
- (IBAction) clearAuth:(id)sender;

- (IBAction) doubleClickedFileRow:(id)sender;
- (IBAction) plusFileRow:(id)sender;
- (IBAction) minusFileRow:(id)sender;
- (void) addFileToFilesTable: (NSURL*) fileUrl;
- (IBAction) doubleClickedParamsRow:(id)sender;
- (IBAction) plusParamsRow:(id)sender;
- (IBAction) minusParamsRow:(id)sender;


// - (void) deleteTableRow:(NSNotification *) notification;
- (void)syntaxHighlightingPreferenceChanged;

- (void) doneEditingHeaderRow:(TableRowAndColumn *)tableRowAndColumn;
- (void) doneEditingParamsRow:(TableRowAndColumn *)tableRowAndColumn;
- (void) selectRequestBodyInputMode;

- (void)loadSavedCRCRequest:(CRCRequest *)request;
- (void) applyShowLineNumbers:(BOOL)show;

- (void) contentTypeMenuItemSelected:(id)sender;

- (void) initHighlightedViews;

@end
