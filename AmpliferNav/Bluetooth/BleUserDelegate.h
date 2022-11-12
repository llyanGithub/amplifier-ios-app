//
//  BleUserDelegate.h
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/12.
//

#import <Foundation/Foundation.h>
#import "BleCentralManager.h"

NS_ASSUME_NONNULL_BEGIN

#define SERVICE_DISCOVERING     0x01
#define SERVICE_DISCOVERED      0x02
#define SERVICE_DISCOVER_FAIL   0x03

typedef void (^UserScanCallback)(CBPeripheral *peripheral,NSDictionary *advertisementData, NSNumber *RSSI, BOOL timeout);

typedef void (^UserConnectedCallback)(BOOL isConnected, NSUInteger serviceDiscoverEvent, CBPeripheral *peripheral);

@protocol BleUserDelegate <NSObject>

@required

- (void) startScan:(UserScanCallback)scanCallback;

- (void) stopScan;

- (void) connectDevice: (CBPeripheral*)peripheral callback:(UserConnectedCallback)callback;

- (void) notifyPeripheral:(nonnull CBPeripheral *)peripheral
                notifyValue:(BOOL)isNotify
                 callback:(NotifyCallback)callback;


- (void) writePeripheral:(CBPeripheral*)peripheral valueData:(NSData *)valueData callback:(WriteDoneCallback)callback;

- (void) registerNotifyInd:(NotifyReceived)callback;

@end

NS_ASSUME_NONNULL_END
