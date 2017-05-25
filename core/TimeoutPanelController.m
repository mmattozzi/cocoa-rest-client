//
//  TimeoutPanelController.m
//  CocoaRestClient
//
//  Created by Mike Mattozzi on 5/24/17.
//
//

#import "TimeoutPanelController.h"

@implementation TimeoutPanelController

@synthesize timeoutTextField;
@synthesize parent;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction) ok:(nullable id)sender {
    [parent endSheet:self.window returnCode:NSModalResponseOK];
}

- (IBAction) cancel:(nullable id)sender {
    [parent endSheet:self.window returnCode:NSModalResponseCancel];
}


@end
