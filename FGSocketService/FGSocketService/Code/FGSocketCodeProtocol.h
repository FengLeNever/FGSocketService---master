//
//  FGSocketCodeProtocol.h
//  PrizeClaw
//
//  Created by FengLe on 2017/9/29.
//  Copyright © 2017年 FengLe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FGSocketPacket.h"

/**
 *  数据解码后分发对象协议
 */
@protocol FGSocketDecoderOutputProtocol <NSObject>

@required

- (void)didDecode:(FGDownstreamPacket *)decodedPacket;

@end

@protocol FGSocketDecoderInputProtocol <NSObject>

@required
/**
 *  解码器
 *  @param downPacket 接收到的原始数据
 *  @param output     数据解码后，分发对象
 */
- (NSInteger)decodeDownPacket:(NSData *)downPacket output:(id<FGSocketDecoderOutputProtocol>)output;

@end


/**
 *  数据编码后分发对象协议
 */
@protocol FGSocketEncoderOutputProtocol <NSObject>

@required

- (void)didEncode:(NSData *)encodedData timeout:(NSInteger)timeout;

@end

@protocol FGSocketEncoderInputProtocol <NSObject>

@required
/**
 *  编码器
 *  @param upPacket 待发送的数据包
 *  @param output 数据编码后，分发对象
 */
- (void)encodeUpPacket:(FGUpstreamPacket *)upPacket output:(id<FGSocketEncoderOutputProtocol>)output;

@end
