//
//  CRCFormEncodedRequest.h
//  CocoaRestClient
//
//  Created by Adam Venturella on 7/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MainWindowController;

@interface CRCFormEncodedRequest : NSObject {

}
+(void)createRequest:(NSMutableURLRequest *)request withWindow:(MainWindowController *)windowController;
+(NSData *) createRequestBody:(NSArray *)params;
@end
