//
//  CRCRawRequest.m
//  CocoaRestClient
//
//  Created by Adam Venturella on 7/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CRCRawRequest.h"
#import "CocoaRestClientAppDelegate.h"

@implementation CRCRawRequest
+(void)createRequest:(NSMutableURLRequest *)request
{
	CocoaRestClientAppDelegate * delegate = (CocoaRestClientAppDelegate *)[[NSApplication sharedApplication] delegate];
	NSMutableData * body    = [NSMutableData data];
	[body appendData:[[delegate.requestText string] dataUsingEncoding:NSUTF8StringEncoding]];
	[request setHTTPBody: body];
}
@end
