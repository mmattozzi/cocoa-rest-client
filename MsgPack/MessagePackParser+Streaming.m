//
//  MessagePackParser+Streaming.m
//  msgpack-objectivec
//
//  Created by Kentaro Matsumae on 2013/01/18.
//  Copyright (c) 2013 kenmaz.net. All rights reserved.
//

#import "MessagePackParser+Streaming.h"

static const int kUnpackerBufferSize = 1024;

@interface MessagePackParser ()
// Implemented in MessagePackParser.m
+(id) createUnpackedObject:(msgpack_object)obj;
@end

@implementation MessagePackParser (Streaming)

- (id)init {
    return [self initWithBufferSize:kUnpackerBufferSize];
}

- (id)initWithBufferSize:(int)bufferSize {
    if (self = [super init]) {
        msgpack_unpacker_init(&unpacker, bufferSize);
    }
    return self;
}

// Feed chunked messagepack data into buffer.
- (void)feed:(NSData*)chunk {
    msgpack_unpacker_reserve_buffer(&unpacker, [chunk length]);
    memcpy(msgpack_unpacker_buffer(&unpacker), [chunk bytes], [chunk length]);
    msgpack_unpacker_buffer_consumed(&unpacker, [chunk length]);
}

// Put next parsed messagepack data. If there is not sufficient data, return nil.
- (id)next {
    id unpackedObject;
    msgpack_unpacked result;
    msgpack_unpacked_init(&result);
    if (msgpack_unpacker_next(&unpacker, &result)) {
        msgpack_object obj = result.data;
        unpackedObject = [MessagePackParser createUnpackedObject:obj];
    }
    msgpack_unpacked_destroy(&result);
    
#if !__has_feature(objc_arc)
    return [unpackedObject autorelease];
#else
    return unpackedObject;
#endif
}

@end
