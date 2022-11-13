//
//  ViewController.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/8.
//

#import "ViewController.h"
#import "NavButton.h"
#import "ModeView.h"
#import "VolumeView.h"
#import "FreqResponseView.h"
#import "ProtectEarView.h"
#import "OtherView.h"
#import "BleCentralManager.h"
#import "BleProfile.h"
#import "PacketProto.h"

@interface ViewController ()
@property (nonatomic) UIStackView* mainStack;
@property (nonatomic) UIStackView* navStack;
@property (nonatomic) NSMutableArray* buttonsArray;
@property (nonatomic) NSMutableArray* viewsArray;
@property (nonatomic) CGRect mainFrame;

@property (nonatomic) UIButton* homeButton;
@property (nonatomic) UILabel* leftBatLabel;
@property (nonatomic) UIImageView* leftBatImageView;
@property (nonatomic) UIImageView* rightBatImageView;
@property (nonatomic) UILabel* rightBatLabel;

@property (nonatomic) NSUInteger homeButtonTopMargin;
@property (nonatomic) NSUInteger horizontalMargin;
@property (nonatomic) NSUInteger navButtonHeight;
@property (nonatomic) NSUInteger navButtonWidth;
@property (nonatomic) NSUInteger navButtonTopMargin;

@property (nonatomic) BleProfile* bleProfile;
@property (nonatomic) NSMutableArray* scanDeviceArray;
@property (nonatomic) CBPeripheral* peripheral;
@property (nonatomic) NSTimer* waitBleReadyTimer;

@property (nonatomic) PacketProto* packetProto;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mainFrame = [UIScreen mainScreen].bounds;
    self.horizontalMargin = 20;
    self.navButtonHeight = 60;
    self.navButtonTopMargin = 10;
    self.navButtonWidth = (self.mainFrame.size.width - 2*self.horizontalMargin)/5;
    
    self.homeButtonTopMargin = 40;
    
    UIView* batteryView = [self createBatteryView];
    NSUInteger batteryViewWidth = 75;
    NSUInteger batteryPosX = self.mainFrame.size.width - self.horizontalMargin - batteryViewWidth;
    batteryView.frame = CGRectMake(batteryPosX, self.homeButtonTopMargin, batteryViewWidth, 25);
    
    self.homeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.horizontalMargin, self.homeButtonTopMargin, 20, 20)];
    [self.homeButton setImage:[UIImage imageNamed:@"返回主页按钮"] forState:UIControlStateNormal];
    
    [self createStack];
    
    // 创建5个导航按钮，并将其放入可变数组中
    self.buttonsArray = [[NSMutableArray alloc]init];
    [self.buttonsArray addObject:[self createNavButton:@"模式" index:0 checkedImageName:[UIImage imageNamed:@"模式选中"] unCheckedImageName:[UIImage imageNamed:@"模式"]]];
    [self.buttonsArray addObject:[self createNavButton:@"音量" index:1 checkedImageName:[UIImage imageNamed:@"音量选中"] unCheckedImageName:[UIImage imageNamed:@"音量"]]];
    [self.buttonsArray addObject:[self createNavButton:@"频响" index:2 checkedImageName:[UIImage imageNamed:@"频响选中"] unCheckedImageName:[UIImage imageNamed:@"频响"]]];
    [self.buttonsArray addObject:[self createNavButton:@"护耳" index:3 checkedImageName:[UIImage imageNamed:@"听力保护选中"] unCheckedImageName:[UIImage imageNamed:@"听力保护"]]];
    [self.buttonsArray addObject:[self createNavButton:@"其它" index:4 checkedImageName:[UIImage imageNamed:@"其它选中"] unCheckedImageName:[UIImage imageNamed:@"其它"]]];
    
    // 创建子页面
    self.viewsArray = [[NSMutableArray alloc]init];
    CGRect frame = CGRectMake(0, 120, self.mainFrame.size.width, self.mainFrame.size.height-120);
    
    ModeView* modeView = [[ModeView alloc] initWithFrame:frame];
    VolumeView* volumeView = [[VolumeView alloc] initWithFrame:frame];
    FreqResponseView* freqResponseView = [[FreqResponseView alloc] initWithFrame:frame];
    ProtectEarView* protectEarView = [[ProtectEarView alloc] initWithFrame:frame];
    OtherView* otherView = [[OtherView alloc] initWithFrame:frame];
    
    [self.viewsArray addObject:modeView];
    [self.viewsArray addObject:volumeView];
    [self.viewsArray addObject:freqResponseView];
    [self.viewsArray addObject:protectEarView];
    [self.viewsArray addObject:otherView];
    
    modeView.hidden = false;
    
    for (UIView* view in self.viewsArray) {
        [self.mainStack addSubview:view];
    }
    
    [self.view addSubview:self.mainStack];
    [self.view addSubview:self.homeButton];
    [self.view addSubview:batteryView];
    
    for (NavButton* button in self.buttonsArray) {
        [self.view addSubview:button];
    }
    
    self.packetProto = [PacketProto getInstance];
    NSLog(@"packetProto: %@", self.packetProto);
    [self BleProfileTest];
//    self.bleCentralManager = [BleCentralManager getInstance];
//    self.scanDeviceArray = [[NSMutableArray alloc]init];
//    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(bluetoothTest) userInfo:nil repeats:NO];
}

- (UIView*) createBatteryView
{
    UIStackView* stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.spacing = 3;
    
    self.leftBatLabel = [[UILabel alloc] init];
    self.rightBatLabel = [[UILabel alloc] init];
    self.leftBatImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"50％"]];
    self.rightBatImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"50％"]];
    
    self.leftBatLabel.text = @"左";
    self.rightBatLabel.text = @"右";
    
    UIFont* font = [UIFont systemFontOfSize:12];
    self.leftBatLabel.font = font;
    self.rightBatLabel.font = font;
    
    [stackView addArrangedSubview:self.leftBatLabel];
    [stackView addArrangedSubview:self.leftBatImageView];
    [stackView addArrangedSubview:self.rightBatImageView];
    [stackView addArrangedSubview:self.rightBatLabel];
    
    return (UIView*)stackView;
}


- (void) createStack
{
    self.mainStack = [[UIStackView alloc] initWithFrame: self.mainFrame];
    self.mainStack.axis = UILayoutConstraintAxisVertical;
    self.mainStack.distribution = UIStackViewDistributionEqualSpacing;
}

- (UIView*) createViews:(UIColor*)color frame:(CGRect)frame
{
    UIView* view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = color;
    view.hidden = true;
    
    NavButton* navButton = [[NavButton alloc]initWithCheckedImage:CGRectMake(50, 100, 300, 100) checkedImage:[UIImage imageNamed:@"模式选中"] unCheckedImage: [UIImage imageNamed:@"模式"]];
    
    [navButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [navButton  setTitle:@"模式" forState:UIControlStateNormal];
    [navButton layoutButtonWithImageStyle:ZJButtonImageStyleTop imageTitleToSpace:20];
    navButton.checked = true;
    
    [view addSubview: navButton];
    
    return view;
}

- (NavButton*)createNavButton:(NSString*)titleName index:(NSUInteger)index checkedImageName:(UIImage*) checkedImage unCheckedImageName:(UIImage*)unCheckedImage
{
    NSUInteger buttonPosX = self.horizontalMargin + self.navButtonWidth*index;
    NSUInteger buttonPosY = self.homeButtonTopMargin + self.homeButton.frame.size.height + self.navButtonTopMargin;
    
    NavButton* button = [[NavButton alloc] initWithCheckedImage:CGRectMake(buttonPosX, buttonPosY, self.navButtonWidth, self.navButtonHeight) checkedImage:checkedImage unCheckedImage:unCheckedImage];

    [button setTitle:titleName forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [button addTarget:self action:@selector(navButtonClicked:) forControlEvents:UIControlEventTouchDown];

    [button layoutButtonWithImageStyle:ZJButtonImageStyleTop imageTitleToSpace:8];
    
    return button;
}

- (void)navButtonClicked:(NavButton *)sender
{
    NSUInteger index = [self.buttonsArray indexOfObject:sender];
    NSLog(@"button: %@ index: %ld clicked", sender.titleLabel.text, index);
    
    for (NavButton* button in self.buttonsArray) {
        button.checked = false;
    }
    sender.checked = true;
    
    for (UIView* view in self.viewsArray) {
        view.hidden = true;
    }
    
    UIView* view = [self.viewsArray objectAtIndex: index];
    view.hidden = false;
}

- (void) registerBleRxHandler
{
    [self.bleProfile registerNotifyInd:^(CBPeripheral *peripheral,CBCharacteristic *characteristic,NSError *error) {
//        NSLog(@"Received BLE Data: %@", characteristic.value);
        
        [[PacketProto getInstance] parseReceviedPacket:characteristic.value compeletionHandler:^(NSUInteger cmdId, NSData* payload) {
//            NSLog(@"cmd: %ld, payload: %@", cmdId, payload);

            if (cmdId == AXON_COMMAND_QUERY_DEVICE) {
                NSLog(@"leftBattery: %ld rightBattery: %ld isTwsConnected: %d", self.packetProto.leftEarBattery, self.packetProto.rightEarBattery, self.packetProto.isTwsConnected);
            }
        }];
    }];
}

- (void) sendTestData
{
    NSData* queryDeviceInfoPkt = [[PacketProto getInstance] packInfoQuery];

    NSLog(@"queryDeviceInfoPkt: %@", queryDeviceInfoPkt);
    [[BleProfile getInstance] writePeripheral:self.peripheral valueData:queryDeviceInfoPkt callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
        NSLog(@"写入设备信息查询指令成功");
    }];
}

- (void) testStart
{
    if (self.bleProfile.blePowerState != CBManagerStatePoweredOn) {
        NSLog(@"请打开您的手机蓝牙...");
        return;
    }
    
    [self.bleProfile startScan:^(CBPeripheral *peripheral,NSDictionary *advertisementData, NSNumber *RSSI, BOOL timeout){
        if (!timeout) {
            [self.scanDeviceArray addObject:peripheral];
            NSLog(@"Found Device: %@", peripheral.name);
        } else {
            if (self.scanDeviceArray.count) {
                CBPeripheral *peripheral = self.scanDeviceArray.firstObject;
                [self.bleProfile connectDevice:peripheral callback:^(BOOL isConnected, NSUInteger serviceDiscoverEvent, CBPeripheral *peripheral) {
                    if (isConnected && serviceDiscoverEvent == SERVICE_DISCOVERING) {
                        NSLog(@"蓝牙已连接，正在搜索服务...");
                    } else if (isConnected && serviceDiscoverEvent == SERVICE_DISCOVERED) {
                        NSLog(@"蓝牙已经连接，服务所搜完毕");
                        self.peripheral = peripheral;
                        [self registerBleRxHandler];
                        
                        [self.bleProfile notifyPeripheral:peripheral notifyValue:YES callback:^ (CBPeripheral *peripheral, CBCharacteristic *ctic, NSError *error) {
                            if (error == nil) {
                                NSLog(@"订阅成功...");
                                [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendTestData) userInfo:nil repeats:NO];
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
        }
    }];
}

- (void)BleProfileTest
{
    self.bleProfile = [BleProfile getInstance];
    
    self.scanDeviceArray = [[NSMutableArray alloc] init];
    
    self.waitBleReadyTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(testStart) userInfo:nil repeats:NO];
}

@end
