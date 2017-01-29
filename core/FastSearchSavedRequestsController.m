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

@interface FastSearchSavedRequestsController ()

@end

@implementation FastSearchSavedRequestsController

@synthesize fastSearchRequestsPanel;
@synthesize fastSearchRequestsTableView;
@synthesize fastSearchRequestsTextField;
@synthesize parent;
@synthesize selectedRequest;

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

    if (savedRequestsArray) {
        baseRequests = savedRequestsArray;
        [self refreshRequestList];
    }
}

- (void) refreshRequestList {
    [requests removeAllObjects];
    [self addSavedRequests:nil];
    [self.fastSearchRequestsTableView reloadData];
}

- (void) addSavedRequests:(NSArray *)savedRequestsArray {
    if (! savedRequestsArray) {
        savedRequestsArray = baseRequests;
    }
    NSString *currentSearchString = [fastSearchRequestsTextField stringValue];
    for (id req in savedRequestsArray) {
        if([req isKindOfClass:[CRCRequest class]]) {
            if ([currentSearchString length] == 0 || [[req name] containsString:currentSearchString]) {
                [requests addObject:req];
            }
        } else if ([req isKindOfClass:[CRCSavedRequestFolder class]]) {
            if ([currentSearchString length] == 0 || [[req name] containsString:currentSearchString]) {
                [self addSavedRequests:[((CRCSavedRequestFolder *) req) contents]];
            }
        }
    }
}

- (void)cancelOperation:(nullable id)sender {
    NSLog(@"Closing because I got cancelOperation");
    [parent endSheet:self.window returnCode:NSModalResponseCancel];
}

- (void)keyDown:(NSEvent *)theEvent {
    NSLog(@"Got event with keycode: %hu", [theEvent keyCode]);
    if ([theEvent keyCode] == 36) {
        self.selectedRequest = [requests objectAtIndex:[fastSearchRequestsTableView selectedRow]];
        [parent endSheet:self.window returnCode:NSModalResponseOK];
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
        // Your increment code
        NSLog(@"Pressed up");
        [self.window makeFirstResponder:fastSearchRequestsTableView];
        return YES;
    }
    if( commandSelector == @selector(moveDown:) ){
        // Your decrement code
        NSLog(@"Press down");
        [self.window makeFirstResponder:fastSearchRequestsTableView];
        return YES;
    }
    
    return NO;
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    NSLog(@"controlTextDidChange: stringValue == %@", [textField stringValue]);
    [self refreshRequestList];
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *) tableView {
    return [requests count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    CRCRequest *req = (CRCRequest *)[requests objectAtIndex:row];
    return [req name];
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    
}

@end
