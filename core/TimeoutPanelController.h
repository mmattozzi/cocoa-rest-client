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
}

@property (strong, nonnull) IBOutlet NSTextField *timeoutTextField;
@property (weak) IBOutlet NSWindow *parent;

- (IBAction) ok:(nullable id)sender;
- (IBAction) cancel:(nullable id)sender;


@end
