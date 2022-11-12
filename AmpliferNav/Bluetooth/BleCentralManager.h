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

typedef void (^DiscoveryServiceCallback)(CBPeripheral *peripheral, NSError *error);

typedef void (^DiscoveryCharacteristicsCallback)(CBPeripheral *peripheral,CBService *service,NSError *error);

typedef void (^NotifyCallback)(CBPeripheral *peripheral, CBCharacteristic *ctic, NSError *error);

@interface BleCentralManager : NSObject
+ (BleCentralManager*)getInstance;
- (void)startScan:(ScanCallback)handler;
- (void)stopScan;

/*
 连接蓝牙从设备
 */
- (void)connectPeripheral:(nonnull CBPeripheral *)peripheral
                  options:(nullable NSDictionary<NSString *, id> *)options
        connectedCallback:(ConnectedCallback)connectedCallback;

/*
 发现设备服务
 */
- (void) discoveryServices:(nonnull CBPeripheral *)peripheral discoveryCallback:(DiscoveryServiceCallback)discoveryCallback;


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

@end


NS_ASSUME_NONNULL_END
