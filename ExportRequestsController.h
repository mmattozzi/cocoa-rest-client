//
//  ExportRequestsDelegate.h
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 1/15/12.
//  Copyright (c) 2012 Michael Mattozzi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExportRequestsController : NSWindowController {
    NSArray *savedRequestsArray;
    NSMutableArray *requestsTableModel;
    NSTableView *tableView;
}

@property (assign, atomic) NSArray *savedRequestsArray;
@property (assign) IBOutlet NSTableView *tableView;

- (void) prepareToDisplay;
- (IBAction) confirmExport:(id)sender;
- (IBAction) cancelExport:(id)sender;
- (IBAction) clickedAllCheckbox:(id)sender;

@end
