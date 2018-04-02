//
//  FGSocketConnectParam.h
//  LoveSeize
//
//  Created by FengLe on 2017/9/22.
//  Copyright © 2017年 FengLe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FGSocketConnectParam : NSObject
/**
 连接服务器的domain或ip,默认nil
 */
@property (nonatomic, copy) NSString *host;
/**
 连接服务器的端口,默认0
 */
@property (nonatomic, assign) NSInteger port;
/**
 imToken,验证身份,默认nil
 */
@property (nonatomic, copy) NSString *imToken;
/**
 连接服务器的超时时间（单位秒s），默认为15秒
 */
@property (nonatomic, assign) NSTimeInterval timeout;
/**
 连接后是否自动开启心跳，默认为YES
 */
@property (nonatomic, assign) BOOL heartbeatEnabled;
/**
 心跳定时间隔，默认为30秒
 */
@property (nonatomic, assign) NSTimeInterval heartbeatInterval;
/**
 断开连接后，是否自动重连，默认为YES
 */
@property (nonatomic, assign) BOOL autoReconnect;
/**
 重连最大重连次数,默认100次
 */
@property (nonatomic, assign) NSInteger connectMaxCount;
/**
 重连的时间间隔,默认5秒
 */
@property (nonatomic, assign) NSTimeInterval connectInterval;

@end
