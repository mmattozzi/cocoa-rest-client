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
@synthesize tableView;
@synthesize importButton;
@synthesize exportButton;
@synthesize allButton;
@synthesize savedOutlineView;
@synthesize label;

- (id)initWithWindow:(NSWindow *)awindow {
    self = [super initWithWindow:awindow];
    if (self) {
        requestsTableModel = [[NSMutableArray alloc] init];
        isExportsWindow = YES;
    }
    
    return self;
}


- (void) setupWindow {
    if (isExportsWindow) {
        [importButton setHidden:YES];
        [exportButton setHidden:NO];
        [[self window] setTitle:@"Export Requests"];
        [label setStringValue:@"Select Requests to Export:"];
    } else {
        [importButton setHidden:NO];
        [exportButton setHidden:YES];
        [[self window] setTitle:@"Import Requests"];
        [label setStringValue:@"Select Requests to Import:"];
    }
    [allButton setState:NSOnState];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self setupWindow];
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
        
        NSMutableArray *requestsToExport = [[NSMutableArray alloc] init];
        for (id object in requestsTableModel) {
            CheckableRequestWrapper *req = (CheckableRequestWrapper *) object;
            if ([req enabled]) {
                [requestsToExport addObject:[req request]];
            }
        }
        
        if ([requestsToExport count] > 0) {
            [NSKeyedArchiver archiveRootObject:requestsToExport toFile:path];
        }
    }
    
    [NSApp endSheet:[self window]];
}

- (IBAction) confirmImport:(id)sender {
    NSLog(@"Pressed import");
    
    for (id object in requestsTableModel) {
        CheckableRequestWrapper *req = (CheckableRequestWrapper *) object;
        if ([req enabled]) {
            [savedRequestsArray addObject:[req request]];
        }
    }
    
    [savedOutlineView reloadItem:nil reloadChildren:YES];
    
    [NSApp endSheet:[self window]];
}

- (IBAction) cancelExport:(id)sender {
    [NSApp endSheet:[self window]];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [sheet orderOut:self];
}

- (void) prepareToDisplayExports {
    isExportsWindow = YES;
    [self setupWindow];
    
    [requestsTableModel removeAllObjects];
    
    for (id object in savedRequestsArray) {
        // Handle current request model
        if ([object isKindOfClass:[CRCRequest class]])
        {
            CRCRequest *crcRequest = (CRCRequest *) object;
            [requestsTableModel addObject:[[CheckableRequestWrapper alloc] initWithName:[crcRequest name] enabled:YES request:crcRequest]];
        }
        // Handle older version of requests
        else if([object isKindOfClass:[NSDictionary class]] )
        {
            [requestsTableModel addObject:[[CheckableRequestWrapper alloc] initWithName:[object objectForKey:@"name"] enabled:YES request:object]];
        }
        
    }
    
    [tableView reloadData];
}

- (void) prepareToDisplayImports:(NSArray *)importRequests {
    isExportsWindow = NO;
    [self setupWindow];
    
    [requestsTableModel removeAllObjects];
    
    for (id object in importRequests) {
        // Handle current request model
        if ([object isKindOfClass:[CRCRequest class]])
        {
            CRCRequest *crcRequest = (CRCRequest *) object;
            [requestsTableModel addObject:[[CheckableRequestWrapper alloc] initWithName:[crcRequest name] enabled:YES request:crcRequest]];
        }
        // Handle older version of requests
        else if([object isKindOfClass:[NSDictionary class]] )
        {
            [requestsTableModel addObject:[[CheckableRequestWrapper alloc] initWithName:[object objectForKey:@"name"] enabled:YES request:object]];
        }
        
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

- (IBAction) clickedAllCheckbox:(id)sender {
    if ([(NSButton *) sender state] == NSOnState) {
        for (id object in requestsTableModel) {
            CheckableRequestWrapper *req = (CheckableRequestWrapper *) object;
            [req setEnabled:YES];
        }
    } else {
        for (id object in requestsTableModel) {
            CheckableRequestWrapper *req = (CheckableRequestWrapper *) object;
            [req setEnabled:NO];
        }
    }
    
    [tableView reloadData];
}

@end
