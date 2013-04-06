//
//  MessagePackParser.h
//  Fetch TV Remote
//
//  Created by Chris Hulbert on 23/06/11.
//  Copyright 2011 Digital Five. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "msgpack_src/msgpack.h"

@interface MessagePackParser : NSObject {
    // This is only for MessagePackParser+Streaming category.
    msgpack_unpacker unpacker;
}

+ (id)parseData:(NSData*)data;

@end
