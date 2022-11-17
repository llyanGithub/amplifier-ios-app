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

@interface ReadySearchView ()

@end

@implementation ReadySearchView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)buttonClicked:(UIButton *)sender {
    NSLog(@"Search Button Clicked");
    [self performSegueWithIdentifier:@"segue2" sender:self];
    
    CGRect mainFrame = [UIScreen mainScreen].nativeBounds;
    NSLog(@"22 %ld %ld", self.view.frame.size.width, self.view.frame.size.height);
    NSLog(@"mainFrame: %ld %ld", mainFrame.size.width, mainFrame.size.height);
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
