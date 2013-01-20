//
//  WelcomeController.m
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 8/5/12.
//  Copyright (c) 2012 Michael Mattozzi. All rights reserved.
//

#import "WelcomeController.h"

@implementation WelcomeController

@synthesize messageText;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    if ([messageText string] == nil || [[messageText string] isEqualToString:@""]) {
        [messageText setString:[NSString stringWithContentsOfFile:
            [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"motd.txt"] encoding:NSUTF8StringEncoding error:nil]];
        [messageText setFont:[NSFont fontWithName:@"Verdana" size:14.0]];
    }
}

@end
