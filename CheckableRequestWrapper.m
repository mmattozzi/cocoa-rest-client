//
//  CheckableRequestWrapper.m
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 1/15/12.
//  Copyright (c) 2012 Michael Mattozzi. All rights reserved.
//

#import "CheckableRequestWrapper.h"

@implementation CheckableRequestWrapper

- (CheckableRequestWrapper *) initWithName:(NSString *)reqName enabled:(BOOL)reqEnabled request:(id)requestObject {
    self = [super init];
    
    if (self) {
        name = reqName;
        enabled = reqEnabled;
        request = requestObject;
        
        cell=[[NSButtonCell alloc] init];
        [cell setTitle:name];
        [cell setAllowsMixedState:YES];
        [cell setButtonType:NSSwitchButton];
    }
    
    return self;
}

- (BOOL) enabled {
    return enabled;
}

- (NSString *) name {
    return name;
}

- (id) request {
    return request;
}

- (void) setEnabled:(BOOL)reqEnabled {
    enabled = reqEnabled;
}

- (NSButtonCell *) cell {
    return cell;
}

@end
