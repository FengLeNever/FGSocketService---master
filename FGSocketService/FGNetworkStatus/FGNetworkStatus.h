//
//  FGNetworkStatus.h
//  LoveSeize
//
//  Created by FengLe on 2017/9/22.
//  Copyright © 2017年 FengLe. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kFGReachabilityChangedNotification;

typedef NS_ENUM(NSInteger, KFGNetworkModeStatus) {
    KFGNotReachable ,
    KFGReachableViaWiFi ,
    KFGReachableViaWWAN ,
};

@interface FGNetworkStatus : NSObject

+ (instancetype)shareNetworkStatus;
/**
 当前网络状态
 */
- (KFGNetworkModeStatus)currentNetworkStatus;
/**
 是否有网
 */
- (BOOL)isReachable;
/**
 具体的网络信息
 
 @return @"UnKnow" @"Wifi" @"NotReachable" @"2G" @"3G" @"4G"
 */
- (NSString *)specificNetworkMode;

@end
