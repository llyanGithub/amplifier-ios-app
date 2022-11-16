//
//  ConnectedView.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/16.
//

#import "ConnectedView.h"
#import "ViewController.h"


@interface ConnectedView ()
@property (weak, nonatomic) IBOutlet UIImageView *twsImageView;
@property (weak, nonatomic) IBOutlet UILabel *connectedLabel;

@end

@implementation ConnectedView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.deviceType == TWS_DEVICE_TYPE_D) {
        [self.twsImageView setImage:[UIImage imageNamed:@"豆式耳机"]];
    } else if (self.deviceType == TWS_DEVICE_TYPE_G) {
        [self.twsImageView setImage:[UIImage imageNamed:@"杆式耳机"]];
    }
    
    self.connectedLabel.text = [NSString stringWithFormat:@"%@ 已连接", self.deviceName];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
