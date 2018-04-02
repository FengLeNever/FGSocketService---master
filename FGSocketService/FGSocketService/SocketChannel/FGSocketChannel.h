//
//  FGSocketChannel.h
//  PrizeClaw
//
//  Created by FengLe on 2017/9/29.
//  Copyright © 2017年 FengLe. All rights reserved.
//

#import "FGSocketConnection.h"
#import "FGSocketPacket.h"

@class FGSocketChannel;


@protocol FGSocketChannelDelegate <NSObject>
@required

- (void)channelOpened:(FGSocketChannel *)channel host:(NSString *)host port:(int)port;
- (void)channelClosed:(FGSocketChannel *)channel error:(NSError *)error;
- (void)channel:(FGSocketChannel *)channel received:(FGDownstreamPacket *)packet;

@end

@interface FGSocketChannel : FGSocketConnection

@property (nonatomic, strong) FGUpstreamPacket *heartbeatPacket;

@property (nonatomic, weak) id<FGSocketChannelDelegate> delegate;

- (void)openConnection;
- (void)closeConnection;
- (void)asyncSendPacket:(FGUpstreamPacket *)packet;

@end
