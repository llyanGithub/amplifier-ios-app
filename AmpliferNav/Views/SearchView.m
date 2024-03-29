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
#import "ConnecteButton.h"
#import "ViewController.h"
#include "ConnectedView.h"
#include "ScreenAdapter.h"
#include "ReadySearchView.h"
#include "CBPeripheral+fullname.h"


#define ROTATE_TMER_INTERVAL (1/15.0)
#define ROTATE_DEGREE       (M_PI/6.0)


@interface SearchView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) BleProfile* bleProfile;
@property (nonatomic) NSMutableArray* scanDeviceArray;
@property (weak, nonatomic) IBOutlet UITableView *searchTable;
@property (weak, nonatomic) IBOutlet UIImageView *searchCenterImage;
@property (weak, nonatomic) IBOutlet UIImageView *searchBorderImage;
@property (weak, nonatomic) IBOutlet UILabel *searchResultLabel;
@property (weak, nonatomic) IBOutlet UILabel *searchStateLabel;

@property (nonatomic) UIButton* backButton;

@property (nonatomic) CGFloat currentDegree;
@property (nonatomic) NSTimer* searchIconRotateTimer;

@property (nonatomic)CBPeripheral* peripheral;

@end

@implementation SearchView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect mainFrame = [UIScreen mainScreen].bounds;
    NSUInteger labelHeight = SHReadValue(20);
    NSUInteger labelWidth = SWReadValue(150);
    NSUInteger topMargin = SHReadValue(120);
    
//    self.backButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"返回"]];
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(SWReadValue(20), SWReadValue(60), SWReadValue(15), SWReadValue(23))];
    [self.backButton setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchDown];
    self.backButton.hidden = YES;
    
    self.searchStateLabel.frame = CGRectMake(mainFrame.origin.x, topMargin, mainFrame.size.width, labelHeight);
    self.searchStateLabel.textAlignment = NSTextAlignmentCenter;
    self.searchStateLabel.text = NSLocalizedString(@"searching", nil);
    
    NSUInteger searchBorderSize = SWReadValue(100);
    NSUInteger imageTopMargin = SHReadValue(80);
    NSUInteger imagePosY = topMargin + labelHeight + imageTopMargin;
    
    self.searchBorderImage.frame = CGRectMake(mainFrame.size.width/2 - searchBorderSize/2, imagePosY, searchBorderSize, searchBorderSize);
    
    NSUInteger searchCenterSize = SWReadValue(30);
    NSUInteger searchCenterPosY = imagePosY + searchBorderSize/2 - searchCenterSize/2;
    self.searchCenterImage.frame = CGRectMake(mainFrame.size.width/2 - searchCenterSize/2, searchCenterPosY, searchCenterSize, searchCenterSize);
    
    NSUInteger searchResultLabelTopMargin = SHReadValue(80);
    self.searchResultLabel.frame = CGRectMake(SWReadValue(20), imagePosY+searchBorderSize + searchResultLabelTopMargin, labelWidth*2, labelHeight);
    self.searchResultLabel.text = NSLocalizedString(@"foundDevices", nil);
    
    NSUInteger tablePosY = self.searchResultLabel.frame.origin.y + labelHeight;
    self.searchTable.frame = CGRectMake(0, tablePosY, mainFrame.size.width, mainFrame.size.height - tablePosY);
    
    self.searchTable.dataSource = self;
    self.searchTable.delegate = self;
    
    self.bleProfile = [BleProfile getInstance];
    self.scanDeviceArray = [[NSMutableArray alloc] init];
    
    self.searchTable.allowsSelection = NO;
    
    [self searchDevice];
    
    [self.view addSubview:self.backButton];
}

- (void)backButtonClicked
{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void) searchNow
{
    if (self.bleProfile.blePowerState != CBManagerStatePoweredOn) {
        NSLog(@"请打开您的手机蓝牙...");
        return;
    }
    
    // 扫描之前，清空所有之前已经扫描到的设备
    [self.scanDeviceArray removeAllObjects];
    
    self.searchStateLabel.text = NSLocalizedString(@"searching", nil);
    
    self.currentDegree = 0.0;
    [self startRotate];
    
    [self.bleProfile startScan:^(CBPeripheral *peripheral,NSDictionary *advertisementData, NSNumber *RSSI, BOOL timeout){
        if (!timeout) {
            [self.scanDeviceArray addObject:peripheral];
            NSLog(@"Found Device: %@", peripheral.name);
            [self.searchTable reloadData];
        } else {
            NSLog(@"Scan Devices: %ld", self.scanDeviceArray.count);
            [self searchDone];
        }
    }];
}

- (void) searchDevice
{
    [self.bleProfile registerStateChangedInd:^(CBCentralManager* central) {
        if (central.state != CBManagerStatePoweredOn) {
            NSLog(@"请打开您的手机蓝牙...");
            return;
        }
    
        [self searchNow];
    }];
}

- (void) searchDone
{
    [self stopRotate];
    self.currentDegree = 0.0;
    CGAffineTransform trans = CGAffineTransformMakeRotation(self.currentDegree);
    self.searchBorderImage.transform = trans;
    
    if (self.scanDeviceArray.count) {
        self.searchCenterImage.hidden = true;
        self.backButton.hidden = false;
        [self.searchBorderImage setImage:[UIImage imageNamed:@"搜索完成图标"]];
        self.searchStateLabel.text = NSLocalizedString(@"searchDone", nil);
    } else {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"searchFail", nil)
                                                                       message: NSLocalizedString(@"searchFailContent", nil)
                                       preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* reSearchAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"reSearch", nil) style:UIAlertActionStyleDefault
           handler:^(UIAlertAction * action) {
            NSLog(@"重新搜索");
            [self restartSearch];
        }];

        [alert addAction:reSearchAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

- (void) restartSearch
{
    self.currentDegree = 0.0;
    CGAffineTransform trans = CGAffineTransformMakeRotation(self.currentDegree);
    self.searchBorderImage.transform = trans;
    
    self.searchCenterImage.hidden = false;
    [self.searchBorderImage setImage:[UIImage imageNamed:@"搜索图标"]];
    
    [self searchNow];
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UILabel* nameLabel = (UILabel*)[cell viewWithTag:1];
    CBPeripheral *peripheral = [self.scanDeviceArray objectAtIndex:indexPath.row];
//    nameLabel.text = peripheral.name;
    nameLabel.text = peripheral.fullname.uppercaseString;
    
    ConnecteButton* button = (ConnecteButton*)[cell viewWithTag:2];
    [button addTarget:self action:@selector(connectButtonClicked:) forControlEvents:UIControlEventTouchDown];
    [button setTitle:NSLocalizedString(@"connect", nil) forState:UIControlStateNormal];
    button.row = indexPath.row;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier  isEqual: @"segueConnected"]) {
        NSLog(@"prepareForSegue");
        ConnectedView* destView = (ConnectedView*)segue.destinationViewController;
        
        destView.deviceName = self.peripheral.name;
        
        NSString *patterG = @".*-G";
        NSString *patterD = @".*-D";
        
        NSPredicate *predicateG = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",patterG];
        NSPredicate *predicateD = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",patterD];
        
        BOOL matched = [predicateG evaluateWithObject: self.peripheral.name];
        if (matched) {
            destView.deviceType = TWS_DEVICE_TYPE_G;
        }
        
        matched = [predicateD evaluateWithObject: self.peripheral.name];
        if (matched) {
            destView.deviceType = TWS_DEVICE_TYPE_D;
        }
        
        //为视图控制器设置过渡类型
        destView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
        //为视图控制器设置显示样式
        destView.modalPresentationStyle = UIModalPresentationFullScreen;
    }
}

- (void) connectDevice:(CBPeripheral*)peripheral
{
    [self searchDone];
    [self.bleProfile stopScan];
    [self.bleProfile connectDevice:peripheral callback:^(BOOL isConnected, NSUInteger serviceDiscoverEvent, CBPeripheral *peripheral) {
        if (isConnected && serviceDiscoverEvent == SERVICE_DISCOVERING) {
            NSLog(@"蓝牙已连接，正在搜索服务...");
        } else if (isConnected && serviceDiscoverEvent == SERVICE_DISCOVERED) {
            NSLog(@"蓝牙已经连接，服务所搜完毕");
            self.peripheral = peripheral;
            
            [self.bleProfile notifyPeripheral:peripheral notifyValue:YES callback:^ (CBPeripheral *peripheral, CBCharacteristic *ctic, NSError *error) {
                if (error == nil) {
                    NSLog(@"订阅成功...");
                    
                    [self performSegueWithIdentifier:@"segueConnected" sender:self];
                }
            }];
        } else if (isConnected && serviceDiscoverEvent == SERVICE_DISCOVER_FAIL) {
            NSLog(@"蓝牙已经连接，搜索服务失败");
        } else if (!isConnected) {
            NSLog(@"蓝牙连接失败");
        } else {
            NSLog(@"蓝牙连接过程中，出现未定义错误: %d %ld %@", isConnected, serviceDiscoverEvent, peripheral);
        }
    }];
}

- (void) connectButtonClicked:(ConnecteButton*)sender
{
    NSLog(@"connectButtonClicked: %ld", sender.row);
    
    CBPeripheral* peripheral = [self.scanDeviceArray objectAtIndex:sender.row];
    
    [self connectDevice:peripheral];
}

- (void)dealloc
{
    NSLog(@"======== SearchView  释放： dealloc   =======\n");
}

#pragma mark- life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    NSLog(@"========   视图将要出现： viewWillAppear:(BOOL)animated   =======\n");
    /* 跳转之前清空已扫描到的设备 */
    [self.scanDeviceArray removeAllObjects];
    [self.searchTable reloadData];
    
    [self restartSearch];
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
