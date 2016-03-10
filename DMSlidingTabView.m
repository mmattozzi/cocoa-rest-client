//
//  DMSlidingTabView.m
//  DMSlidingTabView
//
//  Created by Diego Massanti on 3/9/16.
//  Copyright © 2016 Diego Massanti. All rights reserved.
//

#import "DMSlidingTabView.h"
#import <Quartz/Quartz.h>
@implementation DMSlidingTabView
@synthesize title;
- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeLayout];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initializeLayout];
    }
    return self;
}

- (void)initializeLayout {
    controlTitle = [[NSTextField alloc]init];
    controlTitle.editable = NO;
    controlTitle.font = [NSFont systemFontOfSize:18];
    controlTitle.textColor = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    controlTitle.bezeled = NO;
    controlTitle.drawsBackground = NO;
    controlTitle.selectable = NO;
    tabSelector = [[NSSegmentedControl alloc]init];
    tabViewItems = [NSMutableArray array];
    xConstraints = [NSArray array];
    [self addSubview:tabSelector];
    [self addSubview:controlTitle];
#if TARGET_INTERFACE_BUILDER
    tabSelector.segmentCount = 3;
    for (int i = 0; i < tabSelector.segmentCount; i++) {
        [tabSelector setLabel:@"Test Label" forSegment:i];
        //self.title = @"Test Title";
    }
    [self setupConstraints];
#else
    tabSelector.segmentCount = 0;
#endif
   
    [tabSelector setSegmentStyle:NSSegmentStyleTexturedRounded];
    tabSelector.selectedSegment = 0;
    self.selectedTabIndex = -1;
    tabSelector.translatesAutoresizingMaskIntoConstraints = NO;
    controlTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [tabSelector setTarget:self];
    [tabSelector setAction:@selector(selectedTabDidChange:)];
}



#pragma mark -- Items

- (void)addItem:(id<DMSlidingTabViewItem>)item {
    [tabViewItems addObject:item];
}

- (void)addItems:(NSArray*)items {
    [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addItem:obj];
    }];
    [self updateTabs];
}

- (void)updateTabs {
    tabSelector.segmentCount = tabViewItems.count;
    NSMutableArray *xPosCons = [NSMutableArray arrayWithCapacity:tabViewItems.count];
    [tabViewItems enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DMSlidingTabItemView *item = (DMSlidingTabItemView*)obj;
        [tabSelector setLabel:item.tabTitle forSegment:idx];
        item.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:item];
        NSLayoutConstraint *topSpace = [NSLayoutConstraint constraintWithItem:item
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:tabSelector
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1 constant:10];
        NSLayoutConstraint *bottomSpace = [NSLayoutConstraint constraintWithItem:item
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1 constant:0];
        NSLayoutConstraint *equalWidth = [NSLayoutConstraint constraintWithItem:item
                                                                      attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeWidth
                                                                     multiplier:1 constant:0];
        NSLayoutConstraint *leftSpace = [NSLayoutConstraint constraintWithItem:item
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1 constant:4000];
        [xPosCons addObject:leftSpace];
        item.xPosConstraint = leftSpace;
        item.hidden = YES;

        [self addConstraint:topSpace];
        [self addConstraint:bottomSpace];
        [self addConstraint:equalWidth];
        [self addConstraint:leftSpace];

    }];
    xConstraints = [NSArray arrayWithArray:xPosCons];
    tabSelector.selectedSegment = 0;
    [self selectedTabDidChange:tabSelector];
    
}

#pragma mark -- Segment Selection

- (void)selectedTabDidChange:(NSSegmentedControl*)sender {
    if (self.selectedTabIndex == sender.selectedSegment) return;
    DMSlidingTabItemView *itemToHide;
    if (self.selectedTabIndex > -1) {
        itemToHide = [tabViewItems objectAtIndex:self.selectedTabIndex];
    }
    float direction = self.selectedTabIndex > sender.selectedSegment ? self.bounds.size.width : -(self.bounds.size.width);
    DMSlidingTabItemView *itemToShow = [tabViewItems objectAtIndex:sender.selectedSegment];
    itemToShow.xPosConstraint.constant = sender.selectedSegment > self.selectedTabIndex ? self.frame.size.width : -(self.frame.size.width);
    itemToShow.hidden = NO;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0.1;
        context.allowsImplicitAnimation = YES;
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        itemToHide.xPosConstraint.animator.constant = direction;
        itemToShow.xPosConstraint.animator.constant = 0;
    } completionHandler:^{
        itemToHide.hidden = YES;
        
    }];
    self.selectedTabIndex = sender.selectedSegment;
    
    
    /*[tabViewItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DMSlidingTabItemView *item = (DMSlidingTabItemView*)obj;
        if ([tabViewItems indexOfObject:item] != sender.selectedSegment && [tabViewItems indexOfObject:item] == self.selectedTabIndex) {
            // Item has to dissapear
        }
        item.hidden = [tabViewItems indexOfObject:item] == sender.selectedSegment ? NO : YES;
    }];*/
}
- (void)setTitle:(NSString *)t {
    title = t;
    controlTitle.stringValue = title.uppercaseString;
}

- (NSString*)title {
    return title;
}

- (void)awakeFromNib {
    controlTitle.stringValue = self.title;
    [self setupConstraints];
}

- (void)setupConstraints {
    NSArray *constraints =
        [NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[tabSelector]->=10-[controlTitle(<=120)]-0-|"
                                                options:NSLayoutFormatAlignAllCenterY
                                                metrics:nil
                                                  views:@{@"tabSelector": tabSelector, @"controlTitle": controlTitle}
                            
                            
                            ];
    
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:tabSelector
                                               attribute:NSLayoutAttributeTop
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:self
                                               attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [NSLayoutConstraint activateConstraints:constraints];
    [self addConstraint:c2];
    [self invalidateIntrinsicContentSize];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSGraphicsContext currentContext] saveGraphicsState];
    [[NSColor colorWithRed:0 green:0 blue:0 alpha:0.1]set];

    NSBezierPath * dividerLine = [[NSBezierPath alloc]init];
    [dividerLine moveToPoint:NSMakePoint(0, self.bounds.size.height -27)];
    [dividerLine lineToPoint:NSMakePoint(self.bounds.size.width, self.bounds.size.height -27)];
    [dividerLine setLineWidth:0.5];
    [dividerLine stroke];
    [[NSGraphicsContext currentContext] restoreGraphicsState];
}

@end
