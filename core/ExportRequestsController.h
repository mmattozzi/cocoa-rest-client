//
//  ExportRequestsDelegate.h
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 1/15/12.
//  Copyright (c) 2012 Michael Mattozzi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExportRequestsController : NSWindowController {
    NSMutableArray *savedRequestsArray;
    NSMutableArray *requestsTableModel;
    NSTableView *tableView;
    NSOutlineView *savedOutlineView;
    
    NSButton *importButton;
    NSButton *exportButton;
    NSButton *allButton;
    NSTextField *label;
    BOOL isExportsWindow;
}

@property (assign, atomic) NSMutableArray *savedRequestsArray;
@property (assign, atomic) NSOutlineView *savedOutlineView;

@property (assign) IBOutlet NSTableView *tableView;
@property (assign) IBOutlet NSButton *importButton;
@property (assign) IBOutlet NSButton *exportButton;
@property (assign) IBOutlet NSButton *allButton;
@property (assign) IBOutlet NSTextField *label;

- (void) prepareToDisplayExports;
- (void) prepareToDisplayImports:(NSArray *)importRequests;
- (IBAction) confirmExport:(id)sender;
- (IBAction) cancelExport:(id)sender;
- (IBAction) clickedAllCheckbox:(id)sender;
- (IBAction) confirmImport:(id)sender;

@end
