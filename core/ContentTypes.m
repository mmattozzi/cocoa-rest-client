//
//  ContentTypes.m
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 5/29/16.
//  Copyright (c) 2016 Michael Mattozzi. All rights reserved.
//

#import "ContentTypes.h"

@implementation ContentTypes

@synthesize xmlContentTypes;
@synthesize jsonContentTypes;
@synthesize msgPackContentTypes;

+ (ContentTypes *) sharedContentTypes {
    static ContentTypes *sharedObj = nil;
    @synchronized(self) {
        if (sharedObj == nil) {
            sharedObj = [[self alloc] init];
            
            sharedObj.xmlContentTypes = [NSArray arrayWithObjects:@"application/xml", @"application/atom+xml", @"application/rss+xml",
                               @"text/xml", @"application/soap+xml", @"application/xml-dtd", nil];
            
            sharedObj.jsonContentTypes = [NSArray arrayWithObjects:@"application/json", @"text/json", nil];
            
            sharedObj.msgPackContentTypes = [NSArray arrayWithObjects:@"application/x-msgpack", @"application/x-messagepack", nil];
        }
    }
    return sharedObj;
}

- (BOOL) isXml:(NSString *)contentType {
    return ([xmlContentTypes containsObject:contentType] ||
            ([contentType hasPrefix:@"application"] && [contentType hasSuffix:@"+xml"]));
}

- (BOOL) isJson:(NSString *)contentType {
    return [jsonContentTypes containsObject:contentType] ||
    ([contentType hasPrefix:@"application"] && [contentType hasSuffix:@"+json"]);}

- (BOOL) isMsgPack:(NSString *)contentType {
    return [msgPackContentTypes containsObject:contentType];
}

@end
