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


#define ROTATE_TMER_INTERVAL (1/15.0)
#define ROTATE_DEGREE       (M_PI/6.0)


@interface SearchView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) BleProfile* bleProfile;
@property (nonatomic) NSMutableArray* scanDeviceArray;
@property (weak, nonatomic) IBOutlet UITableView *searchTable;
@property (weak, nonatomic) IBOutlet UIImageView *searchCenterImage;
@property (weak, nonatomic) IBOutlet UIImageView *searchBorderImage;

@property (nonatomic) CGFloat currentDegree;
@property (nonatomic) NSTimer* searchIconRotateTimer;

/* 需要拿到BLE PowerOn的通知之后才能扫描BLE广播，因此需要稍微延时一下 */
@property (nonatomic) NSTimer* waitBleReadyTimer;

@end

@implementation SearchView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.searchTable.dataSource = self;
    self.searchTable.delegate = self;
    
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
    
    self.currentDegree = 0.0;
    [self startRotate];
    
    [self.bleProfile startScan:^(CBPeripheral *peripheral,NSDictionary *advertisementData, NSNumber *RSSI, BOOL timeout){
        if (!timeout) {
            [self.scanDeviceArray addObject:peripheral];
            NSLog(@"Found Device: %@", peripheral.name);
            [self.searchTable reloadData];
        } else {
            NSLog(@"Scan Devices: %ld", self.scanDeviceArray.count);
            [self stopRotate];
            
            self.currentDegree = 0.0;
            CGAffineTransform trans = CGAffineTransformMakeRotation(self.currentDegree);
            self.searchBorderImage.transform = trans;
            
            self.searchCenterImage.hidden = true;
            [self.searchBorderImage setImage:[UIImage imageNamed:@"搜索完成图标"]];
        }
    }];
}

- (void) startRotate
{
    self.searchIconRotateTimer = [NSTimer scheduledTimerWithTimeInterval:ROTATE_TMER_INTERVAL target:self selector:@selector(rotateTimerHandler) userInfo:nil repeats:YES];
}

- (void) stopRotate
{
    if (self.searchIconRotateTimer) {
        [self.searchIconRotateTimer invalidate];
    }
}

- (void) rotateTimerHandler
{
    self.currentDegree = (self.currentDegree + ROTATE_DEGREE) <= M_PI*2 ? (self.currentDegree + ROTATE_DEGREE) : (self.currentDegree + ROTATE_DEGREE) - M_PI*2;
    
    CGAffineTransform trans = CGAffineTransformMakeRotation(self.currentDegree);
    self.searchBorderImage.transform = trans;
}


// 返回行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.scanDeviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellId = @"deviceCell";
    
    UITableViewCell* cell = (UITableViewCell*)[self.searchTable dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    UILabel* nameLabel = (UILabel*)[cell viewWithTag:1];
    CBPeripheral *peripheral = [self.scanDeviceArray objectAtIndex:indexPath.row];
    nameLabel.text = peripheral.name;
    
    return cell;
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
