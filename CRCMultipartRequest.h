//
//  CRCMultipartRequest.h
//  CocoaRestClient
//
//  Created by Adam Venturella on 7/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CRCMultipartRequest : NSObject {

}
+(void)createRequest:(NSMutableURLRequest *)request;
+(NSString *)generateBoundary;
@end
