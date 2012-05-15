//
//  ArchiveExporter.m
//  CocoaRestClient
//
//  Created by Sergey Klimov on 5/13/12.
//  Copyright (c) 2012 Self-Employed. All rights reserved.
//

#import "ArchiveExporter.h"

@implementation ArchiveExporter
+ (void) exportRequests:(NSArray*) requests toFile: (NSString*) path {
    [NSKeyedArchiver archiveRootObject:requests toFile:path];
}
@end
