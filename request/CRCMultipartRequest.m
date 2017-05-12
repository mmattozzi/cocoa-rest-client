//
//  CRCMultipartRequest.m
//  CocoaRestClient
//
//  Created by Adam Venturella on 7/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CRCMultipartRequest.h"
#import "CocoaRestClientAppDelegate.h"
#import "NSData+gzip.h"
#import "MainWindowController.h"

@implementation CRCMultipartRequest
+(void)createRequest:(NSMutableURLRequest *)request withWindow:(MainWindowController *)windowController
{
	CocoaRestClientAppDelegate * delegate = (CocoaRestClientAppDelegate *)[[NSApplication sharedApplication] delegate];
	
	NSMutableData * body    = [NSMutableData data];
	NSString * formBoundary = [CRCMultipartRequest generateBoundary];
	NSString * headerfield  = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", formBoundary];
	
	[request addValue:headerfield forHTTPHeaderField:@"Content-Type"];
	
	if([windowController.paramsTable count] > 0)
	{
		for(NSDictionary * row in windowController.paramsTable)
		{
			[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",formBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", [row objectForKey:@"key"], [row objectForKey:@"value"]] dataUsingEncoding:NSUTF8StringEncoding]];
		}
	}
	
	NSInteger count = [windowController.filesTable count];
	if(count > 0)
	{	
		for(NSDictionary * row in windowController.filesTable)
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
				else if ((mimeType = (__bridge NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)uti, kUTTagClassMIMEType)))
                {
                    // TODO ???
                }
			
				[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", formBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
				[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [row objectForKey:@"key"],[[path relativePath] lastPathComponent]]   dataUsingEncoding:NSUTF8StringEncoding]];
				
                if ([[row objectForKey: @"gzip"] boolValue])
                {
                    [body appendData: [@"Content-Type: application/x-gzip\r\n\r\n" dataUsingEncoding: NSUTF8StringEncoding]];
                    [body appendData: [[NSData dataWithContentsOfFile: [path relativePath]] gzipped]];
                }
                else
                {
                    /* A «smarter» way, perhaps */
                    if ( ! [[NSWorkspace sharedWorkspace] type: uti conformsToType: (NSString *)kUTTypeText])
                    {
                        [body appendData: [@"Content-Transfer-Encoding: binary\r\n" dataUsingEncoding:NSUTF8StringEncoding]];                        
                    }
                    [body appendData: [[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimeType] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData: [NSData dataWithContentsOfFile: [path relativePath]]];
                }
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
	NSString *uuid        = [NSString stringWithString:(NSString*)CFBridgingRelease(stringRef)];
	
	CFRelease(uuidRef);
	
	return uuid;
}
@end
