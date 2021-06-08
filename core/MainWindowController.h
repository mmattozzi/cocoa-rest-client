//
//  MainWindowController.h
//  CocoaRestClient
//
//  Created by Mike Mattozzi on 5/7/17.
//
//

#import <Cocoa/Cocoa.h>
#import "ExportRequestsController.h"
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
#import "CRCRequest.h"
#import "ACEView+TouchBarExtension.h"

@class CocoaRestClientAppDelegate;
@class SavedRequestsDataSource;
@class CRCDrawerView;

@interface MainWindowController : NSWindowController <NSTableViewDelegate, NSTableViewDataSource, NSTouchBarDelegate> {
    
    NSMutableData *receivedData;
    NSString *contentType;
    NSString *charset;
    NSURLRequest *currentRequest;
    NSDate *startDate;
    
    @private NSTouchBarCustomizationIdentifier touchBarIdentifier;
    @private NSTouchBarItemIdentifier touchBarSaveIdentifier;
    @private NSTouchBarItemIdentifier touchBarSaveAsIdentifier;
    @private NSTouchBarItemIdentifier touchBarOpenIdentifier;
    @private NSTouchBarItemIdentifier touchBarGetIdentifier;
    @private NSTouchBarItemIdentifier touchBarPostIdentifier;
    @private NSTouchBarItemIdentifier touchBarPutIdentifier;
    @private NSTouchBarItemIdentifier touchBarCopyCurlIdentifier;
    @private NSDictionary *touchBarIdentifierToItemMap;
    
    @private HighlightingTypeManager *responseTypeManager;
    @private HighlightingTypeManager *requestTypeManager;
    @private SBJson4Writer *jsonWriter;
}

// Ties to parent application
@property (weak) CocoaRestClientAppDelegate *appDelegate;
@property (weak) IBOutlet SavedRequestsDataSource *savedRequestsDataSource;

// Configuration of current request
@property (nonatomic) NSMutableArray *headersTable;
@property (nonatomic) NSMutableArray *filesTable;
@property (nonatomic) NSMutableArray *paramsTable;
@property (nonatomic) NSMutableArray *urlParamsTable;
@property (nonatomic) BOOL preemptiveBasicAuth;
@property (nonatomic) BOOL rawRequestBody;
@property (nonatomic) BOOL fileRequestBody;

// Maintain last request after each execution
@property (retain) CRCRequest *lastRequest;

// Request Outlets
@property (weak) IBOutlet NSComboBox *urlBox;
@property IBOutlet DMSlidingTabView *requestTabView;
@property IBOutlet DMSlidingTabItemView *requestBodyItemView;
@property IBOutlet DMSlidingTabItemView *requestAuthItemView;
@property IBOutlet DMSlidingTabItemView *requestFilesItemView;
@property IBOutlet DMSlidingTabItemView *requestHeadersItemView;
@property IBOutlet DMSlidingTabItemView *urlParametersItemView;
@property (weak) IBOutlet ACEView *requestView;
@property (weak) IBOutlet NSComboBox *methodButton;
@property (weak) IBOutlet TabbingTableView *headersTableView;
@property (weak) IBOutlet TabbingTableView *filesTableView;
@property (weak) IBOutlet TabbingTableView *paramsTableView;
@property (weak) IBOutlet TabbingTableView *urlParametersTableView;
@property (weak) IBOutlet NSTextField *username;
@property (weak) IBOutlet NSTextField *password;
@property (weak) IBOutlet NSButton *plusParam;
@property (weak) IBOutlet NSButton *minusParam;
@property (weak) IBOutlet NSButton *submitButton;
@property (unsafe_unretained) IBOutlet NSTextView *requestTextPlain;
@property (weak) IBOutlet NSScrollView *requestTextPlainView;
@property (weak) IBOutlet NSButton *rawInputButton;
@property (weak) IBOutlet NSButton *fieldInputButton;
@property (weak) IBOutlet NSButton *fileInputButton;
@property (weak) IBOutlet NSButton *plusUrlParameterButton;
@property (weak) IBOutlet NSButton *minusUrlParameterButton;
@property (weak) IBOutlet NSVisualEffectView *mainBodyView;
@property (weak) IBOutlet NSVisualEffectView *topOuterView;

// Response Outlets
@property IBOutlet DMSlidingTabView *responseTabView;
@property IBOutlet DMSlidingTabItemView *responseBodyItemView;
@property IBOutlet DMSlidingTabItemView *responseHeadersItemView;
@property IBOutlet DMSlidingTabItemView *responseHeadersSentItemView;
@property (unsafe_unretained) IBOutlet NSTextView *responseTextHeaders;
@property (weak) IBOutlet ACEView *responseView;
@property (unsafe_unretained) IBOutlet NSTextView *requestHeadersSentText;
@property (weak) IBOutlet NSTextField *status;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (unsafe_unretained) IBOutlet NSTextView *responseTextPlain;
@property (weak) IBOutlet NSScrollView *responseTextPlainView;

// Saved Requests
@property (weak) IBOutlet CRCDrawerView *savedRequestsView;
@property (weak) IBOutlet NSOutlineView *savedOutlineView;
@property (weak) IBOutlet NSSplitView *verticalSplitView;
@property (weak) IBOutlet NSVisualEffectView *savedRequestsOuterView;
@property (weak) IBOutlet NSVisualEffectView *savedRequestsInnerView;
@property CGFloat lastSavedRequestsViewWidth;

// For modal dialogs
@property (weak) IBOutlet NSPanel *saveRequestSheet;
@property (weak) IBOutlet NSPanel *timeoutSheet;
@property (weak) IBOutlet NSTextField *timeoutField;

- (void) initHighlightedViews;
- (NSTouchBarItem *) touchBarButtonWithTitle:(NSString *)title color:(NSColor *)color identifier:(NSTouchBarItemIdentifier)identifier
                                      target:(id)target selector:(SEL)selector;

// Request Manipulation
- (void) setRequestText:(NSString *)request;
- (NSString *) getRequestText;
- (IBAction) doubleClickedHeaderRow:(id)sender;
- (IBAction) plusHeaderRow:(id)sender;
- (IBAction) minusHeaderRow:(id)sender;
- (void) doneEditingHeaderRow:(TableRowAndColumn *)tableRowAndColumn;
- (IBAction) clearAuth:(id)sender;
- (IBAction) doubleClickedFileRow:(id)sender;
- (IBAction) plusFileRow:(id)sender;
- (IBAction) minusFileRow:(id)sender;
- (void) addFileToFilesTable: (NSURL*) fileUrl;
- (IBAction) doubleClickedParamsRow:(id)sender;
- (IBAction) plusParamsRow:(id)sender;
- (IBAction) minusParamsRow:(id)sender;
- (void) doneEditingParamsRow:(TableRowAndColumn *)tableRowAndColumn;
- (void) selectRequestBodyInputMode;
- (IBAction)requestBodyInputMode:(id)sender;
- (void) contentTypeMenuItemSelected:(id)sender;
- (void)deleteTableRow:(NSNotification *)notification;
- (IBAction) plusUrlParamsRow:(id)sender;
- (IBAction) minusUrlParamsRow:(id)sender;
- (void) updateUrlFromParamsTable;
- (BOOL) updateParamsTableFromUrl;
- (void) urlBoxTextEdited:(NSNotification *)notification;
- (IBAction) doubleClickedUrlRow:(id)sender;
- (void) doneEditingUrlParamsRow:(TableRowAndColumn *)tableRowAndColumn;

// Request submission and Response Handling
- (IBAction) runSubmit:(id)sender;
- (void) runGetSubmit;
- (void) runPostSubmit;
- (void) runPutSubmit;
- (NSString *) getValueForHeader:(NSString *)headerName;
- (void) setResponseText:(NSString *)response;
- (NSString *) getResponseText;
- (void) prettyPrintJsonResponseFromObject:(id)obj;
- (void) prettyPrintJsonResponseFromString:(NSData*)jsonData;
- (void) printResponsePlain;
- (NSString *) substituteEnvVariables:(NSString *)stringTemplate;

// Saved request handling
- (void) loadSavedRequest:(id)request;
- (IBAction) createNewSavedFolder:(id)sender;
- (IBAction) deleteSavedRequestFromButton:(id) sender;
- (void)loadSavedCRCRequest:(CRCRequest *)request;
- (IBAction) outlineClick:(id)sender;
- (void)loadSavedDictionary:(NSDictionary *)request __deprecated;
- (void) adjustSavedRequestsViewWidth:(id)object;

// Handling preference updates
- (void)syntaxHighlightingPreferenceChanged;
- (void) applyShowLineNumbers:(BOOL)show;
- (void) darkModeChanged:(id) sender;

@end
