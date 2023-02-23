//
//  ReadySearchView.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/16.
//

#import "ReadySearchView.h"
#import "SearchView.h"
#import "ImageViewGif.h"
#import "GifViewDelegate.h"
#import "ScreenAdapter.h"

@interface ReadySearchView ()
@property (weak, nonatomic) IBOutlet UIImageView *searchFrame;
@property (weak, nonatomic) IBOutlet UIButton *searchCenter;
@property (weak, nonatomic) IBOutlet UILabel *searchLabel;

@end

@implementation ReadySearchView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect mainFrame = [UIScreen mainScreen].bounds;
    NSUInteger searchFrameSize = SWReadValue(200);
    NSUInteger searchFramePosY = SHReadValue(230);
    
    self.searchFrame.frame = CGRectMake(mainFrame.size.width/2-searchFrameSize/2, searchFramePosY, searchFrameSize, searchFrameSize);
    
    
    NSUInteger searchCenterSize = SWReadValue(60);
    NSUInteger searchCenterPosY = searchFramePosY + searchFrameSize/2 - searchCenterSize/2;
    self.searchCenter.frame = CGRectMake(mainFrame.size.width/2-searchCenterSize/2, searchCenterPosY, searchCenterSize, searchCenterSize);
    
    NSUInteger labelWidth = SWReadValue(150);
    NSUInteger labelHeight = SWReadValue(20);
    NSUInteger labelPosY = searchFramePosY + searchFrameSize + SHReadValue(20);
    
    NSUInteger searchLabelWidth = mainFrame.size.width - SWReadValue(50);
    self.searchLabel.frame = CGRectMake(mainFrame.size.width/2-searchLabelWidth/2, labelPosY, searchLabelWidth, labelHeight);
    self.searchLabel.textAlignment = NSTextAlignmentCenter;
    
    self.searchLabel.text = NSLocalizedString(@"tapToSearch", nil);
}

- (IBAction)buttonClicked:(UIButton *)sender {
    NSLog(@"Search Button Clicked");
    [self performSegueWithIdentifier:@"segue2" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier  isEqual: @"segue2"]) {
        NSLog(@"prepareForSegue");
        SearchView* destView = (SearchView*)segue.destinationViewController;
        
        //为视图控制器设置过渡类型
        destView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
        //为视图控制器设置显示样式
        destView.modalPresentationStyle = UIModalPresentationFullScreen;
    }
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
