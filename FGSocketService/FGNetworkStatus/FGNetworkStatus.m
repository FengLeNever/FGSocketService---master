//
//  FGNetworkStatus.m
//  LoveSeize
//
//  Created by FengLe on 2017/9/22.
//  Copyright © 2017年 FengLe. All rights reserved.
//

#import "FGNetworkStatus.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "Reachability.h"

@interface FGNetworkStatus ()
/**
 网络状态
 */
@property (nonatomic, strong) Reachability *reachability;
/**
 2G数组
 */
@property (nonatomic,strong) NSArray *technology2GArray;
/**
 3G数组
 */
@property (nonatomic,strong) NSArray *technology3GArray;
/**
 4G数组
 */
@property (nonatomic,strong) NSArray *technology4GArray;
/**
 网络状态描述
 */
@property (nonatomic, strong) CTTelephonyNetworkInfo *networkInfo;

@end

NSString * const kFGReachabilityChangedNotification = @"kFGReachabilityChangedNotification";

@implementation FGNetworkStatus

+ (instancetype)shareNetworkStatus
{
    static FGNetworkStatus *instance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[[self class] alloc] init];
        }
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self.reachability startNotifier];
        [self addNetworkingStatusNotification];
    }
    return self;
}

- (void)addNetworkingStatusNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveReachabilityChangedNotification:) name:kReachabilityChangedNotification object:nil]; 
}

- (void)receiveReachabilityChangedNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kFGReachabilityChangedNotification object:NULL];
}

- (KFGNetworkModeStatus)currentNetworkStatus
{
    NetworkStatus status = self.reachability.currentReachabilityStatus;
    switch (status) {
        case NotReachable:
            return KFGNotReachable;
            break;
        case ReachableViaWiFi:
            return KFGReachableViaWiFi;
            break;
        case ReachableViaWWAN:
            return KFGReachableViaWWAN;
            break;
        default:
            return KFGNotReachable;
            break;
    }
}

- (BOOL)isReachable
{
    return [self.reachability currentReachabilityStatus] != NotReachable;
}

/**
 获取具体网络状态
 */
- (NSString *)specificNetworkMode
{
    Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    NetworkStatus status = [r currentReachabilityStatus];
    if (status == NotReachable)
    {
        return @"NotReachable";
    }
    else if(status == ReachableViaWiFi)
    {
        return @"Wifi";
    }
    //获取当前网络描述
    NSString *currentStatus = self.networkInfo.currentRadioAccessTechnology;
    if ([self.technology2GArray containsObject:currentStatus]) {
        return @"2G";
    }
    else if ([self.technology3GArray containsObject:currentStatus])
    {
        return @"3G";
    }
    else if ([self.technology4GArray containsObject:currentStatus])
    {
        return @"4G";
    }
    return @"Unkonw";
}

#pragma mark - 懒加载

- (Reachability *)reachability{
    if (!_reachability) {
        _reachability = [Reachability reachabilityForInternetConnection];
    }
    return _reachability;
}

- (CTTelephonyNetworkInfo *)networkInfo
{
    if (!_networkInfo) {
        _networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    }
    return _networkInfo;
}
/**
 2G识别数组
 */
- (NSArray *)technology2GArray{
    if(!_technology2GArray){
        _technology2GArray = @[CTRadioAccessTechnologyEdge,
                               CTRadioAccessTechnologyGPRS,
                               CTRadioAccessTechnologyEdge];
    }
    return _technology2GArray;
}

/**
 3G识别数组
 */
-(NSArray *)technology3GArray{
    if(!_technology3GArray){
        _technology3GArray = @[CTRadioAccessTechnologyHSDPA,
                               CTRadioAccessTechnologyWCDMA,
                               CTRadioAccessTechnologyHSUPA,
                               CTRadioAccessTechnologyCDMA1x,
                               CTRadioAccessTechnologyCDMAEVDORev0,
                               CTRadioAccessTechnologyCDMAEVDORevA,
                               CTRadioAccessTechnologyCDMAEVDORevB,
                               CTRadioAccessTechnologyeHRPD];
    }
    return _technology3GArray;
}

/**
 4G识别数组
 */
-(NSArray *)technology4GArray{
    if(!_technology4GArray){
        _technology4GArray = @[CTRadioAccessTechnologyLTE];
    }
    return _technology4GArray;
}

@end
