//
//  CheckableRequestWrapper.m
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 1/15/12.
//  Copyright (c) 2012 Michael Mattozzi. All rights reserved.
//

#import "CheckableRequestWrapper.h"

@implementation CheckableRequestWrapper

+ (CheckableRequestWrapper *) checkableRequestWrapperForRequest: (id) request {
    
    NSString* name;
    if ([request isKindOfClass:[NSDictionary class]]) {
        name = [request objectForKey:@"name"];
    } else {
        name = [request name];
    }
    
    CheckableRequestWrapper *requestWrapper = [[CheckableRequestWrapper alloc] initWithName:name enabled:YES request:request];
    
    if ([request isKindOfClass:[CRCSavedRequestFolder class]]) {
        CRCSavedRequestFolder *crcFolder = (CRCSavedRequestFolder *) request;
        for (id object in [crcFolder contents]) {
            CheckableRequestWrapper* child = [CheckableRequestWrapper checkableRequestWrapperForRequest:object];
            child->parent = requestWrapper;
            
            [[requestWrapper contents] addObject:child];
        }
    }
    
    return requestWrapper;
}

- (CheckableRequestWrapper *) initWithName:(NSString *)reqName enabled:(BOOL)reqEnabled request:(id)requestObject {
    self = [super init];
    
    if (self) {
        name = reqName;
        _enabled = reqEnabled;
        request = requestObject;
        contents = [NSMutableArray array];
    }
    
    return self;
}

- (NSCellStateValue) enabled {
    return _enabled;
}

- (NSString *) name {
    return name;
}

- (id) request {
    return request;
}

- (void) setEnabled:(BOOL)reqEnabled {
    _enabled = reqEnabled;
    
    [self setChildrenEnabled:reqEnabled];
    [self updateParent];
}

- (void) setChildrenEnabled:(BOOL)reqEnabled {
    for (CheckableRequestWrapper* child in contents) {
        child->_enabled = reqEnabled;
        [child setChildrenEnabled:reqEnabled];
    }
}

- (void) updateParent {
    if (parent == nil) return;
    
    int checkedChildren = 0;
    for (CheckableRequestWrapper* child in [parent contents]) {
        if (child.enabled != NSOffState) checkedChildren++;
    }
    
    NSCellStateValue state;
    if (checkedChildren == 0) {
        state = NSOffState;
    } else if (checkedChildren == [[parent contents] count]) {
        state = NSOnState;
    } else {
        state = NSMixedState;
    }
    
    if ([parent enabled] == state) return;
    
    parent->_enabled = state;
    [parent updateParent];
}

- (int) count {
    return [contents count];
}

- (NSMutableArray*) contents {
    return contents;
}

@end
