//
//  FGSocketChannelDefault.m
//  PrizeClaw
//
//  Created by FengLe on 2017/9/29.
//  Copyright © 2017年 FengLe. All rights reserved.
//

#import "FGSocketChannelDefault.h"
@interface FGSocketChannelDefault ()
{
    // 记录重连的次数,默认最大为重连一百次
    NSInteger _connectCount;
    // 重连时间间隔
    NSTimeInterval _connectInterval;
}

/**
 重连定时器
 */
@property (nonatomic, strong) dispatch_source_t reconnectTimer;

@end

@implementation FGSocketChannelDefault

- (instancetype)initWithConnectParam:(FGSocketConnectParam *)connectParam
{
    if (self = [super initWithConnectParam:connectParam]) {
        [self resetConnectData];
    }
    return self;
}

- (void)openConnection
{
    [super openConnection];
    [self stopReconnectTimer];
}

- (void)closeConnection
{
    [super closeConnection];
    [self stopReconnectTimer];
}

- (void)didConnect:(id<FGSocketConnectionDelegate>)con toHost:(NSString *)host port:(uint16_t)port
{
    [self stopReconnectTimer];
    [self resetConnectData];
    [super didConnect:con toHost:host port:port];
}

- (void)didDisconnect:(id<FGSocketConnectionDelegate>)con withError:(NSError *)err
{
    if ([self isCanReconnectSocket] && !_reconnectTimer) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_connectInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startReconnectTimer:_connectInterval];
        });
    }
    [super didDisconnect:con withError:err];
}

- (void)resetConnectData
{
    // 充值参数
    _connectCount = 0;
    _connectInterval = self.connectParam.connectInterval;
}

#pragma mark - 重连
/**
 重连定时器
 */
- (void)startReconnectTimer:(NSTimeInterval)interval
{
    NSLog(@"想要开启重连...");
    [self stopReconnectTimer];
    if (![self isCanReconnectSocket]) return;
    
    NSTimeInterval minInterval = MAX(5, interval);
    self.reconnectTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.reconnectTimer, dispatch_walltime(NULL, 0), minInterval * NSEC_PER_SEC, 0);
    @weakify(self)
    dispatch_source_set_event_handler(self.reconnectTimer, ^{
        @strongify(self)
        [self reconnectTimerFunction];
    });
    dispatch_resume(self.reconnectTimer);
}

- (void)reconnectTimerFunction
{
    NSLog(@"1.开启重连....");
    if (![self isCanReconnectSocket]) {
        [self stopReconnectTimer];
        return;
    }
    NSLog(@"2.开启重连....");
    _connectCount++;
    if (_connectCount % 10 == 0) {
        _connectInterval += self.connectParam.connectInterval;
        NSLog(@"3.开启重连....");
        [self startReconnectTimer:_connectInterval];
    }
    NSLog(@"4.开启重连....");
    [self openConnection];
}

- (void)stopReconnectTimer
{
    if (_reconnectTimer) {
        dispatch_source_cancel(_reconnectTimer);
        _reconnectTimer = NULL;
    }
}

- (BOOL)isCanReconnectSocket
{
    return (![self isConnected] && self.connectParam.autoReconnect && [FGNetworkStatus shareNetworkStatus].isReachable && _connectCount < self.connectParam.connectMaxCount);
}


@end
