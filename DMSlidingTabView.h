//
//  DMSlidingTabView.h
//  DMSlidingTabView
//
//  Created by Diego Massanti on 3/9/16.
//  Copyright © 2016 Diego Massanti. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DMSlidingTabViewItemProtocol.h"
#import "DMSlidingTabItemView.h"

IB_DESIGNABLE
@interface DMSlidingTabView : NSView {
    NSSegmentedControl              *tabSelector;
    NSMutableArray                  *tabViewItems;
    NSUInteger                      selectedTabIdx;
    NSArray                         *xConstraints;
}

@property NSInteger                selectedTabIndex;

- (void)addItem:(id<DMSlidingTabViewItem>)item;
- (void)addItems:(NSArray*)items;

@end
