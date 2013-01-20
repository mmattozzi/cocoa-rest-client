//
//  CheckableRequestWrapper.h
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 1/15/12.
//  Copyright (c) 2012 Michael Mattozzi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckableRequestWrapper : NSObject {
    BOOL enabled;
    id request;
    NSString *name;
    NSButtonCell *cell;
}

- (CheckableRequestWrapper *) initWithName:(NSString *)name enabled:(BOOL)enabled request:(id)request; 
- (BOOL) enabled;
- (NSString *) name;
- (id) request;
- (void) setEnabled:(BOOL)reqEnabled;
- (NSButtonCell *) cell;

@end
