//
//  CRCSavedRequestFolder.h
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 3/15/14.
//  Copyright (c) 2014 Michael Mattozzi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRCSavedRequestFolder : NSObject<NSCoding> {
    NSString *name;
    NSMutableArray *contents;
}

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSMutableArray *contents;

- (id) init;
- (NSUInteger)count;
- (void) addObject:(id) object;
- (id) objectAtIndex:(NSUInteger)index;
- (void) removeObject:(id) object;

- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;

@end