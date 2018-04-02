//
//  FGSocketPacket.m
//  PrizeClaw
//
//  Created by FengLe on 2017/9/29.
//  Copyright © 2017年 FengLe. All rights reserved.
//

#import "FGSocketPacket.h"

#define BYTES_INT   4
#define BYTES_SHORT 2

@interface FGUpstreamPacket ()

@end


@implementation FGSocketPacket

@end


@interface FGUpstreamPacket ()

@property (nonatomic, strong) NSMutableData *requestData;

@end

@implementation FGUpstreamPacket

- (instancetype)initWithPacketType:(FGSocketMsgType)packetType content:(NSDictionary *)content;
{
    if (self = [super init]) {
        self.packetType = packetType;

        self.socketByte = [[FGSocketByteBuf alloc] init];
        [self.socketByte writeInt32:packetType useHost:YES];
        if (!kDictIsEmpty(content)) {
            NSString *param = [content mj_JSONString];
            [self.socketByte writeInt16:param.length useHost:YES];
            [self.socketByte writeString:[content mj_JSONString]];
        }
    }
    return self;
}

@end

@implementation FGDownstreamPacket


- (instancetype)initWithData:(NSData *)data
{
    if (self = [super init]) {
        self.socketByte = [[FGSocketByteBuf alloc] initWithData:data];
        self.packetType = [self.socketByte readInt32:0 useHost:YES];
        if (data.length > BYTES_INT) {
            self.packetDict = [[self.socketByte readData:BYTES_INT + BYTES_SHORT length:data.length - BYTES_SHORT - BYTES_INT] mj_JSONObject];
        }
    }
    return self;
}

@end
