//
//  BleCentralManager.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/12.
//

#import "BleCentralManager.h"

@interface BleCentralManager () <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (strong, nonatomic)CBCentralManager *centralManager;
@property (nonatomic) BleAdvFilterBlock advFilter;
/*
 BLE扫描结果的回调函数
 */
@property (nonatomic) ScanCallback scanCallback;
/*
 发起连接的回调函数
 */
@property (nonatomic) ConnectedCallback connectedCallback;
/*
 搜索服务的回调函数
 */
@property (nonatomic) DiscoveryServiceCallback discoveryCallback;
/*
 发现属性的回调函数
 */
@property (nonatomic) DiscoveryCharacteristicsCallback discoveryCharCallback;

/*
 订阅服务的回调函数
 */
@property (nonatomic) NotifyCallback notifyCallback;

/*
 写回数据的回调函数
 */
@property (nonatomic) WriteDoneCallback writeDoneCallback;

/*
 读属性数据的回调函数
 */
@property (nonatomic) ReadCharCallback readCharCallback;

/*
 Notify数据的接收函数
 */
@property (nonatomic) NotifyReceived notifyRecevied;

@end

@implementation BleCentralManager

+ (BleCentralManager*)getInstance
{
    static dispatch_once_t predWex = 0;
    __strong static id _sharedWexObject = nil;
    dispatch_once(&predWex, ^
                  {
                      _sharedWexObject = [[self alloc] init];
                  });
    return _sharedWexObject;
}

#pragma mark - CBCentralManagerDelegate的协议实现

/*
 手机蓝牙状态发生变化之后，会调用该函数，比如用户关闭蓝牙，用户打开蓝牙等
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"Bluetooth State: %ld", central.state);
    
    self.blePowerState = central.state;
}

/*
 BLE扫描设备之后，回调这个函数，返回扫描到的从设备的广播内容
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (self.scanCallback != nil) {
        self.scanCallback(central, peripheral, advertisementData, RSSI);
    }
}

/*!
 *  @method centralManager:didConnectPeripheral:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has connected.
 *
 *  @discussion         This method is invoked when a connection initiated by {@link connectPeripheral:options:} has succeeded.
 *
 */
/*
 当主设备调用connectPeripheral:options 函数之后，如果连接成功，则回调这个函数，表示主设备到从设备的BLE连接成功
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"BLE Connected Success");
    if (self.connectedCallback != nil) {
        self.connectedCallback(true);
    }
}

/*
 当主设备发起连接请求之后，如果连接失败，则会回调这个函数
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    NSLog(@"BLE Connected Fail");
    if (self.connectedCallback != nil) {
        self.connectedCallback(false);
    }
}

/*
 发起订阅服务后，会回调这个函数
 */
- (void)peripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(nullable NSError *)error
{
    if (_notifyCallback) {
        _notifyCallback(peripheral, characteristic, error);
        _notifyCallback = nil;
    }

}
/*
 BLE连接被断开
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    NSLog(@"BLE Disconnected");
}

#pragma mark - CBPeripheralDelegate的协议实现

/*
 发现服务完成之后，返回结果
 当主设备调用discoverServices函数之后，该函数返回其结果
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error
{
//    NSLog(@"discover BLE Service: %@", peripheral.services);
    if (self.discoveryCallback != nil) {
        self.discoveryCallback(peripheral, error);
    }
}


/*
 搜索某个服务的属性，返回结果
 当主设备调用discoverCharacteristics:forService函数之后，该函数返回其结果
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error
{
    if (self.discoveryCharCallback != nil) {
        self.discoveryCharCallback(peripheral, service, error);
    }
}

/*
 当主设备调用discoverDescriptorsForCharacteristic函数之后，该函数返回其结果
 */
- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic
             error:(nullable NSError *)error
{
    NSLog(@"discover Descriptor For Characteristic");
}

#pragma mark -
- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        [self initCentralManager];
    }
    
    return self;
}

- (void)initCentralManager
{
#if  __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_6_0
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES],CBCentralManagerOptionShowPowerAlertKey,
                             @"XCYBluetoothRestore",CBCentralManagerOptionRestoreIdentifierKey,
                             nil];
    
#else
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             
                             [NSNumber numberWithBool:YES],CBCentralManagerOptionShowPowerAlertKey,
                             nil];
#endif
    
    NSArray *backgroundModes = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"UIBackgroundModes"];
    if ([backgroundModes containsObject:@"bluetooth-central"]) {
        // The background model
        self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:options];
    }
    else {
        // Non-background mode
        self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    }
}

- (CBCharacteristic *)findCharacteristic:(CBUUID *)chsticUUID
                              inPeripheral:(CBPeripheral *)peripheral
                                 withError:(NSError **)error
{
    CBCharacteristic *findCharactic = nil;
    if (peripheral.services.count > 0) {
        
        NSArray<CBService *> *services = peripheral.services;
        for (CBService *service in services) {

            NSArray<CBCharacteristic *> *characters = service.characteristics;
            for (CBCharacteristic *chst in characters) {

                if ([chst.UUID.UUIDString isEqualToString:chsticUUID.UUIDString]) {
                    findCharactic = chst;
                    break;
                }
            }
            
        }
    }
    
    if (!findCharactic && error) {
        *error = [NSError errorWithDomain:@"XCYNotFindCharatic" code:-2 userInfo:nil];
    }

    return findCharactic;

}

/*
 开始扫描BLE广播
 */
- (void)startScan:(ScanCallback)handler;
{
    NSLog(@"开始扫描BLE设备");
    NSDictionary* options = @{CBCentralManagerScanOptionAllowDuplicatesKey: [NSNumber numberWithBool:NO], CBCentralManagerOptionShowPowerAlertKey:[NSNumber numberWithBool:YES]};
    
    [self.centralManager scanForPeripheralsWithServices:nil options:options];
    self.scanCallback = handler;
}

/*
 停止扫描BLE广播
 */
- (void)stopScan
{
    NSLog(@"停止扫描BLE设备");
    [self.centralManager stopScan];
}

/*
 连接蓝牙从设备
 */
- (void)connectPeripheral:(nonnull CBPeripheral *)peripheral
                  options:(nullable NSDictionary<NSString *, id> *)options
        connectedCallback:(ConnectedCallback)connectedCallback
{
    self.connectedCallback = connectedCallback;
    peripheral.delegate = self;
    [self.centralManager connectPeripheral:peripheral options:options];
}

/*
 发现设备上所有的服务
 */
- (void)discoveryServices:(nonnull CBPeripheral *)peripheral discoveryCallback:(DiscoveryServiceCallback)discoveryCallback
{
    self.discoveryCallback = discoveryCallback;
    [peripheral discoverServices:nil];
}

/*
 发现设备上的某个服务
 */
- (void) discoveryService:(nonnull CBPeripheral *)peripheral serviceUUID:(nullable CBUUID*)serviceUUID discoveryCallback:(DiscoveryServiceCallback)discoveryCallback
{
    self.discoveryCallback = discoveryCallback;
    [peripheral discoverServices:@[serviceUUID]];
}

/*
 发现服务的属性
 */
- (void)discoverCharacteristics:(nullable NSArray<CBUUID *> *)characteristicUUIDs
                     forService:(nonnull CBService *)service
                   inPeripheral:(nonnull CBPeripheral *)peripheral
                       callback:(nonnull DiscoveryCharacteristicsCallback)callback
{
    self.discoveryCharCallback = callback;
    [peripheral discoverCharacteristics:nil forService:service];
}

/*
 订阅服务
 */
- (void)notifyToPeripheral:(nonnull CBPeripheral *)peripheral
            characteristic:(nonnull CBUUID *)characteristicUUID
               notifyValue:(BOOL)isNotify
        callback:(NotifyCallback)callback
{
    self.notifyCallback = callback;
    
    NSError *error;
    CBCharacteristic *targetChar = [self findCharacteristic:characteristicUUID inPeripheral:peripheral withError:&error];
    
    if (error) {
        NSLog(@"Can Not Found uuid: %@", characteristicUUID);
        if (_notifyCallback) {
            _notifyCallback(peripheral, nil, error);
            return;
        }
    }
    
    if (targetChar.properties & CBCharacteristicPropertyNotify) {
        NSLog(@"Notifying %@", targetChar);
         [peripheral setNotifyValue:isNotify forCharacteristic:targetChar];
    } else {
        NSLog(@"Properties cannot be subscribed to");
    }
    
}

/*
 往设备中写入数据
 */
- (void) writeToPeripheral:(CBPeripheral*)peripheral uuid:(CBUUID*)uuid  valueData:(NSData *)valueData callback:(WriteDoneCallback)callback
{
    self.writeDoneCallback = callback;
    
    NSError* error;
    CBCharacteristic* characteristic = [self findCharacteristic:uuid inPeripheral:peripheral withError:&error];
    if (error) {
        if (_writeDoneCallback) {
            _writeDoneCallback(peripheral, nil, error);
        }
        return;
    }
    
    CBCharacteristicWriteType type = CBCharacteristicWriteWithoutResponse;
    if (characteristic.properties & CBCharacteristicPropertyWrite) {
        
        type = CBCharacteristicWriteWithResponse;
    }
    NSLog(@"Sending: %@", valueData);
    [peripheral writeValue:valueData forCharacteristic:characteristic type:type];
}

/*
 读某个属性的值
 */
- (void)readToPeripheral:(CBPeripheral *)peripheral
              descriptor:(CBUUID *)characteristicUUID
                callback:(ReadCharCallback)callback
{
    self.readCharCallback = callback;
    NSError *error;
    CBCharacteristic *targetChtic = [self findCharacteristic:characteristicUUID inPeripheral:peripheral withError:&error];
    if (error) {
        if (_readCharCallback) {
            _readCharCallback(peripheral,nil,error);
        }
        return;
    }
    
    if (targetChtic.properties & CBCharacteristicPropertyRead) {
        [peripheral readValueForCharacteristic:targetChtic];
    }else {
        
        NSError *error  = [NSError errorWithDomain:@"XCYReadCharacterNoPermissions" code:-2 userInfo:nil];
        if (_readCharCallback) {
            _readCharCallback(peripheral,nil,error);
        }
    }
}

/*
 注册Notify的回调函数
 */
- (void) registerNotifyRecivedCallback:(NotifyReceived)callback
{
    self.notifyRecevied = callback;
}

/*
 读某个属性的值，或者设备端发来的Notify数据，也会回调这个函数
 */
- (void)peripheral:(CBPeripheral *)peripheral
            didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(nullable NSError *)error
{
    NSLog(@"Receive: %@", characteristic.value);
    if (_notifyRecevied && (characteristic.properties & CBCharacteristicPropertyNotify)){
        _notifyRecevied(peripheral,characteristic,error);
        return;
    }
    
    if (_readCharCallback && (characteristic.properties & CBCharacteristicPropertyRead)) {
        _readCharCallback(peripheral,characteristic,error);
    }
    
    
}

- (void)peripheral:(CBPeripheral *)peripheral
didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(nullable NSError *)error
{
   if (_writeDoneCallback) {
       _writeDoneCallback(peripheral,characteristic,error);
   }
}

@end
