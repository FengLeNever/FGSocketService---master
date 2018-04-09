//
//  FGSocketService.m
//  PrizeClaw
//
//  Created by FengLe on 2017/9/29.
//  Copyright © 2017年 FengLe. All rights reserved.
//

#import "FGSocketService.h"
#import "FGSocketChannelDefault.h"

NSString * const kFGSocketAuthSuccessNotification = @"kFGSocketAuthSuccessNotification";
NSString * const kFGSocketErrorConnectedNotification = @"kFGSocketErrorConnectedNotification";

static FGSocketService *service = nil;

@interface FGSocketService()<FGSocketChannelDelegate>
{
    BOOL _hostRequesting;
}

@property (nonatomic, strong) FGSocketChannelDefault *socketChannel;
@property (nonatomic, strong) FGSocketConnectParam *connectParam;

@end

@implementation FGSocketService

+ (instancetype)shareSocketService {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[FGSocketService alloc] init];
    });
    return service;
}

- (void)appLogout
{
    [self removeNetworkingStatusNotification];
    [self removeAppStatusNotification];
    _connectParam = NULL;
    _hostRequesting = NO;
    [self closeConnection];
}

- (void)appLogin
{
    [self startConnectSocket];
    [self addAppStatusNotification];
    [self addNetworkingStatusNotification];
}

- (void)closeConnection
{
    if (_socketChannel) {
        [_socketChannel closeConnection];
        _socketChannel = NULL;
    }
}

/**
 启动连接Socket的入口
 */
- (void)startConnectSocket
{
    if (self.connectParam) {
        //如果获取到了端口参数
        NSLog(@"开始连接socket...");
        if (!self.socketChannel) {
            self.socketChannel = [[FGSocketChannelDefault alloc] initWithConnectParam:self.connectParam];
            self.socketChannel.heartbeatPacket = [[FGUpstreamPacket alloc] initWithPacketType:FGSocket_Msg_Heartbeat content:NULL];
            self.socketChannel.delegate = self;
        }
        [self.socketChannel openConnection];
    }
    else
    {
        //从服务器请求端口...
        if (!_hostRequesting) {
             NSLog(@"请求socket host...");
            [self requestSocketHostAddress];
        }
    }
}

// 请求获取socket服务器地址
- (void)requestSocketHostAddress
{
    //这里根据不同的需求产生了不同的业务逻辑代码
    //我们的逻辑是从服务器请求下host和port
    /*
     if(用户已经登录)
     {
         _hostRequesting = YES;
         网络请求成功的回调{
     
             self.connectParam = [[FGSocketConnectParam alloc] init];
             self.connectParam.host = host;
             self.connectParam.port = port;
             [self startConnectSocket];
     
         } 失败{
            [self reconnectSocket];
         }
     }
     */
}

- (void)reconnectSocket
{
    //如果失败了,5秒后再请求一次
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _hostRequesting = NO;
        [self startConnectSocket];
    });
}

#pragma mark -FGSocketChannelDelegate

- (void)channelOpened:(FGSocketChannel *)channel host:(NSString *)host port:(int)port
{
    /* 连接成功的逻辑 */
}

- (void)channelClosed:(FGSocketChannel *)channel error:(NSError *)error
{
    /* 连接失败的逻辑 */
}


- (void)channel:(FGSocketChannel *)channel received:(FGDownstreamPacket *)packet
{
    /* 在这里,根据协议号处理具体的业务逻辑... */
}

#pragma mark - Notification

/* 网络状态改变的处理... */
- (void)addNetworkingStatusNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveReachabilityChangedNotification:) name:kFGReachabilityChangedNotification object:NULL];
}

- (void)removeNetworkingStatusNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFGReachabilityChangedNotification object:NULL];
}

- (void)onReceiveReachabilityChangedNotification:(NSNotification *)notification
{
    if ([FGNetworkStatus shareNetworkStatus].isReachable){
        [self startConnectSocket];
    }
}

/* App前后台切换的处理... */
- (void)addAppStatusNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidChangeStatus:) name:UIApplicationDidEnterBackgroundNotification object:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidChangeStatus:) name:UIApplicationWillEnterForegroundNotification  object:NULL];
}

- (void)removeAppStatusNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:NULL];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:NULL];
}

- (void)handleApplicationDidChangeStatus:(NSNotification *)notification
{
    /* 前后台切换的要告诉服务器 */
}


#pragma mark - Packet

/**
 发送数据的统一入口...
 */
- (void)sendPacketWithPacketType:(FGSocketMsgType)packetType content:(NSDictionary *)content;
{
    NSLog(@"发送数据包类型:%zd 内容:%@",packetType,content);
    FGUpstreamPacket *authPacket = [[FGUpstreamPacket alloc] initWithPacketType:packetType content:content];
    [self.socketChannel asyncSendPacket:authPacket];
}


- (void)sendAtuh
{
    /*
         NSDictionary *content = @{
             组装数据
         };
         [self sendPacketWithPacketType:FGSocket_Msg_Auth content:content];
     */
}



@end
