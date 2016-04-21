//
//  DMSlidingTabItemView.m
//  DMSlidingTabView
//
//  Created by Diego Massanti on 3/9/16.
//  Copyright © 2016 Diego Massanti. All rights reserved.
//

#import "DMSlidingTabItemView.h"

@implementation DMSlidingTabItemView

/*- (BOOL)wantsLayer {
    return YES;
}*/

@synthesize tabTitle = _tabTitle;
@synthesize indexInTabSelector;
@synthesize parentTabSelector;

- (void) setTabTitle:(NSString *)aTabTitle {
    if (aTabTitle) {
        _tabTitle = aTabTitle;
        [parentTabSelector setLabel:_tabTitle forSegment:indexInTabSelector];
    }
}

- (NSString *) getTabTitle {
    return _tabTitle;
}

@end
