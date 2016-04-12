//
//  DMSlidingTabItemView.h
//  DMSlidingTabView
//
//  Created by Diego Massanti on 3/9/16.
//  Copyright © 2016 Diego Massanti. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DMSlidingTabViewItemProtocol.h"

@interface DMSlidingTabItemView : NSView<DMSlidingTabViewItem>

@property (nonatomic) IBInspectable NSString        *tabTitle;
@property NSLayoutConstraint                        *xPosConstraint;
@property NSUInteger                                indexInTabSelector;
@property NSSegmentedControl                        *parentTabSelector;

@end
