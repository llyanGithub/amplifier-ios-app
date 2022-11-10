//
//  ViewController.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/8.
//

#import "ViewController.h"
#import "NavButton.h"

@interface ViewController ()
@property (nonatomic) UIStackView* mainStack;
@property (nonatomic) UIStackView* navStack;
@property (nonatomic) NSMutableArray* buttonsArray;
@property (nonatomic) NSMutableArray* viewsArray;
@property (nonatomic) CGRect mainFrame;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mainFrame = [UIScreen mainScreen].bounds;
    
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
    [self.viewsArray addObject:[self createViews:UIColor.blueColor frame:frame]];
    [self.viewsArray addObject:[self createViews:UIColor.brownColor frame:frame]];
    [self.viewsArray addObject:[self createViews:UIColor.clearColor frame:frame]];
    [self.viewsArray addObject:[self createViews:UIColor.cyanColor frame:frame]];
    [self.viewsArray addObject:[self createViews:UIColor.darkGrayColor frame:frame]];
    
    for (UIView* view in self.viewsArray) {
        [self.mainStack addSubview:view];
    }
    
    // 将按钮放入导航layout中
    for (UIView* button in self.buttonsArray) {
        [self.navStack addArrangedSubview:button];
    }
    
    [self.mainStack addSubview:self.navStack];
    
    [self.view addSubview:self.mainStack];
}

- (void) createStack
{
    self.mainStack = [[UIStackView alloc] initWithFrame: self.mainFrame];
    self.mainStack.axis = UILayoutConstraintAxisVertical;
    self.mainStack.distribution = UIStackViewDistributionEqualSpacing;
    
    //nav 的位置在（20,80） 距离屏幕左右边界各20个point， 高度是40
    self.navStack = [[UIStackView alloc] initWithFrame:CGRectMake(20, 80, self.mainFrame.size.width-40, 40)];
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
