//
//  CRCFormEncodedRequest.m
//  CocoaRestClient
//
//  Created by Adam Venturella on 7/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CRCFormEncodedRequest.h"
#import "CocoaRestClientAppDelegate.h"

@implementation CRCFormEncodedRequest
+(void)createRequest:(NSMutableURLRequest *)request
{
	CocoaRestClientAppDelegate * delegate = (CocoaRestClientAppDelegate *)[[NSApplication sharedApplication] delegate];
	NSMutableData * body    = [NSMutableData data];
	NSString * headerfield  = @"application/x-www-form-urlencoded";
	
	[request addValue:headerfield forHTTPHeaderField:@"Content-Type"];
	
	if([delegate.paramsTable count] > 0)
	{
		for(NSDictionary * row in delegate.paramsTable)
		{
			NSString * key   = [row objectForKey:@"key"];
			NSString * value = [row objectForKey:@"value"];
			
			if([body length] > 0) 
				[body appendData:[@"&" dataUsingEncoding:NSUTF8StringEncoding]];
			
      value = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      value = [value stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
			[body appendData:[[NSString stringWithFormat:@"%@=%@",
							   [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
							   value] 
							  dataUsingEncoding:NSUTF8StringEncoding]];
		}
	}
	
	[request setHTTPBody: body];
}
@end
