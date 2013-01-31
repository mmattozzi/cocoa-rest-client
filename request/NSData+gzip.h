//
//  NSData+gzip.h
//  CocoaRestClient
//
//  Created by Eric Broska on 1/30/13.
//
//
#import <Foundation/Foundation.h>

@interface NSData (gzip)

/*
 * Returns gzip compressed data
 * (max compression, adds gzip headers)
 */
- (NSData *)gzipped;

@end
