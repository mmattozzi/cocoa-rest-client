//
//  MessagePackParser+Streaming.h
//  msgpack-objectivec
//
//  Created by Kentaro Matsumae on 2013/01/18.
//  Copyright (c) 2013 kenmaz.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessagePackParser.h"

@interface MessagePackParser (Streaming)

- (id)init;
- (id)initWithBufferSize:(int)bufferSize;
- (void)feed:(NSData*)rawData;
- (id)next;

@end
