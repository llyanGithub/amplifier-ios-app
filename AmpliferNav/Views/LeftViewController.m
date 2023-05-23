//
//  LeftViewController.m
//  Amplifer
//
//  Created by 鄢陵龙 on 2022/11/19.
//

#import "LeftViewController.h"
#import "SWRevealViewController.h"
#import "BleProfile.h"
#import "PacketProto.h"
#import "ScreenAdapter.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

@interface LeftViewController ()

@property (nonatomic , strong) UITableView *tableView;

@property (nonatomic , strong) NSArray *menuArray;

@property (nonatomic, strong) UIImageView* imageView;

@end

@implementation LeftViewController

+ (LeftViewController*) getInstance
{
    static dispatch_once_t predWex = 0;
    __strong static LeftViewController* _sharedWexObject = nil;
    dispatch_once(&predWex, ^
                  {
                      _sharedWexObject = [[self alloc] init];
                  });
    return _sharedWexObject;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self initData];
    [self initView];
}

-(void)initData{
    _menuArray = [NSArray arrayWithObjects: NSLocalizedString(@"factorySettings", nil), nil];
}

-(void)initView{
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    NSUInteger logoHeight = SWReadValue(66);
    NSUInteger logoWidth = SWReadValue(128);
    
    NSUInteger tablePosY = logoHeight + SHReadValue(80);
    NSUInteger tableHeight = SCREEN_HEIGHT - tablePosY;
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tablePosY, SCREEN_WIDTH, tableHeight) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = UIColor.whiteColor;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AppIcon"]];
//    self.imageView.backgroundColor = UIColor.redColor;
    self.imageView.frame = CGRectMake(SWReadValue(60), SHReadValue(60), logoWidth, logoHeight);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview:_tableView];
    [self.view addSubview:self.imageView];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _menuArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *TABLE_VIEW_ID = @"table_view_id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLE_VIEW_ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TABLE_VIEW_ID];
    }
    cell.textLabel.text = [_menuArray objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SWRevealViewController *revealViewController = self.revealViewController;
//    UIViewController *viewController;
    
    NSLog(@"LeftViewController indexPath.row: %ld", indexPath.row);
    
    switch (indexPath.row) {
        /*
         进入恢复工厂模式
         */
        case 0:
        {
            NSLog(@"Enter Factory MODE");
            NSData* data = [[PacketProto getInstance] packFactoryModeSet];
            
            [[BleProfile getInstance] writeDeviceData:data callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
                NSLog(@"写入工厂模式命令成功");
            }];
        }
            break;
            
        /*
         DUT模式
         */
        case 1:
        {
            NSData* data = [[PacketProto getInstance] packDutModeSet];
            [[BleProfile getInstance] writeDeviceData:data callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
                NSLog(@"写入DUT命令成功");
            }];
        }
            break;;
            
        /*
         进入单耳模式
         */
        case 2:
        {
            NSLog(@"Enter Single Ear MODE");
            
            NSData* data = [[PacketProto getInstance] packSingleEarModeSet];
            
            [[BleProfile getInstance] writeDeviceData:data callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
                NSLog(@"写入单耳命令成功");
            }];
        }
            break;
        case 3:
        {
            /*
             进入OTA模式
             */
            NSLog(@"Enter OTA MODE");
            NSData* data = [[PacketProto getInstance] packOtaModeSet];
            
            [[BleProfile getInstance] writeDeviceData:data callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
                NSLog(@"写入OTA命令成功");
            }];
        }
            break;
        default:
            break;
    }
    //调用pushFrontViewController进行页面切换
    [revealViewController revealToggleAnimated:YES];
//    [revealViewController pushFrontViewController:viewController animated:YES];
    
}

@end
