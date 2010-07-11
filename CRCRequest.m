//
//  CRCSaveRequest.m
//  CocoaRestClient
//
//  Created by Adam Venturella on 7/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CRCRequest.h"


@implementation CRCRequest
@synthesize name, url, method, rawRequestInput, requestText, username, password, headers, files, params;

+ (CRCRequest *)requestWithApplication:(CocoaRestClientAppDelegate *)application
{
	
	CRCRequest * request    = [[CRCRequest alloc] init];
	
	request.name            = [application.saveRequestTextField stringValue];
	request.url             = [application.urlBox stringValue];
	request.method          = [application.methodButton titleOfSelectedItem];
	request.username        = [application.username stringValue];
	request.password        = [application.password stringValue];
	request.rawRequestInput = application.rawRequestInput;
	
	if(request.rawRequestInput)
		request.requestText = [application.requestText string];
	
	if([application.headersTable count] > 0)
		request.headers = application.headersTable;
	
	if([application.paramsTable count] > 0 && !request.rawRequestInput)
		request.params = application.paramsTable;
	
	if([application.filesTable count] > 0)
		request.files = application.filesTable;
	
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
