//
//  CRCSaveRequest.m
//  CocoaRestClient
//
//  Created by Adam Venturella on 7/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CRCRequest.h"


@implementation CRCRequest
@synthesize name, url, method, rawRequestInput, requestText, username, password, headers, files, params, preemptiveBasicAuth;

+ (CRCRequest *)requestWithApplication:(CocoaRestClientAppDelegate *)application
{
	
	CRCRequest * request    = [[CRCRequest alloc] init];
	
	request.name            = [application.saveRequestTextField stringValue];
	request.url             = [application.urlBox stringValue];
    request.method          = [application.methodButton stringValue];
	request.username        = [application.username stringValue];
	request.password        = [application.password stringValue];
	request.rawRequestInput = application.rawRequestInput;
    request.preemptiveBasicAuth = application.preemptiveBasicAuth;
	
	if(request.rawRequestInput)
		request.requestText = [application.requestText string];
	
	if([application.headersTable count] > 0)
		request.headers = [[NSArray alloc] initWithArray:application.headersTable copyItems:YES];
	
	if([application.paramsTable count] > 0 && !request.rawRequestInput)
		request.params = [[NSArray alloc] initWithArray:application.paramsTable copyItems:YES];
	
	if([application.filesTable count] > 0)
		request.files = [[NSArray alloc] initWithArray:application.filesTable copyItems:YES];
	
	return [request autorelease];
}

- (void) encodeWithCoder: (NSCoder *)coder 
{
    [coder encodeBool:   self.rawRequestInput forKey: @"rawRequestInput"];
    [coder encodeObject: self.name forKey: @"name"];
    [coder encodeObject: self.url forKey: @"url"];
    [coder encodeObject: self.method forKey: @"method"];
    [coder encodeObject: self.requestText forKey: @"requestText"];
    [coder encodeObject: self.username forKey: @"username"];
    [coder encodeObject: self.password forKey: @"password"];
    [coder encodeObject: self.headers forKey: @"headers"];
    [coder encodeObject: self.files forKey: @"files"];
    [coder encodeObject: self.params forKey: @"params"];
    [coder encodeBool: self.preemptiveBasicAuth forKey:@"preemptiveBasicAuth"];
}

- (id) initWithCoder: (NSCoder *)coder 
{
    if (self = [super init])
    {
        rawRequestInput = [coder decodeBoolForKey: @"rawRequestInput"];
        name = [coder decodeObjectForKey: @"name"];
        url = [coder decodeObjectForKey: @"url"];
        method = [coder decodeObjectForKey: @"method"];
        requestText = [coder decodeObjectForKey: @"requestText"];
        username = [coder decodeObjectForKey: @"username"];
        password = [coder decodeObjectForKey: @"password"];
        headers = [coder decodeObjectForKey: @"headers"];
        files = [coder decodeObjectForKey: @"files"];
        params = [coder decodeObjectForKey: @"params"];
        if ([coder containsValueForKey:@"preemptiveBasicAuth"]) {
            preemptiveBasicAuth = [coder decodeBoolForKey:@"preemptiveBasicAuth"];
        } else {
            preemptiveBasicAuth = NO;
        }
    }
    
	return self;
}

- (void)dealloc
{
	self.name = nil;
	self.url = nil;
	self.method = nil;
	self.username = nil;
	self.password = nil;
	self.requestText = nil;
	self.headers = nil;
	self.files = nil;
	self.params = nil;
	
	[super dealloc];
}
@end
