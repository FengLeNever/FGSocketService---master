//
//  FGSocketPacketDecode.m
//  PrizeClaw
//
//  Created by FengLe on 2017/9/29.
//  Copyright © 2017年 FengLe. All rights reserved.
//

#import "FGSocketPacketDecode.h"

@interface FGSocketPacketDecode ()

/**
 包长度数据的字节个数，默认为2
 */
@property (nonatomic, assign) int countOMMengthByte;
/**
 *  应用协议中允许发送的最大数据块大小，默认为65536
 */
@property (nonatomic, assign) NSUInteger maxFrameSize;

@end

@implementation FGSocketPacketDecode

- (instancetype)init
{
    if (self = [super init]) {
        _countOMMengthByte = 2;
        _maxFrameSize = 65536;
    }
    return self;
}

- (NSInteger)decodeDownPacket:(NSData *)downPacket output:(id<FGSocketDecoderOutputProtocol>)output
{
    // 读取数据的下标
    NSUInteger headIndex = 0;
    while (!kDataIsEmpty(downPacket) && downPacket.length > _countOMMengthByte + headIndex) {
        // 包长度
        NSInteger dataLength = 0;
        [downPacket getBytes:&dataLength range:NSMakeRange(headIndex, _countOMMengthByte)];
        dataLength = ntohs(dataLength);
        NSAssert(dataLength + _countOMMengthByte < _maxFrameSize, @"DecodeData Length Too Long ...");
        // 数据不是完整的数据包，则break继续读取等待
        if (downPacket.length - headIndex < dataLength + _countOMMengthByte) {
            break;
        }
        NSData *packetData = [downPacket subdataWithRange:NSMakeRange(headIndex + _countOMMengthByte, dataLength)];
        FGDownstreamPacket *downPacket = [[FGDownstreamPacket alloc] initWithData:packetData];
        [output didDecode:downPacket];
        headIndex += packetData.length + _countOMMengthByte;
    }
    return headIndex;
}


@end
