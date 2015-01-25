//
//  WelcomeController.h
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 8/5/12.
//  Copyright (c) 2012 Michael Mattozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WelcomeController : NSWindowController {
    NSTextView *messageText;
}

@property (strong) IBOutlet NSTextView *messageText;

@end
