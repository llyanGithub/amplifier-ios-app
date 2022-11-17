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
#import "ScreenAdapter.h"


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

@property (nonatomic) ModeView* modeView;
@property (nonatomic) VolumeView* volumeView;
@property (nonatomic) FreqResponseView* freqResponseView;
@property (nonatomic) ProtectEarView* protectEarView;
@property (nonatomic) OtherView* otherView;

@property (nonatomic) BleProfile* bleProfile;
@property (nonatomic) NSMutableArray* scanDeviceArray;
@property (nonatomic) CBPeripheral* peripheral;
@property (nonatomic) NSTimer* waitBleReadyTimer;

@property (nonatomic) PacketProto* packetProto;
@property (nonatomic) NSUInteger testCount;

@property (nonatomic) NSUInteger currentMode;
@property (nonatomic) NSUInteger isTwsConnected;
@property (nonatomic) NSData* leftEarFirmwareVersion;
@property (nonatomic) NSData* rightEarFirmVersion;
@property (nonatomic) NSUInteger currentAncMode;

@property (nonatomic) BOOL isBangsScreen;


@end

@implementation ViewController

- (void)setCurrentMode:(NSUInteger)currentMode
{
    _currentMode = currentMode;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (UIApplication.sharedApplication.keyWindow.safeAreaInsets.top > 20) {
        self.isBangsScreen = YES;
        NSLog(@"是刘海屏");
    } else {
        self.isBangsScreen = NO;
        NSLog(@"不是刘海屏");
    }
    
    self.mainFrame = [UIScreen mainScreen].bounds;
    self.horizontalMargin = SHReadValue(20);
    self.navButtonHeight = SHReadValue(45);
    self.navButtonTopMargin = SHReadValue(20);
    self.navButtonWidth = (self.mainFrame.size.width - 2*self.horizontalMargin)/5;
    
    if (self.isBangsScreen) {
        self.homeButtonTopMargin = SHReadValue(80);
    } else {
        self.homeButtonTopMargin = SHReadValue(40);
    }
    
    self.homeButtonTopMargin = SHReadValue(60);

    
    UIView* batteryView = [self createBatteryView];
    NSUInteger batteryViewWidth = SHReadValue(60);
    NSUInteger batteryViewHeight = SHReadValue(20);
    NSUInteger batteryPosX = self.mainFrame.size.width - self.horizontalMargin - batteryViewWidth;
    batteryView.frame = CGRectMake(batteryPosX, self.homeButtonTopMargin, batteryViewWidth, batteryViewHeight);
    
    NSUInteger homeButtonWidth = SWReadValue(20);
    NSUInteger homeButtonHeight = SWReadValue(20);
    
    self.homeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.horizontalMargin, self.homeButtonTopMargin, homeButtonWidth, homeButtonHeight)];
    [self.homeButton setImage:[UIImage imageNamed:@"返回主页按钮"] forState:UIControlStateNormal];
    
    [self createStack];
    
    // 创建5个导航按钮，并将其放入可变数组中
    self.buttonsArray = [[NSMutableArray alloc]init];
    [self.buttonsArray addObject:[self createNavButton:@"模式" index:0 checkedImageName:[UIImage imageNamed:@"模式选中"] unCheckedImageName:[UIImage imageNamed:@"模式"]]];
    [self.buttonsArray addObject:[self createNavButton:@"音量" index:1 checkedImageName:[UIImage imageNamed:@"音量选中"] unCheckedImageName:[UIImage imageNamed:@"音量"]]];
    [self.buttonsArray addObject:[self createNavButton:@"频响" index:2 checkedImageName:[UIImage imageNamed:@"频响选中"] unCheckedImageName:[UIImage imageNamed:@"频响"]]];
    [self.buttonsArray addObject:[self createNavButton:@"护耳" index:3 checkedImageName:[UIImage imageNamed:@"听力保护选中"] unCheckedImageName:[UIImage imageNamed:@"听力保护"]]];
    [self.buttonsArray addObject:[self createNavButton:@"其它" index:4 checkedImageName:[UIImage imageNamed:@"其它选中"] unCheckedImageName:[UIImage imageNamed:@"其它"]]];
    
    NSUInteger subViewPosY = self.homeButtonTopMargin + self.homeButton.frame.size.height + self.navButtonTopMargin + self.navButtonHeight;
    
    // 创建子页面
    self.viewsArray = [[NSMutableArray alloc]init];
    CGRect frame = CGRectMake(0, subViewPosY, self.mainFrame.size.width, self.mainFrame.size.height-subViewPosY);
    
    self.modeView = [[ModeView alloc] initWithFrame:frame];
    self.volumeView = [[VolumeView alloc] initWithFrame:frame];
    self.freqResponseView = [[FreqResponseView alloc] initWithFrame:frame];
    self.protectEarView = [[ProtectEarView alloc] initWithFrame:frame];
    self.otherView = [[OtherView alloc] initWithFrame:frame];
    
    [self.viewsArray addObject:self.modeView];
    [self.viewsArray addObject:self.volumeView];
    [self.viewsArray addObject:self.freqResponseView];
    [self.viewsArray addObject:self.protectEarView];
    [self.viewsArray addObject:self.otherView];
    
    self.modeView.hidden = false;
    
    for (UIView* view in self.viewsArray) {
        [self.mainStack addSubview:view];
    }
    
    [self.view addSubview:self.mainStack];
    [self.view addSubview:self.homeButton];
    [self.view addSubview:batteryView];
    
    for (NavButton* button in self.buttonsArray) {
        [self.view addSubview:button];
    }
    
#if 1
    self.packetProto = [PacketProto getInstance];
    self.bleProfile = [BleProfile getInstance];
    
    self.peripheral = self.bleProfile.peripheral;
    [self registerBleRxHandler];
    
    NSLog(@"packetProto: %@", self.packetProto);
    [self getDeviceInfo];
//    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(getDeviceInfo) userInfo:nil repeats:NO];
#endif
    
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

- (NavButton*)createNavButton:(NSString*)titleName index:(NSUInteger)index checkedImageName:(UIImage*) checkedImage unCheckedImageName:(UIImage*)unCheckedImage
{
    NSUInteger buttonPosX = self.horizontalMargin + self.navButtonWidth*index;
    NSUInteger buttonPosY = self.homeButtonTopMargin + self.homeButton.frame.size.height + self.navButtonTopMargin;
    
    NavButton* button = [[NavButton alloc] initWithCheckedImage:CGRectMake(buttonPosX, buttonPosY, self.navButtonWidth, self.navButtonHeight) checkedImage:checkedImage unCheckedImage:unCheckedImage];
    
    button.titleName = titleName;
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

            /* 查询设备信息：tws是否连接上、左右耳机固件的版本，左右耳机的电量信息 */
            if (cmdId == AXON_COMMAND_QUERY_DEVICE) {
                NSLog(@"收到ACK：AXON_COMMAND_QUERY_DEVICE，errCode: %ld leftBattery: %ld rightBattery: %ld isTwsConnected: %d", self.packetProto.errCode, self.packetProto.leftEarBattery, self.packetProto.rightEarBattery, self.packetProto.isTwsConnected);
                
                // 设置左右耳电量信息，更新电量信息的图标
                [self setLeftEarBatteryLevel:self.packetProto.leftEarBattery];
                [self setRightEarBatteryLevel:self.packetProto.rightEarBattery];
            /* 设置耳机ANC模式,回复Ack */
            } else if (cmdId == AXON_COMMAND_ANC_SWITCH) {
                NSLog(@"收到ACK: AXON_COMMAND_ANC_SWITCH，errCode: %ld", self.packetProto.errCode);
                
            /* 查询设备ANC模式 */
            } else if (cmdId == AXON_COMMAND_QUERY_ANC) {
                NSLog(@"收到ACK: AXON_COMMAND_QUERY_ANC errCode: %ld ancState: %ld", self.packetProto.errCode, self.packetProto.ancState);
                
                // 设置当前ANC模式,忽略模式AXON_ANC_ON，UI上看到好像不支持
                if (self.packetProto.ancState != AXON_ANC_ON) {
                    self.otherView.currentMode = self.packetProto.ancState;
                }
                
            /* 查询耳机频响信息：当前模式（户内、户外、其他），左右耳音量，左右耳频响值，左右耳听力保护等级 */
            } else if (cmdId == AXON_COMMAND_QUERY_SOUND) {
                NSLog(@"收到ACK: AXON_COMMAND_QUERY_SOUND errCode: %ld mode: %ld, rightVolume: %ld leftVolume: %ld, rightFreqs: %@, leftFreqs: %@, rightProtection: %ld leftProtection: %ld", self.packetProto.errCode, self.packetProto.mode, self.packetProto.rightVolume, self.packetProto.leftVolume, self.packetProto.rightFreqs, self.packetProto.leftFreqs, self.packetProto.rightEarProtection, self.packetProto.leftEarProtection);
                
                // 更新界面模式显示
                self.modeView.currentMode = self.packetProto.mode;
                // 更新左右耳音量显示
                self.volumeView.leftVolumeValue = self.packetProto.leftVolume;
                self.volumeView.rightVolumeValue = self.packetProto.rightVolume;
                
                // 更新耳机频响参数
                [self.freqResponseView setLeftFreqResponseValue: self.packetProto.leftFreqs];
                
                // 更新护耳参数
                [self.protectEarView setEarCompressValue:self.packetProto.leftEarProtection rightEarCompressValue:self.packetProto.rightEarProtection];
                
            /* 设置耳机当前模式（户内、户外、其他） */
            } else if (cmdId == AXON_COMMAND_MODE_SELECTION) {
                NSLog(@"收到ACK: AXON_COMMAND_MODE_SELECTION errCode: %ld", self.packetProto.errCode);
            /* 设置左右耳音量 */
            } else if (cmdId == AXON_COMMAND_CONTROL_VOLUME) {
                NSLog(@"收到ACK: AXON_COMMAND_CONTROL_VOLUME errCode: %ld", self.packetProto.errCode);
            /* 设置左右耳频响参数 */
            } else if (cmdId == AXON_COMMAND_SET_FREQ) {
                NSLog(@"收到ACK: AXON_COMMAND_SET_FREQ errCode: %ld", self.packetProto.errCode);
            /* 设置左右耳听力保护等级 */
            } else if (cmdId == AXON_COMMAND_EAR_PROTECT_SET) {
                NSLog(@"收到ACK: AXON_COMMAND_EAR_PROTECT_SET errCode: %ld", self.packetProto.errCode);
            /* 设置耳机进入DUT模式 */
            } else if (cmdId == AXON_COMMAND_DUT_MODE) {
                NSLog(@"收到ACK: AXON_COMMAND_DUT_MODE errCode: %ld", self.packetProto.errCode);
            /* 设置耳机进入出厂设置模式 */
            } else if (cmdId == AXON_COMMAND_FACTORY_MODE) {
                NSLog(@"收到ACK: AXON_COMMAND_FACTORY_MODE errCode: %ld", self.packetProto.errCode);
            /* 设置耳机进入OTA模式 */
            } else if (cmdId == AXON_COMMAND_OTA_MODE) {
                NSLog(@"收到ACK: AXON_COMMAND_OTA_MODE errCode: %ld", self.packetProto.errCode);
            /* 设置耳机进入单耳模式 */
            } else if (cmdId == AXON_COMMAND_SINGLE_MODE) {
                NSLog(@"收到ACK: AXON_COMMAND_SINGLE_MODE errCode: %ld", self.packetProto.errCode);
            }
        }];
    }];
}

- (UIImage*) getBatLevelImage:(NSUInteger)value
{
    if (value >=0 && value < 10) {
        return [UIImage imageNamed:@"0％"];
    } else if (value >=10 && value < 25) {
        return [UIImage imageNamed:@"25％"];
    } else if (value >= 25 && value < 50) {
        return [UIImage imageNamed:@"50％"];
    } else if (value >=50 && value < 75) {
        return [UIImage imageNamed:@"75％"];
    } else {
        return [UIImage imageNamed:@"100％"];
    }
}

- (void) setLeftEarBatteryLevel:(NSUInteger)leftEarBatteryLevel
{
    if (leftEarBatteryLevel == 0xFF || leftEarBatteryLevel == 0x00) {
        self.leftBatLabel.hidden = true;
        self.leftBatImageView.hidden = true;
    } else {
        self.leftBatImageView.hidden = false;
        self.leftBatLabel.hidden = false;
        [self.leftBatImageView setImage:[self getBatLevelImage:leftEarBatteryLevel]];
    }
}

- (void) setRightEarBatteryLevel:(NSUInteger)rightEarBatteryLevel
{
    if (rightEarBatteryLevel == 0xFF || rightEarBatteryLevel == 0x00) {
        self.rightBatLabel.hidden = true;
        self.rightBatImageView.hidden = true;
    } else {
        self.rightBatImageView.hidden = false;
        self.rightBatLabel.hidden = false;
        [self.rightBatImageView setImage:[self getBatLevelImage:rightEarBatteryLevel]];
    }
}

- (void) getDeviceInfo
{
    NSData* queryDeviceInfoPkt = [[PacketProto getInstance] packInfoQuery];
    NSLog(@"queryDeviceInfoPkt: %@", queryDeviceInfoPkt);
    [[BleProfile getInstance] writeDeviceData:queryDeviceInfoPkt callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
        NSLog(@"写入设备信息查询指令成功");
    }];

    NSData* queryAncState = [self.packetProto packAncStateQuery];
    [[BleProfile getInstance] writeDeviceData:queryAncState callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
        NSLog(@"写入ANC状态查询指令成功");
    }];

    NSData* queryVolume = [self.packetProto packVolumeStateQuery];
    [[BleProfile getInstance] writeDeviceData:queryVolume callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
        NSLog(@"写入声音查询指令成功");
    }];
}

- (void) sendTestData
{
    self.testCount++;
    
    if (self.testCount >= 20) {
        return;
    }
    
    switch (self.testCount) {
        case 1:
        {
            NSData* queryDeviceInfoPkt = [[PacketProto getInstance] packInfoQuery];
            NSLog(@"queryDeviceInfoPkt: %@", queryDeviceInfoPkt);
            [[BleProfile getInstance] writeDeviceData:queryDeviceInfoPkt callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
                NSLog(@"写入设备信息查询指令成功");
            }];
        }
            break;
        case 2:
        {
            self.packetProto.ancState = AXON_ANC_OUTER;
            NSData* ancStatePacket = [self.packetProto packAncSwitch];
            [[BleProfile getInstance] writeDeviceData:ancStatePacket callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
                NSLog(@"写入ANC切换指令成功");
            }];
        }
            break;
            
        case 3:
        {
            NSData* queryAncState = [self.packetProto packAncStateQuery];
            [[BleProfile getInstance] writeDeviceData:queryAncState callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
                NSLog(@"写入ANC状态查询指令成功");
            }];
        }
            break;
        case 4:
        {
            NSData* queryVolume = [self.packetProto packVolumeStateQuery];
            [[BleProfile getInstance] writeDeviceData:queryVolume callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
                NSLog(@"写入声音查询指令成功");
            }];
        }
            break;
        case 5:
        {
            self.packetProto.mode = AXON_MODE_INDOOR;
            NSData* modeSet = [self.packetProto packVolumeModeSet];
            [[BleProfile getInstance] writeDeviceData:modeSet callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
                NSLog(@"写入模式设置指令成功");
            }];
        }
            break;
        case 6:
        {
            self.packetProto.leftVolume = 20;
            self.packetProto.rightVolume = 30;
            NSData* volumeControl = [self.packetProto packVolumeControl];
            [[BleProfile getInstance] writeDeviceData:volumeControl callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
                NSLog(@"写入音量控制指令成功");
            }];
        }
        case 7:
        {
            unsigned char leftFreqs[] = {1, 2, 3, 4, 5};
            unsigned char rightFreqs[] = {7, 8, 9, 10, 11};
            self.packetProto.leftFreqs = [[NSData alloc] initWithBytes:leftFreqs length:sizeof(leftFreqs)];
            self.packetProto.rightFreqs = [[NSData alloc] initWithBytes:rightFreqs length:sizeof(rightFreqs)];
            NSData* freqsSet = [self.packetProto packFreqSet];
            [[BleProfile getInstance] writeDeviceData:freqsSet callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
                NSLog(@"写入频响控制指令成功");
            }];
        }
        case 8:
        {
            self.packetProto.leftEarProtection = 1;
            self.packetProto.rightEarProtection = 2;
            NSData* data = [self.packetProto packEarProtectModeSet];
            [[BleProfile getInstance] writeDeviceData:data callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
                NSLog(@"写入护耳控制指令成功");
            }];
        }
        case 9:
            [[BleProfile getInstance] writeDeviceData:[self.packetProto packDutModeSet] callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
                NSLog(@"写入DUT控制指令成功");
            }];
            break;
        case 10:
            [[BleProfile getInstance] writeDeviceData:[self.packetProto packFactoryModeSet] callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
                NSLog(@"写入恢复工厂设置指令成功");
            }];
            break;
        case 11:
            [[BleProfile getInstance] writeDeviceData:[self.packetProto packOtaModeSet] callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
                NSLog(@"写入OTA指令成功");
            }];
        case 12:
            [[BleProfile getInstance] writeDeviceData:[self.packetProto packSingleEarModeSet] callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
                NSLog(@"写入单耳模式指令成功");
            }];
            break;
            
        default:
            break;
    }

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
                                
                                self.testCount = 0;
                                [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getDeviceInfo) userInfo:nil repeats:NO];
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
