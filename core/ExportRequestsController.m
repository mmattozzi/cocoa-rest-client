//
//  ExportRequestsDelegate.m
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 1/15/12.
//  Copyright (c) 2012 Michael Mattozzi. All rights reserved.
//

#import "ExportRequestsController.h"
#import "CRCRequest.h"
#import "CRCSavedRequestFolder.h"
#import "CheckableRequestWrapper.h"

@implementation ExportRequestsController

@synthesize savedRequestsArray;
@synthesize tableView;
@synthesize importButton;
@synthesize exportButton;
@synthesize allButton;
@synthesize label;
@synthesize parent;

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
    
    NSSavePanel* picker = [NSSavePanel savePanel];
	
    if ([picker runModal] != NSModalResponseOK) return;

    NSString* path = [[picker URL] path];
    NSLog(@"Saving requests to %@", path);
    
    NSMutableArray *requestsToExport = [self selectedRequests];
    if ([requestsToExport count] > 0) {
        [NSKeyedArchiver archiveRootObject:requestsToExport toFile:path];
    }
    
    [parent endSheet:[self window] returnCode:NSModalResponseOK];
}

- (NSMutableArray *) selectedRequests {
    return [self buildRequestsFromWrappers:requestsTableModel];
}

- (NSMutableArray *) buildRequestsFromWrappers: (NSMutableArray *)wrappedRequests {
    NSMutableArray *requests = [[NSMutableArray alloc] init];
    
    for (CheckableRequestWrapper* wrappedRequest in wrappedRequests) {
        if ([wrappedRequest enabled] == NSOffState) continue;
        
        if ([[wrappedRequest request] isKindOfClass:[CRCSavedRequestFolder class]]) {
            // build new folder with only selected requests
            CRCSavedRequestFolder *request = [[CRCSavedRequestFolder alloc] init];
            request.name = [wrappedRequest name];
            request.contents = [self buildRequestsFromWrappers:[wrappedRequest contents]];
            [requests addObject:request];
        } else if ([wrappedRequest enabled] == NSOnState) {
            [requests addObject:[wrappedRequest request]];
        }
    }
    
    return requests;
}

- (IBAction) confirmImport:(id)sender {
    NSLog(@"Pressed import");
    
    for (id request in [self selectedRequests]) {
        [savedRequestsArray addObject:request];
    }
    
    [parent endSheet:[self window] returnCode:NSModalResponseOK];
}

- (IBAction) cancelExport:(id)sender {
    [parent endSheet:[self window] returnCode:NSModalResponseCancel];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [sheet orderOut:self];
}

- (void) prepareToDisplayExports {
    isExportsWindow = YES;
    [self setupWindow];
    
    [requestsTableModel removeAllObjects];
    
    for (id object in savedRequestsArray) {
        [requestsTableModel addObject:[CheckableRequestWrapper checkableRequestWrapperForRequest:object]];
    }
    
    [tableView reloadData];
}

- (void) prepareToDisplayImports:(NSArray *)importRequests {
    isExportsWindow = NO;
    [self setupWindow];
    
    [requestsTableModel removeAllObjects];
    
    for (id object in importRequests) {
        [requestsTableModel addObject:[CheckableRequestWrapper checkableRequestWrapperForRequest:object]];
    }
    
    [tableView reloadData];
}

- (IBAction) clickedAllCheckbox:(id)sender {
    if ([allButton state] == NSMixedState) {
        [allButton setNextState];
    }
    
    if ([allButton state] == NSOnState) {
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

- (void) updateAllCheckbox {
    int checkedRequests = 0;
    for (CheckableRequestWrapper* requestWrapper in requestsTableModel) {
        if ([requestWrapper enabled] == NSMixedState) {
            [allButton setState:NSMixedState];
            return;
        }
        
        if ([requestWrapper enabled] != NSOffState) checkedRequests++;
    }
    
    if (checkedRequests == [requestsTableModel count]) {
        [allButton setState: NSOnState];
    } else if (checkedRequests == 0) {
        [allButton setState: NSOffState];
    } else {
        [allButton setState: NSMixedState];
    }
}

#pragma mark Outline view methods
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
    if (item != nil) {
        CheckableRequestWrapper *requestWrapper = (CheckableRequestWrapper*) item;
        return [requestWrapper count];
    }
    
    return [requestsTableModel count];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
    if (item != nil) {
        CheckableRequestWrapper *requestWrapper = (CheckableRequestWrapper*) item;
        return [[requestWrapper contents] objectAtIndex:index];
    }
    
    return [requestsTableModel objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    CheckableRequestWrapper *requestWrapper = (CheckableRequestWrapper*) item;
    return [requestWrapper count] > 0;
}

- (nullable id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn byItem:(nullable id)item {
    CheckableRequestWrapper *requestWrapper = (CheckableRequestWrapper*) item;
    return [NSNumber numberWithInt:[requestWrapper enabled]];
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    [cell setTitle: [item name]];
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    [item setEnabled: [object boolValue]];
    [tableView reloadData];
    [self updateAllCheckbox];
}

@end
