//
//  CocoaRestClientAppDelegate.h
//  CocoaRestClient
//
//  Created by mmattozzi on 1/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CRCRequest;

@interface CocoaRestClientAppDelegate : NSObject {
    NSWindow *window;
	
	NSComboBox *urlBox;
	NSButton *submitButton;
	NSTextView *requestText;
	NSTextView *responseText;
	NSTabViewItem *headersTab;
	NSTextView *responseTextHeaders;
	NSPopUpButton *methodButton;
	NSTableView *headersTableView;
	NSTableView *filesTableView;
	NSTableView *paramsTableView;
	
	NSTextField *username;
	NSTextField *password;
	
	NSMutableData *receivedData;
	NSString *contentType;
	
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
	
	NSInteger timeout;
	
	NSButton *plusParam;
	NSButton *minusParam;
	BOOL rawRequestInput;
	NSTabView *tabView;
	NSTabViewItem *reqHeadersTab;
	NSDate *startDate;
	NSTextField *status;
    
    @private 
    CRCRequest *lastRequest;
	
}



@property (nonatomic, readonly) NSMutableArray *headersTable;
@property (nonatomic, readonly) NSMutableArray *filesTable;
@property (nonatomic, readonly) NSMutableArray *paramsTable;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSComboBox *urlBox;
@property (assign) IBOutlet NSButton *submitButton;
@property (assign) IBOutlet NSTextView *responseText;
@property (assign) IBOutlet NSTextView *responseTextHeaders;
@property (assign) IBOutlet NSPopUpButton *methodButton;
@property (assign) IBOutlet NSTextView *requestText;
@property (assign) IBOutlet NSTableView *headersTableView;
@property (assign) IBOutlet NSTableView *filesTableView;
@property (assign) IBOutlet NSTableView *paramsTableView;
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

- (IBAction) runSubmit:(id)sender;
- (IBAction) plusHeaderRow:(id)sender;
- (IBAction) minusHeaderRow:(id)sender;
- (IBAction) clearAuth:(id)sender;
- (IBAction) outlineClick:(id)sender;
- (IBAction) saveRequest:(id) sender;
- (IBAction) doneSaveRequest:(id) sender;
- (void) loadSavedRequest:(NSDictionary *) request;
- (IBAction) deleteSavedRequest:(id) sender;
- (NSString *) pathForDataFile;
- (void) loadDataFromDisk;
- (void) saveDataToDisk;
- (void) applicationWillTerminate: (NSNotification *)note;
- (IBAction) openTimeoutDialog:(id) sender;
- (IBAction) closeTimoutDialog:(id) sender;
- (IBAction) plusFileRow:(id)sender;
- (IBAction) minusFileRow:(id)sender;
- (IBAction) plusParamsRow:(id)sender;
- (IBAction) minusParamsRow:(id)sender;
- (IBAction) contentTypeMenuItemSelected:(id)sender;
- (IBAction) handleOpenWindow:(id)sender;
- (BOOL)validateMenuItem:(NSMenuItem *)item;
- (IBAction) helpInfo:(id)sender;
- (IBAction) reloadLastRequest:(id)sender;

- (void)setRawRequestInput:(BOOL)value;

@end
