//
//  TimeoutPanelController.h
//  CocoaRestClient
//
//  Created by Mike Mattozzi on 5/24/17.
//
//

#import <Cocoa/Cocoa.h>

@interface TimeoutPanelController : NSWindowController {
    NSTextField *timeoutTextField;
    NSWindow *parent;
}

@property (strong) IBOutlet NSTextField *timeoutTextField;
@property (strong) IBOutlet NSWindow *parent;

- (IBAction) ok:(nullable id)sender;
- (IBAction) cancel:(nullable id)sender;


@end
