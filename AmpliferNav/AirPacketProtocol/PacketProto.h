//
//  PacketProto.h
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define AXON_ANC_NORMAL  0x00
#define AXON_ANC_OUTER   0x02

#define AXON_MODE_OUTDOOR  0x01
#define AXON_MODE_INDOOR   0x02
#define AXON_MODE_NORMAL   0x03

#define AXON_COMMAND_QUERY_DEVICE           (0x01)
#define AXON_COMMAND_ANC_SWITCH             (0x02)
#define AXON_COMMAND_QUERY_ANC              (0x03)
#define AXON_COMMAND_QUERY_SOUND            (0x04)
#define AXON_COMMAND_MODE_SELECTION         (0x05)
#define AXON_COMMAND_CONTROL_VOLUME         (0x06)
#define AXON_COMMAND_SET_FREQ               (0x07)
#define AXON_COMMAND_EAR_PROTECT_SET        (0x08)

typedef unsigned char byte;

typedef void (^RxHandler) (NSUInteger cmdId, NSData* payload);

@interface PacketProto : NSObject

@property (nonatomic) NSUInteger ancState;
@property (nonatomic) NSUInteger mode;
@property (nonatomic) NSUInteger leftVolume;
@property (nonatomic) NSUInteger rightVolume;
@property (nonatomic) NSData* leftFreqs;
@property (nonatomic) NSData* rightFreqs;
@property (nonatomic) NSUInteger leftMode;
@property (nonatomic) NSUInteger rightMode;

@property (nonatomic, readonly) NSUInteger errCode;
@property (nonatomic, readonly) BOOL isTwsConnected;
@property (nonatomic, readonly) NSData* leftEarVersiion;
@property (nonatomic, readonly) NSData* rightEarVersion;
@property (nonatomic, readonly) NSUInteger leftEarBattery;
@property (nonatomic, readonly) NSUInteger rightEarBattery;

+ (PacketProto*)getInstance;

/*
 * 解析收到的数据包
 */
- (void) parseReceviedPacket:(NSData*)data compeletionHandler:(RxHandler)handler;

/**
 * 查询设备信息
*/
- (NSData*) packInfoQuery;
/**
 * ANC状态切换指令 %s 1个byte
*/
- (NSData*) packAncSwitch;
/**
 * 查询当前ANC状态指令
*/
- (NSData*) packAncStateQuery;

/**
 * 查询声音控制参数指令
 */
- (NSData*) packVolumeStateQuery;

/**
 * 声音控制-模式选择指令 %s 0.5个byte
 */

- (NSData*) packVolumeModeSet;

/**
 * 声音控制-音量控制指令 %s 1个byte
 */
- (NSData*) packVolumeControl;

/**
 * 声音控制-频段调节指令 %s 5个byte
 */
- (NSData*) packFreqSet;

/**
 * 声音控制-护耳设置指令 %s 1个byte
 */

- (NSData*) packEarProtectModeSet;

/**
 * 进入DUT模式的指令
 */

- (NSData*) packDutModeSet;

/**
 * 恢复出厂设置的指令
 */

- (NSData*) packFactoryModeSet;

/**
 * 进入OTA模式的指令
 */

- (NSData*) packOtaModeSet;

/**
 * 进入单耳模式的指令
 */
- (NSData*) packSingleEarModeSet;

@end

NS_ASSUME_NONNULL_END
