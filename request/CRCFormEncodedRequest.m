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
			
      value = (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge_retained CFStringRef)value, NULL, CFSTR("!#$%&'()*+,/:;=?@[]"), kCFStringEncodingUTF8);
			[body appendData:[[NSString stringWithFormat:@"%@=%@",
							   [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
							   value] 
							  dataUsingEncoding:NSUTF8StringEncoding]];
		}
	}
	
	[request setHTTPBody: body];
}
@end
