//
//  MarkdownExporter.m
//  CocoaRestClient
//
//  Created by Sergey Klimov on 5/13/12.
//  Copyright (c) 2012 Self-Employed. All rights reserved.
//
#import "MarkdownExporter.h"

#import "GRMustache.h"

@implementation MarkdownExporter
+ (void) exportRequests:(NSArray*) requests toFile: (NSString*) path {
    NSString *result = [GRMustacheTemplate renderObject:[NSDictionary dictionaryWithObjectsAndKeys:requests, @"requests", nil]
                                              fromResource:@"MarkdownExport.md"
                                                    bundle:nil
                                                     error:NULL];
    NSError *error = nil;
    [result writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&error];
}
@end
