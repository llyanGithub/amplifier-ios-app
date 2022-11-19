//
//  ConnectedView.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/16.
//

#import "ConnectedView.h"
#import "ViewController.h"
#import "ScreenAdapter.h"


@interface ConnectedView ()
@property (weak, nonatomic) IBOutlet UIImageView *twsImageView;
@property (weak, nonatomic) IBOutlet UILabel *connectedLabel;

@property (nonatomic) UIButton* jumpMainButton;

@end

@implementation ConnectedView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect mainFrame = [UIScreen mainScreen].bounds;
    NSUInteger topMargin = SHReadValue(200);
    NSUInteger imageSize = SWReadValue(270);
    
    self.twsImageView.frame = CGRectMake(mainFrame.size.width/2 - imageSize/2, topMargin, imageSize, imageSize);
    
    NSUInteger labelTopMargin = SHReadValue(20);
    NSUInteger labelWidth = SWReadValue(150);
    NSUInteger labelHeight = SHReadValue(20);
    
    self.jumpMainButton = [[UIButton alloc] initWithFrame:CGRectMake(SWReadValue(20), SHReadValue(60), SWReadValue(20), SHReadValue(20))];
    [self.jumpMainButton setImage:[UIImage imageNamed:@"返回主页按钮"] forState:UIControlStateNormal];
    [self.jumpMainButton addTarget:self action:@selector(jumpMainButtonClicked) forControlEvents:UIControlEventTouchDown];
    self.jumpMainButton.hidden = true;
    
    [self.view addSubview:self.jumpMainButton];
    
    self.connectedLabel.textAlignment = NSTextAlignmentCenter;
    self.connectedLabel.frame = CGRectMake(mainFrame.size.width/2 - labelWidth/2, topMargin + imageSize + labelTopMargin, labelWidth, labelHeight);
    
    if (self.deviceType == TWS_DEVICE_TYPE_D) {
        [self.twsImageView setImage:[UIImage imageNamed:@"豆式耳机"]];
    } else if (self.deviceType == TWS_DEVICE_TYPE_G) {
        [self.twsImageView setImage:[UIImage imageNamed:@"杆式耳机"]];
    }
    
    self.connectedLabel.text = [NSString stringWithFormat:@"%@ %@", self.deviceName, NSLocalizedString(@"connected", nil)];
    
    self.backFromMainVC = NO;
    
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(jump2Main) userInfo:nil repeats:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier  isEqual: @"segueMain"]) {
        NSLog(@"prepareForSegue");
        ViewController* destView = (ViewController*)segue.destinationViewController;
        
        //为视图控制器设置过渡类型
        destView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
        //为视图控制器设置显示样式
        destView.modalPresentationStyle = UIModalPresentationFullScreen;
    }
}

- (void) jump2Main
{
    NSLog(@"Jump To Main View");
    
    [self performSegueWithIdentifier:@"segueMain" sender:self];
}

- (void) jumpMainButtonClicked
{
    NSLog(@"jumpMainButtonClicked");
    self.backFromMainVC = NO;
    [self jump2Main];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark- life cycle

//- (void)viewWillLayoutSubviews {
//    [super viewWillLayoutSubviews];
//    NSLog(@"========   将要布局子视图： viewWillLayoutSubviews   =======\n");
//}
//
//- (void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//    NSLog(@"========   已经布局子视图： viewDidLayoutSubviews   =======\n");
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    NSLog(@"========   收到内存警告： didReceiveMemoryWarning   =======\n");
//}
//
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"========   视图将要出现： viewWillAppear:(BOOL)animated   =======\n");
    if (self.isDismiss) {
        [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
        return;
    }
    if (self.backFromMainVC) {
        self.jumpMainButton.hidden = false;
    }
}
//
//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    NSLog(@"========   视图已经出现： viewDidAppear:(BOOL)animated   =======\n");
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    NSLog(@"========   视图将要消失： viewWillDisappear:(BOOL)animated   =======\n");
//}
//
//- (void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
//    NSLog(@"========   视图已经消失： viewDidDisappear:(BOOL)animated   =======\n");
//}
//
//- (void)dealloc {
//    NSLog(@"========   释放： dealloc   =======\n");
//}

@end
