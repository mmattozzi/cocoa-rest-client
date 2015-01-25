//
//  CRCDrawerView.h
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 1/16/12.
//  Copyright (c) 2012 Michael Mattozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CocoaRestClientAppDelegate.h"

@class CocoaRestClientAppDelegate;

@interface CRCDrawerView : NSView {
    CocoaRestClientAppDelegate *cocoaRestClientAppDelegate;
}

@property (strong, atomic) CocoaRestClientAppDelegate *cocoaRestClientAppDelegate;

@end
