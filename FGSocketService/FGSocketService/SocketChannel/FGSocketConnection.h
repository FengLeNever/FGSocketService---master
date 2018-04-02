//
//  FGSocketConnection.h
//  PrizeClaw
//
//  Created by FengLe on 2017/9/29.
//  Copyright © 2017年 FengLe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FGSocketConnectParam.h"
#import "FGSocketConnectionDelegate.h"
/**
 *  socket网络连接对象，只负责socket网络的连接通信，内部使用GCDAsyncSocket。
 *  1-只公开GCDAsyncSocket的主要方法，增加使用的便捷性。
 *  2-封装的另一个目的是，易于后续更新调整。如果不想使用GCDAsyncSocket，只想修改内部实现即可，对外不产生影响。
 */

@interface FGSocketConnection : NSObject<FGSocketConnectionDelegate>

@property (nonatomic, strong) FGSocketConnectParam *connectParam;

- (instancetype)initWithConnectParam:(FGSocketConnectParam *)connectParam;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (void)dispatchOnSocketQueue:(dispatch_block_t)block async:(BOOL)async;

@end
