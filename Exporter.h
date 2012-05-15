//
//  Exporter.h
//  CocoaRestClient
//
//  Created by Sergey Klimov on 5/13/12.
//  Copyright (c) 2012 Self-Employed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Exporter : NSObject
+ (void) exportRequests:(NSArray*) requests toFile: (NSString*) path;
@end
