//
//  BleProfile.h
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/12.
//

#import <Foundation/Foundation.h>
#import "BleUserDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface BleProfile : NSObject
+ (BleProfile*) getInstance;

@property (nonatomic, readonly) CBManagerState blePowerState;
@property (nonatomic) CBPeripheral* peripheral;

- (void) startScan:(UserScanCallback)scanCallback;

- (void) stopScan;

- (void) connectDevice: (CBPeripheral*)peripheral callback:(UserConnectedCallback)callback;

- (void) notifyPeripheral:(nonnull CBPeripheral *)peripheral
                notifyValue:(BOOL)isNotify
                 callback:(NotifyCallback)callback;


- (void) writePeripheral:(CBPeripheral*)peripheral valueData:(NSData *)valueData callback:(WriteDoneCallback)callback;

- (void) registerNotifyInd:(NotifyReceived)callback;

- (void) writeDeviceData:(NSData*)data callback:(nonnull WriteDoneCallback)callback;

@end

NS_ASSUME_NONNULL_END
