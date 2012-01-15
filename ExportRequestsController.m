//
//  ExportRequestsDelegate.m
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 1/15/12.
//  Copyright (c) 2012 Michael Mattozzi. All rights reserved.
//

#import "ExportRequestsController.h"
#import "CRCRequest.h"
#import "CheckableRequestWrapper.h"

@implementation ExportRequestsController

@synthesize savedRequestsArray;

- (id)initWithWindow:(NSWindow *)awindow {
    self = [super initWithWindow:awindow];
    if (self) {
        requestsTableModel = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction) confirmExport:(id)sender {
    NSLog(@"Pressed export");
    
    NSLog(@"Saved request array = %@", savedRequestsArray);
    for (id object in savedRequestsArray) {
        NSLog(@"Request = %@", object);
    }
    
    NSSavePanel* picker = [NSSavePanel savePanel];
	
    if ( [picker runModal] == NSOKButton ) {
		NSString* path = [picker filename];
        NSLog(@"Saving requests to %@", path);
    }
    
    [NSApp endSheet:[self window]];
}

- (IBAction) cancelExport:(id)sender {
    [NSApp endSheet:[self window]];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [sheet orderOut:self];
}

- (void) prepareToDisplay {
    [requestsTableModel removeAllObjects];
    
    for (id object in savedRequestsArray) {
        CRCRequest *crcRequest = (CRCRequest *) object;
        [requestsTableModel addObject:[[CheckableRequestWrapper alloc] initWithName:[crcRequest name] enabled:YES request:crcRequest]];
    }
    
    [tableView reloadData];
}

#pragma mark Table view methods
- (NSInteger) numberOfRowsInTableView:(NSTableView *) tableView {
	NSLog(@"Calling number rows");
	
    return [requestsTableModel count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	id object;
	
	if ([(NSString *) [tableColumn identifier] isEqualToString:@"CheckboxColumn"]) {
        BOOL value = [(CheckableRequestWrapper *) [requestsTableModel objectAtIndex:row] enabled];
        return [NSNumber numberWithInteger:(value ? NSOnState : NSOffState)];
    }
	
	return object;
}

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    id object = nil;
    
    if ([(NSString *) [tableColumn identifier] isEqualToString:@"CheckboxColumn"]) {
        return [(CheckableRequestWrapper *) [requestsTableModel objectAtIndex:row] cell];
    }
    
    return object;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)value forTableColumn:(NSTableColumn *)column row:(NSInteger)row {
    NSLog(@"Calling setObjectValue with value: %@", value);
    
    [(CheckableRequestWrapper *) [requestsTableModel objectAtIndex:row] setEnabled:[value boolValue]];
}

@end
