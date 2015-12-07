//
//  CheckableRequestWrapper.h
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 1/15/12.
//  Copyright (c) 2012 Michael Mattozzi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRCSavedRequestFolder.h"

@interface CheckableRequestWrapper : NSObject {
    NSCellStateValue _enabled;
    id request;
    NSString *name;
    NSMutableArray *contents;
    CheckableRequestWrapper *parent;
}

+ (CheckableRequestWrapper *) checkableRequestWrapperForRequest: (id)request;
- (CheckableRequestWrapper *) initWithName:(NSString *)name enabled:(BOOL)enabled request:(id)request;
- (NSString *) name;
- (id) request;
- (NSCellStateValue) enabled;
- (void) setEnabled:(BOOL)reqEnabled;
- (int) count;
- (NSMutableArray*) contents;

@end
