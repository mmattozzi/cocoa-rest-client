//
//  ContentTypes.h
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 5/29/16.
//  Copyright (c) 2016 Michael Mattozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ContentTypes : NSObject {
    NSArray *xmlContentTypes;
    NSArray *jsonContentTypes;
    NSArray *msgPackContentTypes;
}

@property (nonatomic, retain) NSArray *xmlContentTypes;
@property (nonatomic, retain) NSArray *jsonContentTypes;
@property (nonatomic, retain) NSArray *msgPackContentTypes;

+ (ContentTypes *) sharedContentTypes;

- (BOOL) isXml:(NSString *)contentType;
- (BOOL) isJson:(NSString *)contentType;
- (BOOL) isMsgPack:(NSString *)contentType;

@end
