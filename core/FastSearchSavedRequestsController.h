//
//  FastSearchSavedRequestsController.h
//  CocoaRestClient
//
//  Created by Mike Mattozzi on 12/29/16.
//
//

#import <Cocoa/Cocoa.h>

@interface FastSearchSavedRequestsController : NSWindowController <NSTableViewDelegate, NSTableViewDataSource> {
    NSWindow *parent;
    NSMutableArray *requests;
    NSArray *baseRequests;
}

@property (weak) IBOutlet NSTableView *fastSearchRequestsTableView;
@property (weak) IBOutlet NSTextField *fastSearchRequestsTextField;
@property (weak) IBOutlet NSPanel *fastSearchRequestsPanel;
@property (strong) NSWindow *parent;
@property (strong) id selectedRequest;

- (void) setupWindow:(NSArray *)requests;
- (void) sendDeleteKey;

@end
