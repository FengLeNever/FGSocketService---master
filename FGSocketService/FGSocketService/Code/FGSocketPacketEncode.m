//
//  FGSocketPacketEncode.m
//  PrizeClaw
//
//  Created by FengLe on 2017/10/9.
//  Copyright © 2017年 FengLe. All rights reserved.
//

#import "FGSocketPacketEncode.h"

@interface FGSocketPacketEncode()

@property (nonatomic, assign) NSInteger timeout;

@end

@implementation FGSocketPacketEncode

- (instancetype)init
{
    if (self = [super init]) {
        _timeout = -1;
    }
    return self;
}

- (void)encodeUpPacket:(FGUpstreamPacket *)upPacket output:(id<FGSocketEncoderOutputProtocol>)output
{
    if (upPacket.socketByte.buffer.length <= 0) {
        NSLog(@"dataRequest is nil");
        return;
    }
    FGSocketByteBuf *socketByte = [[FGSocketByteBuf alloc] init];
    
    [socketByte writeInt16:upPacket.socketByte.length useHost:YES];
    [socketByte writeData:upPacket.socketByte.buffer];
    [output didEncode:socketByte.buffer timeout:_timeout];
}

@end
