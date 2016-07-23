//
//  CRCFileRequest.m
//  CocoaRestClient
//
//  Created by Adam Venturella on 7/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CRCFileRequest.h"
#import "CocoaRestClientAppDelegate.h"

@implementation CRCFileRequest
+(void)createRequest:(NSMutableURLRequest *)request
{
	CocoaRestClientAppDelegate * delegate = (CocoaRestClientAppDelegate *)[[NSApplication sharedApplication] delegate];
	NSMutableData * body    = [NSMutableData data];
	
	NSURL * path = [[delegate.filesTable objectAtIndex:0] objectForKey:@"url"];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:[path relativePath]])
	{
	
		[body appendData:[NSData dataWithContentsOfFile:[path relativePath]]];
		[request setHTTPBody: body];
	}
}

+(BOOL) currentRequestIsCRCFileRequest:(CocoaRestClientAppDelegate *)application {
    return [application.filesTable count] > 0 && [[application getRequestText] isEqualToString:@""] &&
        [[NSUserDefaults standardUserDefaults]boolForKey:RAW_REQUEST_BODY];
}

@end
