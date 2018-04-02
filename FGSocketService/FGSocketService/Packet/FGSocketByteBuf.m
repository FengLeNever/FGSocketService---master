//
//  RHSocketByteBuf.m
//  Example
//
//  Created by zhuruhong on 16/8/19.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "FGSocketByteBuf.h"

@implementation FGSocketByteBuf

- (instancetype)init
{
    if (self = [super init]) {
        _buffer = [[NSMutableData alloc] init];
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data
{
    if (self = [super init]) {
        _buffer = [[NSMutableData alloc] initWithData:data];
    }
    return self;
}

- (NSData *)data
{
    return _buffer;
}

- (NSUInteger)length
{
    return _buffer.length;
}

- (void)clear
{
    _buffer = [[NSMutableData alloc] init];
}

@end

static NSInteger ByteLength     = 1;
static NSInteger ShortLength    = 2;
static NSInteger IntLength      = 4;
static NSInteger LongLength     = 8;


@implementation FGSocketByteBuf (NSInteger)

- (void)writeInt8:(int8_t)param
{
    [_buffer appendBytes:&param length:ByteLength];
}

- (void)writeInt16:(int16_t)param useHost:(BOOL)isUse
{
    param = isUse ? HTONS(param) : param;
    [_buffer appendBytes:&param length:ShortLength];
}

- (void)writeInt32:(int32_t)param useHost:(BOOL)isUse
{
    param = isUse ? HTONL(param) : param;
    [_buffer appendBytes:&param length:IntLength];
}

- (void)writeInt64:(int64_t)param
{
    [_buffer appendBytes:&param length:LongLength];
}

- (int8_t)readInt8:(NSUInteger)index
{
    NSAssert(index + 1 <= _buffer.length, @"index > _buffer.length");
    
    int8_t val = 0;
    [_buffer getBytes:&val range:NSMakeRange(index, ByteLength)];
    return val;
}

- (int16_t)readInt16:(NSUInteger)index
{
    NSAssert(index + 2 <= _buffer.length, @"index > _buffer.length");
    
    int16_t val = 0;
    [_buffer getBytes:&val range:NSMakeRange(index, ShortLength)];
    return val;
}

- (int32_t)readInt32:(NSUInteger)index useHost:(BOOL)isUse
{
    NSAssert(index + 4 <= _buffer.length, @"index > _buffer.length");
    
    int32_t val = 0;
    [_buffer getBytes:&val range:NSMakeRange(index, IntLength)];
    return !isUse ? val : (NTOHL(val));
}

- (int64_t)readInt64:(NSUInteger)index
{
    NSAssert(index + 8 <= _buffer.length, @"index > _buffer.length");
    
    int64_t val = 0;
    [_buffer getBytes:&val range:NSMakeRange(index, LongLength)];
    return val;
}

@end

@implementation FGSocketByteBuf (NSData)

- (void)writeData:(NSData *)param
{
    if (param.length == 0) {
        return;
    }
    [_buffer appendData:param];
}

- (NSData *)readData:(NSUInteger)index length:(NSUInteger)length
{
    NSAssert(index + length <= _buffer.length, @"index > _buffer.length");
    
    NSRange range = NSMakeRange(index, length);
    NSData *temp = [_buffer subdataWithRange:range];
    return temp;
}

@end

@implementation FGSocketByteBuf (NSString)

- (void)writeString:(NSString *)param
{
    if (param.length == 0) {
        return;
    }

    [_buffer appendBytes:param.UTF8String length:param.length];
}

- (NSString *)readString:(NSUInteger)index length:(NSUInteger)length
{
    NSAssert(index + length <= _buffer.length, @"index > _buffer.length");
    
    NSData *tempData = [self readData:index length:length];
    NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
    return tempStr;
}

@end
