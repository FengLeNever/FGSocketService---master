//
//  FGSocketPacket.h
//  PrizeClaw
//
//  Created by FengLe on 2017/9/29.
//  Copyright © 2017年 FengLe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FGSocketCMDType.h"

#import "FGSocketByteBuf.h"

@interface FGSocketPacket : NSObject

@property (nonatomic, assign) FGSocketMsgType packetType;

@property (nonatomic, strong) FGSocketByteBuf *socketByte;

@end

@interface FGUpstreamPacket : FGSocketPacket

#warning 注意: 每个公司定的数据包格式不同,解析方法也不同
/**
 在这里对数据包进行了解析
 */
- (instancetype)initWithPacketType:(FGSocketMsgType)packetType content:(NSDictionary *)content;

@end

@interface FGDownstreamPacket : FGSocketPacket


@property (nonatomic, strong) NSDictionary *packetDict;

- (instancetype)initWithData:(NSData *)data;

@end
