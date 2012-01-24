//
//  CRCDrawerView.m
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 1/16/12.
//  Copyright (c) 2012 Michael Mattozzi. All rights reserved.
//

#import "CRCDrawerView.h"

@implementation CRCDrawerView

@synthesize cocoaRestClientAppDelegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    [super drawRect:dirtyRect];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        if (sourceDragMask & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        
        if (sourceDragMask & NSDragOperationCopy) {
            NSMutableArray *loadedRequests = [[NSMutableArray alloc] init];
            
            for (id file in files) {
                @try {
                    [loadedRequests addObjectsFromArray:[NSKeyedUnarchiver unarchiveObjectWithFile:file]];
                }
                @catch (NSException *exception) {
                    [cocoaRestClientAppDelegate invalidFileAlert];
                }
            }
            
            if ([loadedRequests count] > 0) {
                [cocoaRestClientAppDelegate importRequestsFromArray:loadedRequests];
            }
            
            return YES;
        }
    }
    
    return NO;
}

@end
