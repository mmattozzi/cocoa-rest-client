//
//  ExportRequestsDelegate.h
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 1/15/12.
//  Copyright (c) 2012 Michael Mattozzi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExportRequestsController : NSWindowController <NSOutlineViewDataSource, NSOutlineViewDelegate> {
    NSMutableArray *savedRequestsArray;
    NSMutableArray *requestsTableModel;
    NSTableView *tableView;
    
    NSButton *importButton;
    NSButton *exportButton;
    NSButton *allButton;
    NSTextField *label;
    BOOL isExportsWindow;
}

@property (strong, atomic) NSMutableArray *savedRequestsArray;
@property (weak, nullable) IBOutlet NSWindow *parent;

@property (strong) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSButton *importButton;
@property (strong) IBOutlet NSButton *exportButton;
@property (strong) IBOutlet NSButton *allButton;
@property (strong) IBOutlet NSTextField *label;

- (void) prepareToDisplayExports;
- (void) prepareToDisplayImports:(NSArray *)importRequests;
- (IBAction) confirmExport:(id)sender;
- (IBAction) cancelExport:(id)sender;
- (IBAction) clickedAllCheckbox:(id)sender;
- (IBAction) confirmImport:(id)sender;

@end
