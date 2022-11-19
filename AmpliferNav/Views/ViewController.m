//
//  ViewController.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/8.
//

#import "ViewController.h"
#import "ScreenAdapter.h"
#import "HomeViewController.h"
#import "LeftViewController.h"


@interface ViewController ()

@property (nonatomic) HomeViewController* homeViewController;
@property (nonatomic) LeftViewController* leftViewController;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.leftViewController = [LeftViewController getInstance];
    self.homeViewController = [HomeViewController getInstance];
    
    self.homeViewController.view.backgroundColor = UIColor.whiteColor;
    self.homeViewController.revealViewController = self;
    
    self.leftViewController.view.backgroundColor = UIColor.whiteColor;
    
//    [self initDe]
    [self setViewController:self.leftViewController frontViewController:self.homeViewController];
    self.rightViewController = nil;
    
    //浮动层离左边距的宽度
    self.rearViewRevealWidth = 230;
    //    revealViewController.rightViewRevealWidth = 230;
    
    //是否让浮动层弹回原位
    //mainRevealController.bounceBackOnOverdraw = NO;
    [self setFrontViewPosition:FrontViewPositionLeft animated:YES];
    
    [self.view addGestureRecognizer: self.panGestureRecognizer];
}

- (void)dealloc {
    NSLog(@"======== ViewController  释放： dealloc   =======\n");
    
//    [self.leftViewController dealloc];
}

@end
