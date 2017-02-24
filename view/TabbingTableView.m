//
//  TabbingTableView.m
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 2/25/12.
//  Copyright (c) 2012 Michael Mattozzi. All rights reserved.
//

#import "TabbingTableView.h"
#import "TableRowAndColumn.h"

@implementation TabbingTableView

// Remember the key the user pressed to end the editing action
- (void) textDidEndEditing: (NSNotification *) notification {
    int editedColumn = [self editedColumn];
    int editedRow = [self editedRow];
    NSTableColumn *currentColumn = [[self tableColumns] objectAtIndex:editedColumn];
    NSDictionary *userInfo = [notification userInfo];
    lastTextMovement = [[userInfo valueForKey:@"NSTextMovement"] intValue];
    [super textDidEndEditing: notification];
    if (textDidEndEditingAction) {
        TableRowAndColumn *tableRowAndColumn = [[TableRowAndColumn alloc] init];
        tableRowAndColumn.column = currentColumn;
        tableRowAndColumn.row = editedRow;
        [[self delegate] performSelector:textDidEndEditingAction withObject:tableRowAndColumn];
    }
}

- (int) getLastTextMovement {
    return lastTextMovement;
}

- (void) setTextDidEndEditingAction: (SEL)action {
    textDidEndEditingAction = action;
}

- (void)keyDown:(NSEvent *)theEvent {
    // Backspace or delete key
    if ([theEvent keyCode] == 51 || [theEvent keyCode] == 117) {
        NSString *identifier = [self identifier];
        NSDictionary *payload = @{@"sender":self, @"identifier": identifier};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteTableRow"
                                                            object:theEvent userInfo:payload];
    } else {
        [super keyDown:theEvent];
    }
}

@end
