//
//  FastSearchSavedRequestsController.m
//  CocoaRestClient
//
//  Created by Mike Mattozzi on 12/29/16.
//
//

#import "FastSearchSavedRequestsController.h"
#import "CRCRequest.h"
#import "CRCSavedRequestFolder.h"
#import "SelectableSavedRequestWrapper.h"
#import "FastSearchSavedRequestTextCellView.h"

@interface FastSearchSavedRequestsController ()

@end

@implementation FastSearchSavedRequestsController

@synthesize fastSearchRequestsPanel;
@synthesize fastSearchRequestsTableView;
@synthesize fastSearchRequestsTextField;
@synthesize parent;
@synthesize selectedRequest;
@synthesize requestScrollView;

- (id)initWithWindow:(NSWindow *)awindow {
    self = [super initWithWindow:awindow];
    if (self) {
        requests = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [fastSearchRequestsTableView setAllowsTypeSelect:NO];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self setupWindow:nil];
}

- (void) setupWindow:(NSArray *)savedRequestsArray {
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
    [fastSearchRequestsTableView selectRowIndexes:indexSet byExtendingSelection:NO];

    [fastSearchRequestsTextField setStringValue:@""];
    
    if (savedRequestsArray) {
        baseRequests = savedRequestsArray;
        [self refreshRequestList];
        
        // Scroll the vertical scroller to top
        if ([requestScrollView hasVerticalScroller]) {
            requestScrollView.verticalScroller.floatValue = 0;
        }
        
        // Scroll the content back to the top
        [requestScrollView.contentView scrollToPoint:NSMakePoint(0, 0)];
    }
    
    [self.window makeFirstResponder:fastSearchRequestsTextField];
}

- (void) refreshRequestList {
    [requests removeAllObjects];
    [self addSavedRequests:nil path:@"/"];
    [self.fastSearchRequestsTableView reloadData];
}

- (void) addSavedRequests:(NSArray *)savedRequestsArray path:(NSString *)path {
    if (! savedRequestsArray) {
        savedRequestsArray = baseRequests;
    }
    NSString *currentSearchString = [fastSearchRequestsTextField stringValue];
    for (id req in savedRequestsArray) {
        if([req isKindOfClass:[CRCRequest class]]) {
            if (([currentSearchString length] == 0) || [[req name] rangeOfString:currentSearchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [requests addObject:[SelectableSavedRequestWrapper initWithRequest:req withPath:path]];
            }
        } else if ([req isKindOfClass:[CRCSavedRequestFolder class]]) {
            NSString* buildPath = [NSString stringWithFormat:@"%@%@/", path, [req name]];
            [self addSavedRequests:[((CRCSavedRequestFolder *) req) contents] path:buildPath];
        }
    }
}

- (void)cancelOperation:(nullable id)sender {
    [parent endSheet:self.window returnCode:NSModalResponseCancel];
}

- (void) pickedRow {
    SelectableSavedRequestWrapper *wrapper = [requests objectAtIndex:[fastSearchRequestsTableView selectedRow]];
    self.selectedRequest = wrapper.request;
    [parent endSheet:self.window returnCode:NSModalResponseOK];
}

- (void)keyDown:(NSEvent *)theEvent {
    NSLog(@"Got event with keycode: %hu", [theEvent keyCode]);
    if ([theEvent keyCode] == 36) {
        // Return
        [self pickedRow];
    } else if ([theEvent keyCode] == 51) {
        // Backspace
        NSString *val = [fastSearchRequestsTextField stringValue];
        [fastSearchRequestsTextField setStringValue:[val substringToIndex:([val length] - 1)]];
        [self.window makeFirstResponder:fastSearchRequestsTextField];
        [self deselectText];
        [self controlTextDidChange:[NSNotification notificationWithName:@"TextChanged" object:fastSearchRequestsTextField]];
    } else {
        // TODO: make backspace work
        NSString *characterTyped = [theEvent charactersIgnoringModifiers];
        [fastSearchRequestsTextField setStringValue:[NSString stringWithFormat:@"%@%@", [fastSearchRequestsTextField stringValue], characterTyped]];
        [self.window makeFirstResponder:fastSearchRequestsTextField];
        
        [fastSearchRequestsTextField performKeyEquivalent:theEvent];
        [self deselectText];
        [self controlTextDidChange:[NSNotification notificationWithName:@"TextChanged" object:fastSearchRequestsTextField]];
    }
}

- (IBAction)doubleClickOnTable:(id)sender {
    NSLog(@"Got double click");
    [self pickedRow];
}

- (void)sendDeleteKey {
    [fastSearchRequestsTextField setStringValue:[[fastSearchRequestsTextField stringValue] substringToIndex:[[fastSearchRequestsTextField stringValue] length] - 1]];
    [self.window makeFirstResponder:fastSearchRequestsTextField];
    [self deselectText];
}

- (void)deselectText {
    NSRange tRange = [[fastSearchRequestsTextField  currentEditor] selectedRange];
    [[fastSearchRequestsTextField  currentEditor] setSelectedRange:NSMakeRange(tRange.length,0)];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor
        doCommandBySelector:(SEL)commandSelector {
    if( commandSelector == @selector(moveUp:) ){
        if ([requests count] > 0) {
            [self.window makeFirstResponder:fastSearchRequestsTableView];
            return YES;
        }
    }
    if( commandSelector == @selector(moveDown:) ){
        if ([requests count] > 0) {
            [self.window makeFirstResponder:fastSearchRequestsTableView];
            return YES;
        }
    }
    
    return NO;
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    [self refreshRequestList];
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *) tableView {
    return [requests count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    FastSearchSavedRequestTextCellView *result = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    SelectableSavedRequestWrapper *wrapper = (SelectableSavedRequestWrapper *)[requests objectAtIndex:row];
    // result.imageView.image = item.itemIcon;
    result.textField.stringValue = wrapper.request.name;
    result.detailTextField.stringValue = wrapper.path;
    return result;
}

@end
