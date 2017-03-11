//
//  SelectableSavedRequestWrapper.h
//  CocoaRestClient
//
//  Created by Mike Mattozzi on 3/11/17.
//
//

#import <Foundation/Foundation.h>
#import "CRCRequest.h"

@interface SelectableSavedRequestWrapper : NSObject

@property (nonatomic, retain) CRCRequest* request;
@property (nonatomic, retain) NSString* path;

+ (SelectableSavedRequestWrapper *) initWithRequest:(CRCRequest *)request withPath:(NSString*)path;

@end
