//
//  DiffWindowController.m
//  CocoaRestClient
//
//  Created by Mike Mattozzi on 9/14/17.
//
//

#import "DiffWindowController.h"
#import "MainWindowController.h"

@implementation DiffWindowController

@synthesize diffSourceLeft;
@synthesize diffSourceRight;
@synthesize diffView;

- (void) setup:(NSArray<MainWindowController *> *)openWindows {
    NSLog(@"Setting up diff window");
    self.windows = openWindows;
    [diffSourceLeft removeAllItems];
    [diffSourceRight removeAllItems];
    NSInteger index = 1;
    for (MainWindowController* window in openWindows) {
        [diffSourceLeft addItemWithTitle:[NSString stringWithFormat:@"%ld: %@", (long)index, window.window.title]];
        [diffSourceRight addItemWithTitle:[NSString stringWithFormat:@"%ld: %@", (long)index, window.window.title]];
        index++;
    }
}

- (IBAction) updateDiff:(id)sender {
    
}

@end
