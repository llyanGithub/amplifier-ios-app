//
//  ModeView.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/10.
//

#import "ModeView.h"

@interface ModeView()

@property (nonatomic) ModeButton* outdoorButton;
@property (nonatomic) ModeButton* indoorButton;
@property (nonatomic) ModeButton* normalButton;

@property (nonatomic) UILabel* titleLable;
@property (nonatomic) UILabel* contentLabel;

@end

@implementation ModeView
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGRect mainFrame = [UIScreen mainScreen].bounds;
        
        NSUInteger topMargin = 20;
        NSUInteger horizontalMargin = 20;
        NSUInteger buttonHeight = 80;
        NSUInteger buttonWidth = mainFrame.size.width - horizontalMargin*2;
        NSUInteger spacing = 20;
        
        UIFont* font = [UIFont systemFontOfSize:12];
        
        self.outdoorButton = [self allocButton:CGRectMake(horizontalMargin, topMargin, buttonWidth, buttonHeight) checkedImageName:@"户外选中" unCheckedImageName:@"户外" titleText:@"户外模式"];
        self.indoorButton = [self allocButton:CGRectMake(horizontalMargin, buttonHeight+spacing+topMargin, buttonWidth, buttonHeight) checkedImageName:@"室内选中" unCheckedImageName:@"室内" titleText:@"室内模式"];
        self.normalButton = [self allocButton:CGRectMake(horizontalMargin, buttonHeight*2+spacing*2+topMargin, buttonWidth, buttonHeight)  checkedImageName:@"常规选中" unCheckedImageName:@"常规" titleText:@"常规模式"];
        
        
        NSUInteger labelTopMargin = 10;
        NSUInteger labelYPos = buttonHeight*3+spacing*2+topMargin + labelTopMargin;
        
        self.titleLable = [[UILabel alloc] initWithFrame:CGRectMake(horizontalMargin, labelYPos, buttonWidth, 40)];
        self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalMargin, labelYPos+spacing+10, buttonWidth, 40)];
        
        self.titleLable.text = @"常规模式：用于地铁或飞机等场景";
        self.contentLabel.text = @"请在其中选择最合适您的模式进行使用。\n如左右耳都已连接设备，将同步进行模式切换";
        self.contentLabel.numberOfLines = 2;
        [self.titleLable setFont:font];
        [self.contentLabel setFont:font];
        
        [self addSubview:self.outdoorButton];
        [self addSubview:self.indoorButton];
        [self addSubview:self.normalButton];
        [self addSubview:self.titleLable];
        [self addSubview:self.contentLabel];
    }
    return self;
}

- (ModeButton*)allocButton:(CGRect)frame checkedImageName:(NSString*)checkedImageName unCheckedImageName:(NSString*)unCheckedImageName titleText:(NSString*)titleText
{
    ModeButton* button = [[ModeButton alloc] initWithCheckedImage:frame checkedImage:[UIImage imageNamed:checkedImageName] unCheckedImage:[UIImage imageNamed:unCheckedImageName]];
    [button  setTitle:titleText forState:UIControlStateNormal];
    [button layoutButtonWithImageStyle:ButtonImageStyleTop imageTitleToSpace:20];
    
    [button setCornerRadius:10.0];
    
    return button;
}

@end
