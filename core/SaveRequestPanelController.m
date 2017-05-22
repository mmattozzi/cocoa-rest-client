//
//  SaveRequestPanelController.m
//  CocoaRestClient
//
//  Created by Mike Mattozzi on 5/21/17.
//
//

#import "SaveRequestPanelController.h"

@implementation SaveRequestPanelController

@synthesize saveRequestTextField;
@synthesize parent;

- (IBAction) save:(nullable id)sender {
    [parent endSheet:self.window returnCode:NSModalResponseOK];
}

- (IBAction) cancel:(nullable id)sender {
    [parent endSheet:self.window returnCode:NSModalResponseCancel];
}

@end
