//
//  LoadingView.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/16.
//

#import "LoadingView.h"
#import "ImageViewGif.h"
#import "ReadySearchView.h"


@interface LoadingView ()

@end

@implementation LoadingView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ImageViewGif* gifView = [[ImageViewGif alloc] initWithDuration:3 delegate:self];
    [gifView startGif];
    [self.view addSubview:gifView];
    NSLog(@"viewDidLoad");
}

- (void)gifStopped
{
    NSLog(@"gif stopped");

    // 执行segue
    [self performSegueWithIdentifier:@"segue1" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier  isEqual: @"segue1"]) {
        NSLog(@"prepareForSegue");
        ReadySearchView* destView = (ReadySearchView*)segue.destinationViewController;
        
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
