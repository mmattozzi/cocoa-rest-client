//
//  NSData+gzip.m
//  CocoaRestClient
//
//  Created by Eric Broska on 1/30/13.
//
#include <zlib.h>
#import "NSData+gzip.h"

@implementation NSData (gzip)

- (NSData *)gzipped
{
    if ([self length] == 0) {
        return nil;
    }
    z_stream stream = {0};
    stream.avail_in = [self length];
    stream.next_in  = (unsigned char *)[self bytes];
    /*
     * (15+16) means: max window size(15) + write gzip headers(16)
     */
    int error = deflateInit2(&stream, Z_BEST_COMPRESSION, Z_DEFLATED, (15+16), MAX_MEM_LEVEL, Z_DEFAULT_STRATEGY);
    if (Z_OK != error) {
        NSLog(@"zlib's deflateInit2() error response: %d\n", error);
        return nil;
    }
    /*
     * > In this case [Z_FINISH], avail_out must be at least 0.1% larger than avail_in plus 12 bytes.
     * @ http://www.gzip.org/zlib/manual.html
     */
    NSMutableData *result = [NSMutableData dataWithLength: [self length] * 1.01 + 12];
    
    while (Z_OK == error) {
        stream.next_out = [result mutableBytes] + stream.total_out;
        stream.avail_out = [result length] - stream.total_out;
        error = deflate(&stream, Z_FINISH);
    }
    if (error != Z_STREAM_END) { 
        NSLog(@"zlib's deflate() error response: %d\n", error);
        return nil;
    }
    deflateEnd(&stream);
    result.length = stream.total_out;
    
    return result;
}

@end
