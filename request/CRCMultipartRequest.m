//
//  CRCMultipartRequest.m
//  CocoaRestClient
//
//  Created by Adam Venturella on 7/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CRCMultipartRequest.h"
#import "CocoaRestClientAppDelegate.h"

@implementation CRCMultipartRequest
+(void)createRequest:(NSMutableURLRequest *)request
{
	CocoaRestClientAppDelegate * delegate = (CocoaRestClientAppDelegate *)[[NSApplication sharedApplication] delegate];
	
	NSMutableData * body    = [NSMutableData data];
	NSString * formBoundary = [CRCMultipartRequest generateBoundary];
	NSString * headerfield  = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", formBoundary];
	
	[request addValue:headerfield forHTTPHeaderField:@"Content-Type"];
	
	if([delegate.paramsTable count] > 0)
	{
		for(NSDictionary * row in delegate.paramsTable)
		{
			[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",formBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", [row objectForKey:@"key"], [row objectForKey:@"value"]] dataUsingEncoding:NSUTF8StringEncoding]];
		}
	}
	
	NSInteger count = [delegate.filesTable count];
	if(count > 0)
	{	
		for(NSDictionary * row in delegate.filesTable)
		{
			NSError *err = nil;
			NSString *uti; 
			NSString *mimeType;
			
			NSURL *path = [row objectForKey:@"url"];
			
			if([[NSFileManager defaultManager] fileExistsAtPath:[path relativePath]])
			{
			
				if (!(uti = [[NSWorkspace sharedWorkspace] typeOfFile:[path relativePath] error:&err]))
				{
					mimeType = @"application/octet-stream";
				}
				else 
				{
					if ((mimeType = (NSString *)UTTypeCopyPreferredTagWithClass((CFStringRef)uti, kUTTagClassMIMEType)))
						mimeType = NSMakeCollectable(mimeType);
				}
							
			
				[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", formBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
				[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [row objectForKey:@"key"],[[path relativePath] lastPathComponent]]   dataUsingEncoding:NSUTF8StringEncoding]];
				

				// there is most certainly a smarter way to handle this
				// for now, though, it's just a simple rule.
				NSRange result = [mimeType rangeOfString:@"image"];
				if(result.length > 0)
					[body appendData:[[NSString stringWithString:@"Content-Transfer-Encoding: binary\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
				
				
				[body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimeType] dataUsingEncoding:NSUTF8StringEncoding]];	
				[body appendData:[NSData dataWithContentsOfFile:[path relativePath]]];
			}
		}

	}
	
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", formBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[request setHTTPBody: body];
}

+(NSString *)generateBoundary
{
	CFUUIDRef uuidRef     = CFUUIDCreate(kCFAllocatorDefault);
	CFStringRef stringRef = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
	NSString *uuid        = [NSString stringWithString:(NSString*)stringRef];
	
	CFRelease(stringRef);
	CFRelease(uuidRef);
	
	return uuid;
}
@end
