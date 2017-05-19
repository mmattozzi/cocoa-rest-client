//
//  SavedRequestsDataSource.m
//  CocoaRestClient
//
//  Created by Mike Mattozzi on 5/17/17.
//
//

#import "SavedRequestsDataSource.h"
#import "CRCSavedRequestFolder.h"
#import "CRCRequest.h"
#import "CRCConstants.h"
#import "CocoaRestClientAppDelegate.h"

@implementation SavedRequestsDataSource

static NSMutableArray* _savedRequestsArray = nil;

+ (NSMutableArray *) savedRequestsArray {
    return _savedRequestsArray;
}

+ (void) setSavedRequestsArray:(NSMutableArray *)array {
    _savedRequestsArray = array;
}

- (id) init {
    self = [super init];
    
    appDelegate = (CocoaRestClientAppDelegate *)[NSApp delegate];
    
    return self;
}

- (NSInteger) outlineView: (NSOutlineView *)outlineView numberOfChildrenOfItem: (id)item {
    if (item == nil) {
        return [SavedRequestsDataSource.savedRequestsArray count];
    } else {
        return [item count];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if (item == nil) return NO;
    return [item isKindOfClass:[CRCSavedRequestFolder class]];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil) {
        return [SavedRequestsDataSource.savedRequestsArray objectAtIndex:index];
    } else {
        return [item objectAtIndex:index];
    }
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if ([item isKindOfClass:[CRCRequest class]])
    {
        CRCRequest * req = (CRCRequest *)item;
        return req.name;
    }
    else if ([item isKindOfClass:[CRCSavedRequestFolder class]])
    {
        return ((CRCSavedRequestFolder *)item).name;
    }
    else if (item == SavedRequestsDataSource.savedRequestsArray) {
        return SavedRequestsDataSource.savedRequestsArray;
    }
    
    return nil;
}

- (void) outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if ([item isKindOfClass:[CRCRequest class]]) {
        CRCRequest * req = (CRCRequest *)item;
        req.name = object;
    }
    else if ([item isKindOfClass:[CRCSavedRequestFolder class]]) {
        ((CRCSavedRequestFolder *)item).name = object;
    }
}

#pragma mark OutlineView drag and drop methods
- (id <NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView pasteboardWriterForItem:(id)item{
    // No dragging if <some condition isn't met>
    BOOL dragAllowed = YES;
    if (!dragAllowed)  {
        return nil;
    }
    
    NSPasteboardItem *pboardItem = [[NSPasteboardItem alloc] init];
    NSString *idStr = [NSString stringWithFormat:@"%ld", (long) item];
    [pboardItem setString:idStr forType: @"public.text"];
    NSLog(@"%@", idStr);
    
    return pboardItem;
}


- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id < NSDraggingInfo >)info proposedItem:(id)targetItem proposedChildIndex:(NSInteger)index{
    
    if (index >= 0) {
        return NSDragOperationMove;
    } else {
        return NSDragOperationNone;
    }
}


- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id < NSDraggingInfo >)info item:(id)targetItem childIndex:(NSInteger)targetIndex{
    
    NSPasteboard *p = [info draggingPasteboard];
    NSString *objId = [p stringForType:@"public.text"];
    NSLog(@"Pasteboad item = %@", objId);
    
    id sourceItem = nil;
    CRCSavedRequestFolder *sourceParentFolder = nil;
    int sourceIndex = -1;
    
    for (id entry in SavedRequestsDataSource.savedRequestsArray) {
        if ([[NSString stringWithFormat:@"%ld", (long) entry] isEqualToString:objId]) {
            sourceItem = entry;
            sourceIndex = [SavedRequestsDataSource.savedRequestsArray indexOfObject:sourceItem];
        } else if ([entry isKindOfClass:[CRCSavedRequestFolder class]]) {
            id recursiveParent = [((CRCSavedRequestFolder *)entry) findParentOfObjectWith:objId];
            if (recursiveParent) {
                sourceParentFolder = recursiveParent;
                sourceItem = [((CRCSavedRequestFolder *)sourceParentFolder) findObjectWith:objId];
                sourceIndex = [((CRCSavedRequestFolder *)sourceParentFolder) findIndexOfObject:sourceItem];
            }
        }
    }
    
    // Unclear how this would happen, but we don't know what we are moving
    if (! sourceItem) {
        NSLog(@"Unable to find source item dropped into list");
        return NO;
    }
    
    if (sourceIndex == -1) {
        NSLog(@"Unable to find index of moving item");
        return NO;
    }
    
    if (targetItem == sourceItem) {
        return NO;
    }
    
    if (sourceParentFolder) {
        [((CRCSavedRequestFolder *) sourceParentFolder) removeObject:sourceItem];
    } else {
        [SavedRequestsDataSource.savedRequestsArray removeObject:sourceItem];
    }
    
    NSLog(@"Found source item of drop: %@ with parent %@", sourceItem, sourceParentFolder);
    
    if (! targetItem) {
        // Saving into the top level array
        if (sourceParentFolder == nil && (targetIndex > sourceIndex)) {
            targetIndex--;
        }
        [SavedRequestsDataSource.savedRequestsArray insertObject:sourceItem atIndex:targetIndex];
        [appDelegate redrawRequestViews];
        [self saveDataToDisk];
        return YES;
    } else {
        // Saving into a sub-folder
        NSLog(@"TargetIndex = %ld and sourceIndex = %d", targetIndex, sourceIndex);
        if (sourceParentFolder == targetItem && (targetIndex > sourceIndex)) {
            targetIndex--;
        }
        [((CRCSavedRequestFolder *) targetItem) insertObject:sourceItem atIndex:targetIndex];
        [appDelegate redrawRequestViews];
        [self saveDataToDisk];
        return YES;
    }
    
}

- (void) saveDataToDisk {
    NSString *path = [self pathForDataFile];
    [NSKeyedArchiver archiveRootObject:SavedRequestsDataSource.savedRequestsArray toFile:path];
}

- (void) loadDataFromDisk {
    NSString *path = [self pathForDataFile];
    SavedRequestsDataSource.savedRequestsArray = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:path]];
}

- (NSString *) pathForDataFile {
    if (!appDataFilePath) {
        NSArray *allPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSString *dir = [[allPaths objectAtIndex: 0] stringByAppendingPathComponent: APPLICATION_NAME];
        if (!dir) {
            NSLog(@"Can not locate the Application Support directory. Weird.");
            return nil;
        }
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        BOOL success = [fileManager createDirectoryAtPath: dir withIntermediateDirectories: YES
                                               attributes: nil error: &error];
        if (!success) {
            NSLog(@"Can not create a support directory.\n%@", [error localizedDescription]);
            return nil;
        }
        appDataFilePath = [dir stringByAppendingPathComponent: DATAFILE_NAME];
        
        // On first time startup of version 1.3.8 of the app, backup the data file since the format
        // will make it backwards incompatible.
        NSString *backupDataFilePath = [dir stringByAppendingPathComponent:BACKUP_DATAFILE_1_3_8];
        if (! [fileManager fileExistsAtPath:backupDataFilePath]) {
            NSError *error = nil;
            [fileManager copyItemAtPath:appDataFilePath toPath:backupDataFilePath error:&error];
            if (! error) {
                NSLog(@"Successfully backed up 1.3.8 datafile as: %@", backupDataFilePath);
            } else {
                NSLog(@"Error backing up old data file: %@", [error localizedDescription]);
            }
        }
    }
    return appDataFilePath;
}


@end
