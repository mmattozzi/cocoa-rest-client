//
//  TabbingTableView.m
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 2/25/12.
//  Copyright (c) 2012 Michael Mattozzi. All rights reserved.
//

#import "TabbingTableView.h"

@implementation TabbingTableView

// Remember the key the user pressed to end the editing action
- (void) textDidEndEditing: (NSNotification *) notification {
    NSDictionary *userInfo = [notification userInfo];
    lastTextMovement = [[userInfo valueForKey:@"NSTextMovement"] intValue];
    [super textDidEndEditing: notification];
}

- (int) getLastTextMovement {
    return lastTextMovement;
}

@end
