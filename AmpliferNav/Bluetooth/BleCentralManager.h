//
//  BleCentralManager.h
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/12.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^BleAdvFilterBlock)(NSString* deviceName);

typedef void (^ScanCallback)(CBCentralManager *central,CBPeripheral *peripheral,NSDictionary *advertisementData, NSNumber *RSSI);

typedef void (^ConnectedCallback)(BOOL isConnected);

typedef void (^DisconnectedCallback)(CBCentralManager* central, CBPeripheral *peripheral, NSError* error);

typedef void (^DiscoveryServiceCallback)(CBPeripheral *peripheral, NSError *error);

typedef void (^DiscoveryCharacteristicsCallback)(CBPeripheral *peripheral,CBService *service,NSError *error);

typedef void (^NotifyCallback)(CBPeripheral *peripheral, CBCharacteristic *ctic, NSError *error);

typedef void (^WriteDoneCallback)(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error);

typedef void (^ReadCharCallback)(CBPeripheral *,CBCharacteristic * nullable, NSError *);

typedef void (^NotifyReceived)(CBPeripheral *peripheral,CBCharacteristic *characteristic,NSError *error);

@interface BleCentralManager : NSObject
+ (BleCentralManager*)getInstance;

@property (nonatomic) CBManagerState blePowerState;

- (void)startScan:(ScanCallback)handler;
- (void)stopScan;

/*
 连接蓝牙从设备
 */
- (void)connectPeripheral:(nonnull CBPeripheral *)peripheral
                  options:(nullable NSDictionary<NSString *, id> *)options
        connectedCallback:(ConnectedCallback)connectedCallback;

/*
 发现设备上所有服务
 */
- (void) discoveryServices:(nonnull CBPeripheral *)peripheral discoveryCallback:(DiscoveryServiceCallback)discoveryCallback;

/*
 发现设备上某个服务
 */
- (void) discoveryService:(nonnull CBPeripheral *)peripheral serviceUUID:(nullable CBUUID*)serviceUUID discoveryCallback:(DiscoveryServiceCallback)discoveryCallback;

/*
 发现服务的属性
 */
- (void)discoverCharacteristics:(nullable NSArray<CBUUID *> *)characteristicUUIDs
                     forService:(nonnull CBService *)service
                   inPeripheral:(nonnull CBPeripheral *)peripheral
        callback:(nonnull DiscoveryCharacteristicsCallback)callback;

/*
 订阅服务
 */
- (void)notifyToPeripheral:(nonnull CBPeripheral *)peripheral
            characteristic:(nonnull CBUUID *)characteristicUUID
               notifyValue:(BOOL)isNotify
        callback:(NotifyCallback)callback;


/*
 往设备中写入数据
 */
- (void) writeToPeripheral:(CBPeripheral*)peripheral uuid:(CBUUID*)uuid  valueData:(NSData *)valueData callback:(WriteDoneCallback)callback;

/*
 读某个属性的值
 */
- (void) readToPeripheral:(CBPeripheral *)peripheral
              descriptor:(CBUUID *)characteristicUUID
callback:(ReadCharCallback)callback;

/*
 注册Notify的回调函数
 */
- (void) registerNotifyRecivedCallback:(NotifyReceived)callback;

/*
 注册断开连接的回调函数
 */
- (void) registerDisconnectedCallback:(DisconnectedCallback)callback;

@end


NS_ASSUME_NONNULL_END
