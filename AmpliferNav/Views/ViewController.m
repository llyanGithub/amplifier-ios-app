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

@property (nonatomic) NSUInteger horizontalMargin;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mainFrame = [UIScreen mainScreen].bounds;
    self.horizontalMargin = 20;
    
    NSUInteger homeButtonTopMargin = 40;
    
    UIView* batteryView = [self createBatteryView];
    NSUInteger batteryViewWidth = 75;
    NSUInteger batteryPosX = self.mainFrame.size.width - self.horizontalMargin - batteryViewWidth;
    batteryView.frame = CGRectMake(batteryPosX, homeButtonTopMargin, batteryViewWidth, 25);
    
    self.homeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.horizontalMargin, homeButtonTopMargin, 20, 20)];
    [self.homeButton setImage:[UIImage imageNamed:@"返回主页按钮"] forState:UIControlStateNormal];
    
    [self createStack];
    
    // 创建5个导航按钮，并将其放入可变数组中
    self.buttonsArray = [[NSMutableArray alloc]init];
    [self.buttonsArray addObject:[self createNavButton:@"模式"]];
    [self.buttonsArray addObject:[self createNavButton:@"音量"]];
    [self.buttonsArray addObject:[self createNavButton:@"频响"]];
    [self.buttonsArray addObject:[self createNavButton:@"护耳"]];
    [self.buttonsArray addObject:[self createNavButton:@"其他"]];
    
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
    
//    [self.viewsArray addObject:[self createViews:UIColor.darkGrayColor frame:frame]];
    
    for (UIView* view in self.viewsArray) {
        [self.mainStack addSubview:view];
    }
    
    // 将按钮放入导航layout中
    for (UIView* button in self.buttonsArray) {
        [self.navStack addArrangedSubview:button];
    }
    
    [self.mainStack addSubview:self.navStack];
    
    [self.view addSubview:self.mainStack];
    [self.view addSubview:self.homeButton];
    [self.view addSubview:batteryView];
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
    
    //nav 的位置在（20,80） 距离屏幕左右边界各20个point， 高度是40
    self.navStack = [[UIStackView alloc] initWithFrame:CGRectMake(self.horizontalMargin, 80, self.mainFrame.size.width-self.horizontalMargin*2, 40)];
    self.navStack.axis = UILayoutConstraintAxisHorizontal;
    self.navStack.alignment = UIStackViewAlignmentFill;
    self.navStack.distribution = UIStackViewDistributionEqualSpacing;
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

- (UIButton*)createNavButton:(NSString*)titleName
{
    UIButton* button = [[UIButton alloc]init];
    [button setTitle:titleName forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(navButtonClicked:) forControlEvents:UIControlEventTouchDown];
    
    button.backgroundColor = UIColor.whiteColor;
    
    return button;
}

- (void)navButtonClicked:(UIButton *)sender
{
    NSUInteger index = [self.buttonsArray indexOfObject:sender];
    NSLog(@"button: %@ index: %ld clicked", sender.titleLabel.text, index);
    
    for (UIView* view in self.viewsArray) {
        view.hidden = true;
    }
    
    UIView* view = [self.viewsArray objectAtIndex: index];
    view.hidden = false;
}

@end
