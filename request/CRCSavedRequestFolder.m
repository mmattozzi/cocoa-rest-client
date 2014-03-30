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
