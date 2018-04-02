//
//  FGSocketChannel.m
//  PrizeClaw
//
//  Created by FengLe on 2017/9/29.
//  Copyright © 2017年 FengLe. All rights reserved.
//

#import "FGSocketChannel.h"
#import "FGSocketCodeProtocol.h"
#import "FGSocketPacketDecode.h"
#import "FGSocketPacketEncode.h"


@interface FGSocketChannel()<FGSocketDecoderOutputProtocol,FGSocketEncoderOutputProtocol>

@property (nonatomic, strong, readonly) NSMutableData *receiveDataBuffer;
/**
 心跳定时器
 */
@property (nonatomic, strong) dispatch_source_t heartbeatTimer;

@property (nonatomic, strong) dispatch_semaphore_t socketLock;

@property (nonatomic, strong) FGSocketPacketDecode *dataDecoder;

@property (nonatomic, strong) FGSocketPacketEncode *dataEncoder;

@end

@implementation FGSocketChannel

- (void)dealloc
{
    NSLog(@" %@ - dealloc" ,NSStringFromClass([self class]));
}

- (instancetype)initWithConnectParam:(FGSocketConnectParam *)connectParam
{
    if (self = [super initWithConnectParam:connectParam]) {
        _receiveDataBuffer = [[NSMutableData alloc] init];
        _socketLock = dispatch_semaphore_create(1);
        _dataDecoder = [[FGSocketPacketDecode alloc] init];
        _dataEncoder = [[FGSocketPacketEncode alloc] init];
    }
    return self;
}

- (void)openConnection
{
    if ([self isConnected]) return;
    [self closeConnection];
    [self stopHeartbeatTimer];
    [self contect];
}

- (void)closeConnection
{
    [self disconnect];
    [self stopHeartbeatTimer];
}

- (void)asyncSendPacket:(FGUpstreamPacket *)packet
{
    if (nil == packet) {
        NSLog(@"Warning: RHSocket asyncSendPacket packet is nil ...");
        return;
    };
    @weakify(self)
    [self dispatchOnSocketQueue:^{
        @strongify(self)
        [self.dataEncoder encodeUpPacket:packet output:self];
    } async:YES];
}
#pragma mark - FGSocketConnectionDelegate

- (void)didConnect:(id<FGSocketConnectionDelegate>)con toHost:(NSString *)host port:(uint16_t)port
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(channelOpened:host:port:)]) {
        dispatch_async_on_main_queue(^{
            [self.delegate channelOpened:self host:host port:port];
        });
    }
}

- (void)didDisconnect:(id<FGSocketConnectionDelegate>)con withError:(NSError *)err
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(channelClosed:error:)]) {
        dispatch_async_on_main_queue(^{
            [self.delegate channelClosed:self error:err];
        });
    }
    [self stopHeartbeatTimer];
}

- (void)didRead:(id<FGSocketConnectionDelegate>)con withData:(NSData *)data tag:(long)tag
{
    if (kDataIsEmpty(data)) return;
    dispatch_semaphore_wait(self.socketLock, DISPATCH_TIME_FOREVER);
    [self.receiveDataBuffer appendData:data];
    NSData *responseData = [NSData dataWithData:self.receiveDataBuffer];
    NSInteger decodedLength = [self.dataDecoder decodeDownPacket:responseData output:self];
    if (decodedLength < 0) {
        [self closeConnection];
        NSLog(@"decodedLength < 0 ... decodData Fail");
        return;
    }
    if (decodedLength > 0) {
        NSUInteger remainLength = self.receiveDataBuffer.length - decodedLength;
        NSData *remainData = [_receiveDataBuffer subdataWithRange:NSMakeRange(decodedLength, remainLength)];
        [self.receiveDataBuffer setData:remainData];
    }
    dispatch_semaphore_signal(self.socketLock);
}

#pragma mark - 心跳包

// 发送心跳包
- (void)startHeartbeatTimer
{
    [self stopHeartbeatTimer];
    self.heartbeatTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.heartbeatTimer, dispatch_walltime(NULL, 0), self.connectParam.heartbeatInterval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.heartbeatTimer, ^{
        if (![self isConnected]) {
            [self stopHeartbeatTimer];
            return;
        }
        [self asyncSendPacket:self.heartbeatPacket];
    });
    dispatch_resume(self.heartbeatTimer);
}

// 停止心跳
- (void)stopHeartbeatTimer
{
    if (_heartbeatTimer)
    {
        dispatch_cancel(_heartbeatTimer);
        _heartbeatTimer = NULL;
    }
}

#pragma mark -FGSocketProtocol

-(void)didDecode:(FGDownstreamPacket *)decodedPacket
{
    if (decodedPacket.packetType == FGSocket_Msg_HostHeartbeat) return;
     NSLog(@"收到..packetType CMD...%zd packetDict:%@",decodedPacket.packetType,decodedPacket.packetDict);
    if (decodedPacket.packetType == FGSocket_Msg_HostAuth) {
        //开启心跳包
        [self startHeartbeatTimer];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(channel:received:)]) {
        dispatch_async_on_main_queue(^{
            [self.delegate channel:self received:decodedPacket];
        });
    }
}

- (void)didEncode:(NSData *)encodedData timeout:(NSInteger)timeout
{
    if (kDataIsEmpty(encodedData)) {
        return;
    }
    [self writeData:encodedData timeout:timeout];
}

@end
