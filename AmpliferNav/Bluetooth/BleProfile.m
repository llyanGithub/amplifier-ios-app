//
//  BleProfile.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/12.
//

#import "BleProfile.h"


@interface BleProfile () <BleUserDelegate>

@property (nonatomic) BleCentralManager* bleCentralManager;
@property (nonatomic) NSTimer* scanTimer;

@property (nonatomic) CBUUID* serviceUUID;
@property (nonatomic) CBUUID* txUUID;
@property (nonatomic) CBUUID* rxUUID;

@property (nonatomic) NSUInteger scanDuration;
@property (nonatomic) NSString* deviceName;

@property (nonatomic) NSMutableArray* scanDeviceArray;

@property (nonatomic) UserScanCallback scanCallback;
@property (nonatomic) UserConnectedCallback connectedCallback;

@end

@implementation BleProfile

+ (BleProfile*) getInstance
{
    static dispatch_once_t predWex = 0;
    __strong static BleProfile* _sharedWexObject = nil;
    dispatch_once(&predWex, ^
                  {
                      _sharedWexObject = [[self alloc] init];
                  });
    return _sharedWexObject;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.bleCentralManager = [BleCentralManager getInstance];
        self.serviceUUID = [CBUUID UUIDWithString:@"55AA0001-B5A3-F393-E0A9-E50E24DCCA9E"];
        self.txUUID = [CBUUID UUIDWithString:@"55AA0002-B5A3-F393-E0A9-E50E24DCCA9E"];
        self.rxUUID = [CBUUID UUIDWithString:@"55AA0003-B5A3-F393-E0A9-E50E24DCCA9E"];
        
        self.deviceName = @"HJS_ZFZ";
        self.scanDuration = 5;
        
        self.scanDeviceArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (CBManagerState)blePowerState
{
    return self.bleCentralManager.blePowerState;
}

- (void)connectDevice:(nonnull CBPeripheral *)peripheral callback:(nonnull UserConnectedCallback)callback
{
    self.connectedCallback = callback;
    [self.bleCentralManager connectPeripheral:peripheral options:nil connectedCallback: ^(BOOL isConnected) {
        if (isConnected) {
            NSLog(@"Device Connected Success !!!!");

            if (self.connectedCallback) {
                self.connectedCallback(YES, SERVICE_DISCOVERING, peripheral);
            }
            
            [self.bleCentralManager discoveryService:peripheral serviceUUID:self.serviceUUID discoveryCallback:^(CBPeripheral *peripheral, NSError *error) {
                if (error == nil) {
                    CBService* service = [peripheral.services firstObject];
                    [self.bleCentralManager discoverCharacteristics:nil forService:service inPeripheral:peripheral callback:^(CBPeripheral *peripheral,CBService *service,NSError *error){
                        BOOL txValidateDone = NO;
                        BOOL rxValidateDone = NO;
                        
                        NSLog(@"Characteristics %@", service.characteristics);
                        
                        for (CBCharacteristic* characteristic in service.characteristics) {
                            if ([characteristic.UUID.UUIDString isEqualToString:self.txUUID.UUIDString]) {
                                txValidateDone = YES;
                            }
                            
                            if ([characteristic.UUID.UUIDString isEqualToString:self.rxUUID.UUIDString]) {
                                rxValidateDone = YES;
                            }
                        }
                        
                        if (txValidateDone && rxValidateDone) {
                            if (self.connectedCallback) {
                                self.connectedCallback(YES, SERVICE_DISCOVERED, peripheral);
                            }
                        } else {
                            if (self.connectedCallback) {
                                self.connectedCallback(YES, SERVICE_DISCOVER_FAIL, peripheral);
                            }
                        }
                    }];
                }
            }];
        
        } else {
            NSLog(@"Device Connected Fail !!!!");
            if (self.connectedCallback) {
                self.connectedCallback(NO, SERVICE_DISCOVER_FAIL, nil);
            }
        }
    }];
}

- (void)notifyPeripheral:(nonnull CBPeripheral *)peripheral notifyValue:(BOOL)isNotify callback:(nonnull NotifyCallback)callback
{
    [self.bleCentralManager notifyToPeripheral:peripheral characteristic:self.rxUUID notifyValue:true callback:^(CBPeripheral *peripheral, CBCharacteristic *ctic, NSError *error) {
        if (error) {
            NSLog(@"notify err: %@", error);
        } else {
            NSLog(@"notify char %@ done", ctic);
        }
        if (callback) {
            callback(peripheral, ctic, error);
        }
    }];
}

- (void)registerNotifyInd:(nonnull NotifyReceived)callback
{
    [self.bleCentralManager registerNotifyRecivedCallback:callback];
}

- (void)startScan:(nonnull UserScanCallback)scanCallback
{
    self.scanTimer = [NSTimer scheduledTimerWithTimeInterval:self.scanDuration target:self selector:@selector(scanTimeout) userInfo:nil repeats:NO];
    
    [self.scanDeviceArray removeAllObjects];
    self.scanCallback = scanCallback;
    
    [self.bleCentralManager startScan: ^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI){
        if (![self.scanDeviceArray containsObject:peripheral]) {
            [self.scanDeviceArray addObject:peripheral];
//            NSLog(@"scan device: %@", peripheral.name);
            
            NSString *regex = self.deviceName;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
            BOOL matched = [predicate evaluateWithObject:peripheral.name];
            if (matched && scanCallback) {
                scanCallback(peripheral, advertisementData, RSSI, NO);
            }
        }
    }];
}

- (void)stopScan
{
    [self.scanTimer invalidate];
    [self.bleCentralManager stopScan];
}

- (void)writePeripheral:(nonnull CBPeripheral *)peripheral valueData:(nonnull NSData *)valueData callback:(nonnull WriteDoneCallback)callback
{
    [self.bleCentralManager writeToPeripheral:peripheral uuid:self.txUUID valueData:valueData callback:callback];
}

- (void)scanTimeout
{
    if (self.scanCallback) {
        [self.bleCentralManager stopScan];
        self.scanCallback(nil, nil, nil, YES);
    }
}

@end
