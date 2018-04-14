//
//  NSTextView+TouchBarExtension.m
//  CocoaRestClient
//
//  Created by Mike Mattozzi on 3/26/18.
//

#import "NSTextView+TouchBarExtension.h"

@implementation NSTextView (TouchBarExtension)

- (NSTouchBar *) makeTouchBar {
    NSWindow *window = [self window];
    NSTouchBar *touchBar = [window makeTouchBar];
    return touchBar;
}

@end
