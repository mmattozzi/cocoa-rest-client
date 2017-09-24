//
//  DiffWindowController.m
//  CocoaRestClient
//
//  Created by Mike Mattozzi on 9/14/17.
//
//

#import "DiffWindowController.h"
#import "MainWindowController.h"
#import "DiffMatchPatch.h"

#define DIFF_STYLE @"<style>span { font-family: monospace; } ins { color: green; } del { color: red; }</style>"

@implementation DiffWindowController

@synthesize diffSourceLeft;
@synthesize diffSourceRight;
@synthesize diffView;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    diffView.layer.borderColor = [NSColor grayColor].CGColor;
    diffView.layer.borderWidth = 1.0f;
}

- (void) setup:(NSArray<MainWindowController *> *)openWindows {
    NSLog(@"Setting up diff window");
    self.windows = openWindows;
    [diffSourceLeft removeAllItems];
    [diffSourceRight removeAllItems];
    for (MainWindowController* window in openWindows) {
        [diffSourceLeft addItemWithTitle:window.window.title];
        [diffSourceRight addItemWithTitle:window.window.title];
    }
    [self clearDiff:nil];
}

- (IBAction) clearDiff:(id)sender {
    [self.diffView loadHTMLString:@"" baseURL:nil];
}

- (IBAction) updateDiff:(id)sender {
    NSInteger leftIndex = [diffSourceLeft indexOfSelectedItem];
    NSInteger rightIndex = [diffSourceRight indexOfSelectedItem];
    NSString* leftIndexResponseText = [[self.windows objectAtIndex:leftIndex] getResponseText];
    if (! leftIndexResponseText) {
        [self.diffView loadHTMLString:@"Left index has no response text." baseURL:nil];
    } else {
        NSString* rightIndexResponseText = [[self.windows objectAtIndex:rightIndex] getResponseText];
        if (! rightIndexResponseText) {
            [self.diffView loadHTMLString:@"Right index has no response text." baseURL:nil];
        } else {
            NSArray *diffs = diff_diffsBetweenTextsWithOptions(leftIndexResponseText, rightIndexResponseText, YES, 0.0);
            NSString *htmlDiff = diff_prettyHTMLFromDiffs(diffs);
            [self.diffView loadHTMLString:[NSString stringWithFormat:@"%@%@", DIFF_STYLE, htmlDiff] baseURL:nil];
        }
    }
}

@end
