//
//  CRCSavedRequestFolder.m
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 3/15/14.
//  Copyright (c) 2014 Michael Mattozzi. All rights reserved.
//

#import "CRCSavedRequestFolder.h"

@implementation CRCSavedRequestFolder
@synthesize name;
@synthesize contents;

- (NSUInteger)count {
    return [contents count];
}

- (void) addObject:(id) object {
    [contents addObject:object];
}

- (void) insertObject:(id) object atIndex:(NSUInteger)index {
    [contents insertObject:object atIndex:index];
}

- (id) objectAtIndex:(NSUInteger)index {
    return [contents objectAtIndex:index];
}

// Recursively remove object from any embedded CRCSavedRequestFolders
- (void) removeObject:(id) object {
    if ([contents containsObject:object]) {
        [contents removeObject:object];
    } else {
        for (id entry in contents) {
            if ([entry isKindOfClass:[CRCSavedRequestFolder class]]) {
                [((CRCSavedRequestFolder *)entry) removeObject:object];
            }
        }
    }
}

- (void)setContents:(NSMutableArray *)array {
    contents = [array mutableCopy];
}

/**
 * Recursively search all subfolders and return the object matching the id requested. 
 * Returns self if self matches the given id. 
 */
- (id) findObjectWith:(NSString *) objId {
    id object = nil;
    if ([[NSString stringWithFormat:@"%p", (long) self] isEqualToString:objId]) {
        object = self;
    } else {
        for (id entry in contents) {
            if (! [entry isKindOfClass:[CRCSavedRequestFolder class]]) {
                if ([[NSString stringWithFormat:@"%p", (long) entry] isEqualToString:objId]) {
                    object = entry;
                }
            } else {
                id recursiveObj = [((CRCSavedRequestFolder *)entry) findObjectWith:objId];
                if (recursiveObj) {
                    object = recursiveObj;
                }
            }
        }
    }
    
    return object;
}

/**
 * Recursively search contents and subfolders and return the index of the object specified, in 
 * whatever subfolder it was located. For example, if we are searching for object x in:
 *     - a
 *     + b
 *       + c
 *         - d
 *         - e
 *         - x
 * The returned integer would be 2. If the object is not found, return -1.
 */
- (int) findIndexOfObject:(id) obj {
    int index = -1;
    for (int i = 0; i < [contents count]; i++) {
        id entry = [contents objectAtIndex:i];
        if (entry == obj) {
            index = i;            
        } else if ([entry isKindOfClass:[CRCSavedRequestFolder class]]) {
            int recursiveIndex = [((CRCSavedRequestFolder *)entry) findIndexOfObject:obj];
            if (recursiveIndex > -1) {
                index = recursiveIndex;
            }
        }
    }    
    return index;
}

/**
 * Recursively search subfolders and return the parent of the given object id. 
 * If this is the object id of self, return nil. If the object is not found, return nil.
 * 
 */
- (id) findParentOfObjectWith:(NSString *) objId {
    id parentId = nil;
    for (id entry in contents) {
        if ([[NSString stringWithFormat:@"%p", (long) entry] isEqualToString:objId]) {
            parentId = self;
        } else if ([entry isKindOfClass:[CRCSavedRequestFolder class]]) {
            id recursiveParentId = [((CRCSavedRequestFolder *)entry) findParentOfObjectWith:objId];
            if (recursiveParentId) {
                parentId = recursiveParentId;
            }
        }
    }
    return parentId;
}

-(id)init {
    if (self = [super init]) {
        contents = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.contents forKey:@"contents"];
}

- (id) initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        name = [coder decodeObjectForKey:@"name"];
        contents = [coder decodeObjectForKey:@"contents"];
    }
    return self;
}

@end
