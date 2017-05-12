//
//  CRCMultipartRequest.h
//  CocoaRestClient
//
//  Created by Adam Venturella on 7/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MainWindowController;

@interface CRCMultipartRequest : NSObject {

}
+(void)createRequest:(NSMutableURLRequest *)request withWindow:(MainWindowController *)windowController;
+(NSString *)generateBoundary;
@end
