//
//  TabbingTableView.h
//  CocoaRestClient
//
//  This is a subclass of NSTableView that remembers the last text movement keypress 
//  after a value is edited. This allows the TableView to keep track of whether the edit
//  ended with the return key, the tab key, or some other key.
//
//  Created by Michael Mattozzi on 2/25/12.
//  Copyright (c) 2012 Michael Mattozzi. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface TabbingTableView : NSTableView {
    int lastTextMovement;
    SEL textDidEndEditingAction;
}

- (int) getLastTextMovement;
- (void) setTextDidEndEditingAction: (SEL)action;

@end
