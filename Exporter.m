//
//  Exporter.m
//  CocoaRestClient
//
//  Created by Sergey Klimov on 5/13/12.
//  Copyright (c) 2012 Self-Employed. All rights reserved.
//

#import "Exporter.h"
#import "ArchiveExporter.h"
#import "MarkdownExporter.h"

@implementation Exporter
+ (void) exportRequests:(NSArray*) requests toFile: (NSString*) path {
    NSString* extension = [path pathExtension];
    if ([extension isEqualToString:@"restClient"]) {
        [ArchiveExporter exportRequests:requests toFile:path];
    } else if ([extension isEqualToString:@"md"]||
               [extension isEqualToString:@"markdown"]) {
        [MarkdownExporter exportRequests:requests toFile:path];
    } else {
        @throw [NSException exceptionWithName:@"NotImplementedError" reason:@"Format not known" userInfo:nil];
    
    }
}

@end
