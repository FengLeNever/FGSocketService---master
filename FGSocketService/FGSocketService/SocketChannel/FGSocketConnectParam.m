//
//  FGSocketConnectParam.m
//  LoveSeize
//
//  Created by FengLe on 2017/9/22.
//  Copyright © 2017年 FengLe. All rights reserved.
//

#import "FGSocketConnectParam.h"

@implementation FGSocketConnectParam

- (instancetype)init
{
    if (self = [super init]) {
        _host = nil;
        _port = 0;
        _imToken = nil;
        _timeout = 15;
        _heartbeatEnabled = YES;
        _heartbeatInterval = 30;
        _autoReconnect = YES;
        _connectMaxCount = 100;
        _connectInterval = 5;
    }
    return self;
}

@end
