//
//  CRCSaveRequest.m
//  CocoaRestClient
//
//  Created by Adam Venturella on 7/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CRCRequest.h"
#import "CRCFormEncodedRequest.h"
#import "MainWindowController.h"


@implementation CRCRequest
@synthesize name, url, method, rawRequestInput, requestText, username, password, headers, files, params, preemptiveBasicAuth;

+ (CRCRequest *)requestWithWindow:(MainWindowController *)mainWindowController named:(NSString *)name
{
	
	CRCRequest * request    = [[CRCRequest alloc] init];
	
	request.name            = name;
	request.url             = [mainWindowController.urlBox stringValue];
    request.method          = [mainWindowController.methodButton stringValue];
	request.username        = [mainWindowController.username stringValue];
	request.password        = [mainWindowController.password stringValue];
    request.rawRequestInput = mainWindowController.rawRequestBody;
    request.preemptiveBasicAuth = mainWindowController.preemptiveBasicAuth;
	
	if(request.rawRequestInput)
		request.requestText = [mainWindowController getRequestText];
	
	if([mainWindowController.headersTable count] > 0)
		request.headers = [[NSArray alloc] initWithArray:mainWindowController.headersTable copyItems:YES];
	
	if([mainWindowController.paramsTable count] > 0 && !request.rawRequestInput)
		request.params = [[NSArray alloc] initWithArray:mainWindowController.paramsTable copyItems:YES];
	
	if([mainWindowController.filesTable count] > 0)
		request.files = [[NSArray alloc] initWithArray:mainWindowController.filesTable copyItems:YES];
	
	return request;
}

/** Overwrite all fields except the name with the contents of the input request. */
- (CRCRequest *)overwriteContentsWith:(CRCRequest *)request {
    self.url = request.url;
    self.method = request.method;
    self.username = request.username;
    self.password = request.password;
    self.rawRequestInput = request.rawRequestInput;
    self.preemptiveBasicAuth = request.preemptiveBasicAuth;
    self.requestText = request.requestText;
    self.headers = request.headers;
    self.params = request.params;
    self.files = request.files;
    return self;
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

+ (CRCContentType) determineRequestContentType:(NSArray *) headers {
    CRCContentType requestContentType = CRCContentTypeUnknown;
    
    for(NSDictionary * row in headers)
    {
        if([[[row objectForKey:@"key"] lowercaseString] isEqualToString:@"content-type"])
        {
            NSString * value = [[row objectForKey:@"value"] lowercaseString];
            NSRange range;
            
            if([value isEqualToString:@"application/x-www-form-urlencoded"]){
                requestContentType = CRCContentTypeFormEncoded;
                break;
            }
            
            if([value isEqualToString:@"multipart/form-data"]){
                requestContentType = CRCContentTypeMultipart;
                break;
            }
            
            range = [value rangeOfString:@"json"];
            if(range.length > 0){
                requestContentType = CRCContentTypeJson;
                break;
            }
            
            range = [value rangeOfString:@"xml"];
            if(range.length > 0){
                requestContentType = CRCContentTypeXml;
                break;
            }
            
            range = [value rangeOfString:@"image"];
            if(range.length > 0){
                requestContentType = CRCContentTypeImage;
                break;
            }
        }
    }
    
    return requestContentType;
}

- (NSString *) generateCurlCommand:(bool)followRedirects {
    NSMutableString *command = [NSMutableString stringWithCapacity:500];
    [command appendString:@"curl -k "];
    if (followRedirects) {
        [command appendString:@" -L "];
    }
    if (! [method isEqualToString:@"GET"]) {
        [command appendString:[NSString stringWithFormat:@"-X %@ ", method]];
    }
    
    for (NSDictionary *header in headers) {
        [command appendString:[NSString stringWithFormat:@"-H '%@: %@' ", [header valueForKey:@"key"], [header valueForKey:@"value"]]];
    }
    
    CRCContentType contentType = [CRCRequest determineRequestContentType:headers];
    
    if (contentType != CRCContentTypeFormEncoded) {
        for (NSDictionary *param in params) {
            [command appendString:[NSString stringWithFormat:@"-F '%@=%@' ", [param valueForKey:@"key"], [param valueForKey:@"value"]]];
        }
    } else if (! rawRequestInput && [params count] > 0) {
        [command appendString:[NSString stringWithFormat:@"-d '%@' ",
           [[NSString alloc] initWithData:[CRCFormEncodedRequest createRequestBody:params] encoding:NSUTF8StringEncoding]]];
    }
    
    if (rawRequestInput && [requestText length] > 0) {
        [command appendString:[NSString stringWithFormat:@"-d '%@' ", requestText]];
    }
    
    if (username && password && ([username length] > 0 || [password length] > 0)) {
        [command appendString:[NSString stringWithFormat:@"-u '%@:%@' ", username, password]];
    }
    
    if (contentType == CRCContentTypeMultipart) {
        for (NSDictionary *fileParam in files) {
            NSString *filePath = [[fileParam valueForKey:@"url"] absoluteString];
            if ([filePath hasPrefix:@"file://"]) {
                filePath = [filePath substringFromIndex:7];
            }
            [command appendString:[NSString stringWithFormat:@"-F '%@=@%@' ", [fileParam valueForKey:@"key"], filePath]];
        }
    }
    
    [command appendString:[NSString stringWithFormat:@"'%@'", url]];
    
    return command;
}

@end
