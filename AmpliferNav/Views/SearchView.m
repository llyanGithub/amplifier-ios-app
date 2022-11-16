//
//  SearchView.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/16.
//

#import "SearchView.h"
#import "BleCentralManager.h"
#import "BleProfile.h"
#import "PacketProto.h"


@interface SearchView ()

@property (nonatomic) BleProfile* bleProfile;
@property (nonatomic) NSMutableArray* scanDeviceArray;

/* 需要拿到BLE PowerOn的通知之后才能扫描BLE广播，因此需要稍微延时一下 */
@property (nonatomic) NSTimer* waitBleReadyTimer;

@end

@implementation SearchView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.bleProfile = [BleProfile getInstance];
    self.scanDeviceArray = [[NSMutableArray alloc] init];
    
    self.waitBleReadyTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(searchDevice) userInfo:nil repeats:NO];
//    [self searchDevice];
}

- (void) searchDevice
{
    if (self.bleProfile.blePowerState != CBManagerStatePoweredOn) {
        NSLog(@"请打开您的手机蓝牙...");
        return;
    }
    
    // 扫描之前，清空所有之前已经扫描到的设备
    [self.scanDeviceArray removeAllObjects];
    
    [self.bleProfile startScan:^(CBPeripheral *peripheral,NSDictionary *advertisementData, NSNumber *RSSI, BOOL timeout){
        if (!timeout) {
            [self.scanDeviceArray addObject:peripheral];
            NSLog(@"Found Device: %@", peripheral.name);
        } else {
            NSLog(@"Scan Devices: %ld", self.scanDeviceArray.count);
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
