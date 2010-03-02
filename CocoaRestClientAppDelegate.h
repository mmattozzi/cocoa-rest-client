//
//  CocoaRestClientAppDelegate.h
//  CocoaRestClient
//
//  Created by mmattozzi on 1/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

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
	
	NSTextField *username;
	NSTextField *password;
	
	NSMutableData *receivedData;
	NSString *contentType;
	
	NSMutableArray *headersTable;
	
	NSDrawer *savedRequestsDrawer;
	NSMutableArray *savedRequestsArray;
	NSOutlineView *savedOutlineView;
	
	NSPanel *saveRequestSheet;
	NSTextField *saveRequestTextField;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSComboBox *urlBox;
@property (assign) IBOutlet NSButton *submitButton;
@property (assign) IBOutlet NSTextView *responseText;
@property (assign) IBOutlet NSTextView *responseTextHeaders;
@property (assign) IBOutlet NSPopUpButton *methodButton;
@property (assign) IBOutlet NSTextView *requestText;
@property (assign) IBOutlet NSTableView *headersTableView;
@property (assign) IBOutlet NSTextField *username;
@property (assign) IBOutlet NSTextField *password;
@property (assign) IBOutlet NSOutlineView *savedOutlineView;
@property (assign) IBOutlet NSPanel *saveRequestSheet;
@property (assign) IBOutlet NSTextField *saveRequestTextField;
@property (assign) IBOutlet NSDrawer *savedRequestsDrawer;
@property (assign) IBOutlet NSTabViewItem *headersTab;

- (IBAction) runSubmit:(id)sender;
- (IBAction) plusHeaderRow:(id)sender;
- (IBAction) minusHeaderRow:(id)sender;
- (IBAction) clearAuth:(id)sender;
- (IBAction) outlineClick:(id)sender;
- (IBAction) saveRequest:(id) sender;
- (IBAction) doneSaveRequest:(id) sender;
- (void) loadSavedRequest:(NSDictionary *) request;
- (NSMutableDictionary *) saveCurrentRequestAsDictionary;
- (IBAction) deleteSavedRequest:(id) sender;
- (NSString *) pathForDataFile;
- (void) loadDataFromDisk;
- (void) saveDataToDisk;
- (void) applicationWillTerminate: (NSNotification *)note;

@end
