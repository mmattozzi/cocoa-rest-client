//
//  SelectableSavedRequestWrapper.m
//  CocoaRestClient
//
//  Created by Mike Mattozzi on 3/11/17.
//
//

#import "SelectableSavedRequestWrapper.h"

@implementation SelectableSavedRequestWrapper

@synthesize request;
@synthesize path;

+ (SelectableSavedRequestWrapper *) initWithRequest:(CRCRequest *)request withPath:(NSString*)path {
    SelectableSavedRequestWrapper *reqWrapper = [[SelectableSavedRequestWrapper alloc] init];
    reqWrapper.request = request;
    reqWrapper.path = path;
    return reqWrapper;
}

@end
