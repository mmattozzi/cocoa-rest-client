//
//  ACEView+TouchBarExtension.m
//  CocoaRestClient
//
//  Created by Mike Mattozzi on 3/26/18.
//

#import "ACEView+TouchBarExtension.h"

@implementation ACEWebView (ACEViewTouchBarExtension)

- (NSTouchBar *) makeTouchBar {
    NSWindow *window = [self window];
    NSTouchBar *touchBar = [[window windowController] makeTouchBar];
    return touchBar;
}

@end
