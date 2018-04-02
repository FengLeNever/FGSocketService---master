//
//  FGSocketConnection.m
//  PrizeClaw
//
//  Created by FengLe on 2017/9/29.
//  Copyright © 2017年 FengLe. All rights reserved.
//

#import "FGSocketConnection.h"
#import <GCDAsyncSocket.h>

@interface FGSocketConnection ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;

@property (nonatomic, strong) dispatch_queue_t socketQueue;

@end

static void *IsOnSocketQueueOrTargetQueueKey;
char * const FGSocketQueueLabel = "com.socketQueue.FGSocketQueueLabel";
static const NSUInteger TimeOut = -1;

@implementation FGSocketConnection

- (void)dealloc
{
    NSLog(@" %@ - dealloc" ,NSStringFromClass([self class]));
}

- (instancetype)initWithConnectParam:(FGSocketConnectParam *)connectParam
{
    if (self = [super init]) {
        
        NSAssert(connectParam.host.length > 0, @"host is nil");
        NSAssert(connectParam.port > 0, @"port is 0");
        
        _connectParam = connectParam;
        _socketQueue = dispatch_queue_create(FGSocketQueueLabel, DISPATCH_QUEUE_SERIAL);
        IsOnSocketQueueOrTargetQueueKey = &IsOnSocketQueueOrTargetQueueKey;
        dispatch_queue_set_specific(_socketQueue, IsOnSocketQueueOrTargetQueueKey, (__bridge void *)self, NULL);
    }
    return self;
}

#pragma mark - queue

- (BOOL)isOnSocketQueue
{
    return dispatch_get_specific(IsOnSocketQueueOrTargetQueueKey) != NULL;
}

- (void)dispatchOnSocketQueue:(dispatch_block_t)block async:(BOOL)async
{
    if ([self isOnSocketQueue]) {
        @autoreleasepool {
            block();
        }
        return;
    }
    if (async) {
        dispatch_async([self socketQueue], ^{
            @autoreleasepool {
                block();
            }
        });
        return;
    }
    dispatch_sync([self socketQueue], ^{
        @autoreleasepool {
            block();
        }
    });
}

#pragma connect


- (void)contect
{
    if ([self isConnected]) return;
    @weakify(self)
    [self dispatchOnSocketQueue:^{
        @strongify(self)
        [self disconnect];
        
        self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.socketQueue];
        [self.asyncSocket setIPv4PreferredOverIPv6:NO];
        
        NSError *error = nil;
        [self.asyncSocket connectToHost:_connectParam.host onPort:_connectParam.port withTimeout:_connectParam.timeout error:&error];
        if (error) {
            [self didDisconnect:self withError:error];
        }
    } async:YES];
}

// 异步
- (void)disconnect
{
    @weakify(self)
    [self dispatchOnSocketQueue:^{
        @strongify(self)
        if (NULL == self.asyncSocket) return;
        [self.asyncSocket disconnect];
        self.asyncSocket.delegate = NULL;
        self.asyncSocket = NULL;
    } async:YES];
}

- (BOOL)isConnected
{
    __block BOOL result = NO;
    __weak typeof(self) weakSelf = self;
    [self dispatchOnSocketQueue:^{
        result = [weakSelf.asyncSocket isConnected];
    } async:NO];
    return result;
}

#pragma mark - FGSocketConnectionDelegate

- (void)didConnect:(id<FGSocketConnectionDelegate>)con toHost:(NSString *)host port:(uint16_t)port
{
}


- (void)didDisconnect:(id<FGSocketConnectionDelegate>)con withError:(NSError *)err
{
}

- (void)didRead:(id<FGSocketConnectionDelegate>)con withData:(NSData *)data tag:(long)tag
{
}

#pragma mark - write

- (void)writeData:(NSData *)data timeout:(NSTimeInterval)timeout
{
    @weakify(self)
    [self dispatchOnSocketQueue:^{
        @strongify(self)
        [self.asyncSocket writeData:data withTimeout:timeout tag:10086];
    } async:YES];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
     NSLog(@"socket连接成功");
    [self didConnect:self toHost:host port:port];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"socket连接失败...error: %@", err.description);
    [self didDisconnect:self withError:err];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"socket收到数据...length: %lu, tag: %ld", (unsigned long)data.length, tag);
    [self didRead:self withData:data tag:tag];
    [sock readDataWithTimeout:TimeOut tag:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"socket写入数据...Tag: %ld", tag);
    [sock readDataWithTimeout:TimeOut tag:tag];
}
@end
