//
//  CRCFileRequest.m
//  CocoaRestClient
//
//  Created by Adam Venturella on 7/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CRCFileRequest.h"
#import "CocoaRestClientAppDelegate.h"
#import "MainWindowController.h"

@implementation CRCFileRequest
+(void)createRequest:(NSMutableURLRequest *)request withWindow:(MainWindowController *)windowController
{
	NSMutableData * body    = [NSMutableData data];
	
	NSURL * path = [[windowController.filesTable objectAtIndex:0] objectForKey:@"url"];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:[path relativePath]])
	{
	
		[body appendData:[NSData dataWithContentsOfFile:[path relativePath]]];
		[request setHTTPBody: body];
	}
}

+(BOOL) currentRequestIsCRCFileRequest:(MainWindowController *)windowController {
    return [windowController.filesTable count] > 0 && [[windowController getRequestText] isEqualToString:@""] &&
        [[NSUserDefaults standardUserDefaults]boolForKey:RAW_REQUEST_BODY];
}

@end
