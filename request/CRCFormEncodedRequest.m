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
			
			if([body length] > 0) {
				[body appendData:[@"&" dataUsingEncoding:NSUTF8StringEncoding]];
            }
			
            // URL form encode the key for the parameter
            key = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            // For some reason, & and + are not escaped by stringByAddingPercentEscapesUsingEncoding
            key = [key stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
            key = [key stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
            
            // URL form encode the value of the parameter
            value = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            // For some reason, & and + are not escaped by stringByAddingPercentEscapesUsingEncoding
 			value = [value stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
            value = [value stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
            
			[body appendData:[[NSString stringWithFormat:@"%@=%@", key, value] 
                              dataUsingEncoding:NSUTF8StringEncoding]];
		}
	}
	
	[request setHTTPBody: body];
}
@end
