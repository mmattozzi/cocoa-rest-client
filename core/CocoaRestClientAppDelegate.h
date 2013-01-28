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
#import "HighlightedTextView.h"
#import "WelcomeController.h"

extern NSString* const FOLLOW_REDIRECTS;
extern NSString* const RESPONSE_TIMEOUT;

@class CRCRequest;
@class CRCDrawerView;

@interface CocoaRestClientAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	
	NSComboBox *urlBox;
	NSButton *submitButton;
	NSTextView *requestText;
	NSTextView *responseText;
    WebView *responseWebView;
    NSTextView *requestHeadersSentText;
	NSTabViewItem *headersTab;
	NSTextView *responseTextHeaders;
	NSPopUpButton *methodButton;
	TabbingTableView *headersTableView;
	TabbingTableView *filesTableView;
	TabbingTableView *paramsTableView;
    HighlightedTextView *responseView;
    HighlightedTextView *requestView;
	
    NSTextView *requestTextPlain;
    NSTextView *responseTextPlain;
    NSScrollView *responseTextPlainView;
    NSScrollView *requestTextPlainView;
    
	NSTextField *username;
	NSTextField *password;
	
	NSMutableData *receivedData;
	NSString *contentType;
    NSString *charset;
	
	NSMutableArray *headersTable;
	NSMutableArray *filesTable;
	NSMutableArray *paramsTable;
	
	NSDrawer *savedRequestsDrawer;
	NSMutableArray *savedRequestsArray;
	NSOutlineView *savedOutlineView;
	
	NSPanel *saveRequestSheet;
	NSTextField *saveRequestTextField;
	
	NSPanel *timeoutSheet;
	NSTextField *timeoutField;
	
	ExportRequestsController *exportRequestsController;
    
    BOOL allowSelfSignedCerts;
    NSURLRequest *currentRequest;
    
	NSButton *plusParam;
	NSButton *minusParam;
	BOOL rawRequestInput;
	NSTabView *tabView;
	NSTabViewItem *reqHeadersTab;
	NSDate *startDate;
	NSTextField *status;
    NSProgressIndicator *progressIndicator;
    
    CRCDrawerView *drawerView;
    PreferencesController *preferencesController;
    WelcomeController *welcomeController;
    
    NSMenuItem *syntaxHighlightingMenuItem;
    NSMenuItem *reGetResponseMenuItem;
    
    @private CRCRequest *lastRequest;
    
    @private NSSet *requestMethodsWithBody;
    
    @private NSArray *xmlContentTypes;    
    @private NSArray *jsonContentTypes;
	
}



@property (nonatomic, readonly) NSMutableArray *headersTable;
@property (nonatomic, readonly) NSMutableArray *filesTable;
@property (nonatomic, readonly) NSMutableArray *paramsTable;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSComboBox *urlBox;
@property (assign) IBOutlet NSButton *submitButton;
@property (assign) IBOutlet NSTextView *responseText;

@property (assign) IBOutlet WebView *responseWebView;
@property (assign) IBOutlet HighlightedTextView *responseView;
@property (assign) IBOutlet HighlightedTextView *requestView;
@property (assign) IBOutlet NSTextView *responseTextHeaders;
@property (assign) IBOutlet NSPopUpButton *methodButton;
@property (assign) IBOutlet NSTextView *requestText;
@property (assign) IBOutlet TabbingTableView *headersTableView;
@property (assign) IBOutlet TabbingTableView *filesTableView;
@property (assign) IBOutlet TabbingTableView *paramsTableView;
@property (assign) IBOutlet NSTextField *username;
@property (assign) IBOutlet NSTextField *password;
@property (assign) IBOutlet NSOutlineView *savedOutlineView;
@property (assign) IBOutlet NSPanel *saveRequestSheet;
@property (assign) IBOutlet NSTextField *saveRequestTextField;
@property (assign) IBOutlet NSDrawer *savedRequestsDrawer;
@property (assign) IBOutlet NSTabViewItem *headersTab;
@property (assign) IBOutlet NSPanel *timeoutSheet;
@property (assign) IBOutlet NSTextField *timeoutField;
@property (assign) IBOutlet NSButton *plusParam;
@property (assign) IBOutlet NSButton *minusParam;
@property (assign) BOOL rawRequestInput;
@property (assign) IBOutlet NSTabView *tabView;
@property (assign) IBOutlet NSTabViewItem *reqHeadersTab;
@property (assign) IBOutlet NSTextField *status;
@property (assign) IBOutlet NSTextView *requestHeadersSentText;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (assign) IBOutlet CRCDrawerView *drawerView;
@property (retain) PreferencesController *preferencesController;
@property (assign) IBOutlet NSTextView *requestTextPlain;
@property (assign) IBOutlet NSTextView *responseTextPlain;
@property (assign) IBOutlet NSScrollView *responseTextPlainView;
@property (assign) IBOutlet NSScrollView *requestTextPlainView;
@property (assign) IBOutlet NSMenuItem *syntaxHighlightingMenuItem;
@property (assign) IBOutlet NSMenuItem *reGetResponseMenuItem;
@property (retain) WelcomeController *welcomeController;

- (IBAction) runSubmit:(id)sender;
- (IBAction) doubleClickedHeaderRow:(id)sender;
- (IBAction) plusHeaderRow:(id)sender;
- (IBAction) minusHeaderRow:(id)sender;
- (IBAction) clearAuth:(id)sender;
- (IBAction) outlineClick:(id)sender;
- (IBAction) saveRequest:(id) sender;
- (IBAction) overwriteRequest:(id) sender;
- (IBAction) doneSaveRequest:(id) sender;
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
- (IBAction) doubleClickedParamsRow:(id)sender;
- (IBAction) plusParamsRow:(id)sender;
- (IBAction) minusParamsRow:(id)sender;
- (IBAction) contentTypeMenuItemSelected:(id)sender;
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
- (void) showWelcome;

- (void)setRawRequestInput:(BOOL)value;

- (void) initHighlightedViews;
- (void) setHighlightSyntaxForMIME:(NSString*) mimeType;

@end
