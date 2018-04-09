//
//  FGSocketService.h
//  PrizeClaw
//
//  Created by FengLe on 2017/9/29.
//  Copyright © 2017年 FengLe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FGSocketPacket.h"

/* 验证连接成功和失败 */
extern NSString * const kFGSocketAuthSuccessNotification;
extern NSString * const kFGSocketErrorConnectedNotification;

@protocol FGASocketProtocol<NSObject>

- (void)roomReceivePacket:(FGDownstreamPacket *)packet;

@end

@protocol FGBSocketChannelProtocol<NSObject>

- (void)socketChannelReceivePacket:(FGDownstreamPacket *)packet;

@end

@interface FGSocketService : NSObject

/* 我在这里采用不同业务逻辑-对应-不同代理 */
/**
 A代理
 */
@property (nonatomic, weak) id<FGASocketProtocol> roomDelegate;
/**
 B代理
 */
@property (nonatomic, weak) id<FGBSocketChannelProtocol> channelDelegate;


+ (instancetype)shareSocketService;

- (void)appLogin;

- (void)appLogout;

- (void)sendPacketWithPacketType:(FGSocketMsgType)packetType content:(NSDictionary *)content;

@end
