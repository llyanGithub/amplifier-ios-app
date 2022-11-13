//
//  PacketProto.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/13.
//

#import "PacketProto.h"

@implementation PacketProto

+ (PacketProto*)getInstance
{
    static dispatch_once_t predWex = 0;
    __strong static id _sharedWexObject = nil;
    dispatch_once(&predWex, ^
                  {
                      _sharedWexObject = [[self alloc] init];
                  });
    return _sharedWexObject;
}

- (instancetype)init
{
    self = [super init];
    
    self.leftFreqs = [NSData data];
    self.rightFreqs = [NSData data];
    
    return self;
}

- (unsigned short) crc16:(NSData*)data
{
    unsigned short crc = 0xFFFF;  //init crc is 0xffff
    byte* buffer = (byte*)data.bytes;
    unsigned char size = data.length;

    while (size--) {
        crc = (crc >> 8) | (crc << 8);
        crc ^= *buffer++;
        crc ^= ((unsigned char) crc) >> 4;
        crc ^= crc << 12;
        crc ^= (crc & 0xFF) << 5;
    }
    
    return crc;
}

- (void) addCrc16Value:(unsigned char*) buffer totalLen:(int)totalLen
{
    NSData* validateData = [[NSData alloc] initWithBytes:buffer length:totalLen-2];
    unsigned short crc = [self crc16:validateData];
    
    buffer[totalLen-2] = (crc&0xFF00)>>8;
    buffer[totalLen-1] = crc&0x00FF;
}

/*
 * 解析收到的数据包
 */
- (void) parseReceviedPacket:(NSData*)data compeletionHandler:(RxHandler)handler
{
    NSData* cmdHeader = [data subdataWithRange: NSMakeRange(0, 2)];
    byte* bytes = (byte*)data.bytes;
    NSUInteger totalLen = data.length;
    unsigned short index = 0;
    NSUInteger cmdId = bytes[1];
    unsigned short crc = bytes[totalLen-1] | (bytes[totalLen-2] << 8);
    NSUInteger payloadLength = (bytes[2]<<8)| bytes[3];
    NSData* payload = [data subdataWithRange: NSMakeRange(4, payloadLength)];
    
    NSData* validateData = [data subdataWithRange: NSMakeRange(0, totalLen - 2)];
    
    PacketInfo packetInfo;
    
//    NSLog(@"checksum: 0x%04x", [self crc16:validateData]);
    
    if (crc == [self crc16:validateData]) {
        NSLog(@"crc validate pass");
    } else {
        NSLog(@"crc validate FAIL");
        return;
    }
    
//    NSLog(@"header: %@", cmdHeader);
//    NSLog(@"payload: %@", payload);
    
    unsigned char* payloadBuff = (unsigned char*)payload.bytes;
    switch (cmdId) {
        case AXON_COMMAND_QUERY_DEVICE:
            packetInfo.errCode = payloadBuff[index++];
            packetInfo.isTwsConnected = payloadBuff[index++];
            memcpy(packetInfo.rightEarVerson, payloadBuff+index, 4);
            index += 4;
            memcpy(packetInfo.leftEarVerson, payloadBuff+index, 4);
            index += 4;
            packetInfo.rightEarBattery = payloadBuff[index++];
            packetInfo.leftEarBattery = payloadBuff[index++];
            
            break;
            
        default:
            break;
    }
    
    if (handler) {
        handler(cmdId, payload, &packetInfo);
    }
}

/**
 * 查询设备信息
*/
- (NSData*) packInfoQuery
{
    byte cmd[6] = {0xFE, 0x01, 0x00, 0x00, 0x00, 0x00};
    
    [self addCrc16Value:cmd totalLen:sizeof(cmd)];
    NSData* data = [NSData dataWithBytes:cmd length:sizeof(cmd)];
    
    return data;
}
/**
 * ANC状态切换指令 %s 1个byte
*/
- (NSData*) packAncSwitch
{
    byte cmd[] = {0xFE, 0x02, 0x00, 0x01, 0x00, 0x00, 0x00};
    cmd[4] = (byte)self.ancState;
    
    [self addCrc16Value:cmd totalLen:sizeof(cmd)];
    NSData* data = [NSData dataWithBytes:cmd length:sizeof(cmd)];
    return data;
}
/**
 * 查询当前ANC状态指令
*/
- (NSData*) packAncStateQuery
{
    byte cmd[] = {0xFE, 0x03, 0x00, 0x00, 0x00, 0x00};
    
    [self addCrc16Value:cmd totalLen:sizeof(cmd)];
    
    NSData* data = [NSData dataWithBytes:cmd length:sizeof(cmd)];
    return data;
}

/**
 * 查询声音控制参数指令
 */
- (NSData*) packVolumeStateQuery
{
    byte cmd[] = {0xFE, 0x04, 0x00, 0x00, 0x00, 0x00};
    
    [self addCrc16Value:cmd totalLen:sizeof(cmd)];
    
    NSData* data = [NSData dataWithBytes:cmd length:sizeof(cmd)];
    return data;
}

/**
 * 声音控制-模式选择指令 %s 0.5个byte
 */

- (NSData*) packVolumeModeSet
{
    byte cmd[5] = {0xFE, 0x05, 0x00, 0x01, 0x00, 0x00, 0x00};
    cmd[4] = (byte)self.mode;
    
    [self addCrc16Value:cmd totalLen:sizeof(cmd)];
    
    NSData* data = [NSData dataWithBytes:cmd length:sizeof(cmd)];
    return data;
}

/**
 * 声音控制-音量控制指令 %s 1个byte
 */
- (NSData*) packVolumeControl
{
    byte cmd[] = {0xFE, 0x06, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00};
    cmd[4] = (byte)self.leftVolume;
    cmd[5] = (byte)self.rightVolume;
    
    [self addCrc16Value:cmd totalLen:sizeof(cmd)];
    
    NSData* data = [NSData dataWithBytes:cmd length:sizeof(cmd)];
    return data;
}

/**
 * 声音控制-频段调节指令 %s 5个byte
 */
- (NSData*) packFreqSet;
{
    byte cmd[] = {0xFE, 0x07, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    byte* leftFreqs = (byte*)self.leftFreqs.bytes;
    byte* rightFreqs = (byte*)self.rightFreqs.bytes;
    

    memcpy(cmd+4, leftFreqs, 5);
    memcpy(cmd+9, rightFreqs, 5);
    
    [self addCrc16Value:cmd totalLen:sizeof(cmd)];
    
    NSData* data = [NSData dataWithBytes:cmd length:sizeof(cmd)];
    return data;
}

/**
 * 声音控制-护耳设置指令 %s 1个byte
 */

- (NSData*) packEarProtectModeSet
{
    byte cmd[] = {0xFE, 0x08, 0x00, 0x01, 0x00, 0x00, 0x00};
    byte mode = (self.leftMode<<4) | self.rightMode;
    cmd[4] = (byte)mode;
    
    [self addCrc16Value:cmd totalLen:sizeof(cmd)];
    
    NSData* data = [NSData dataWithBytes:cmd length:sizeof(cmd)];
    return data;
}

/**
 * 进入DUT模式的指令
 */

- (NSData*) packDutModeSet
{
    byte cmd[] = {0xFE, 0x09, 0x00, 0x00, 0x00, 0x00};
    
    [self addCrc16Value:cmd totalLen:sizeof(cmd)];
    
    NSData* data = [NSData dataWithBytes:cmd length:sizeof(cmd)];
    return data;
}

/**
 * 恢复出厂设置的指令
 */

- (NSData*) packFactoryModeSet
{
    byte cmd[] = {0xFE, 0x0A, 0x00, 0x00, 0x00, 0x00};
    
    [self addCrc16Value:cmd totalLen:sizeof(cmd)];
    
    NSData* data = [NSData dataWithBytes:cmd length:sizeof(cmd)];
    return data;
}

/**
 * 进入OTA模式的指令
 */

- (NSData*) packOtaModeSet
{
    byte cmd[] = {0xFE, 0x0B, 0x00, 0x00, 0x00, 0x00};
    
    [self addCrc16Value:cmd totalLen:sizeof(cmd)];
    
    NSData* data = [NSData dataWithBytes:cmd length:sizeof(cmd)];
    return data;
}

/**
 * 进入单耳模式的指令
 */
- (NSData*) packSingleEarModeSet
{
    byte cmd[] = {0xFE, 0x0C, 0x00, 0x00, 0x00, 0x00};
    
    [self addCrc16Value:cmd totalLen:sizeof(cmd)];
    
    NSData* data = [NSData dataWithBytes:cmd length:sizeof(cmd)];
    return data;
}

@end
