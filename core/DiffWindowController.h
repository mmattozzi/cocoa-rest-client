//
//  DiffWindowController.h
//  CocoaRestClient
//
//  Created by Mike Mattozzi on 9/14/17.
//
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface DiffWindowController : NSWindowController

@property (weak) IBOutlet NSPopUpButton *diffSourceLeft;
@property (weak) IBOutlet NSPopUpButton *diffSourceRight;
@property (weak) IBOutlet WKWebView *diffView;

- (IBAction) updateDiff:(id)sender;

@end
