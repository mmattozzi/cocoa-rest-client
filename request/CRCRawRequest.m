//
//  CRCRawRequest.m
//  CocoaRestClient
//
//  Created by Adam Venturella on 7/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CRCRawRequest.h"
#import "CocoaRestClientAppDelegate.h"
#import "MainWindowController.h"

@implementation CRCRawRequest
+(void)createRequest:(NSMutableURLRequest *)request withWindow:(MainWindowController *)windowController
{
	NSMutableData * body    = [NSMutableData data];
	[body appendData:[[windowController getRequestText] dataUsingEncoding:NSUTF8StringEncoding]];
	[request setHTTPBody: body];
}
@end
