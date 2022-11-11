//
//  VolumeView.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/10.
//

#import "VolumeView.h"
#import "VolumeSlider.h"

@interface VolumeView ()

@property (nonatomic) UISlider* leftVolumeSlider;
@property (nonatomic) UISlider* rightVolumeSlider;

@property (nonatomic) UILabel* leftVolumeLabel;
@property (nonatomic) UILabel* rightVolumeLabel;

@property (nonatomic) UIButton* leftChannButton;
@property (nonatomic) UIButton* rightChannButton;
@property (nonatomic) UIButton* allChanButton;

@property (nonatomic) UILabel* leftChannLabel;
@property (nonatomic) UILabel* rightChannLabel;

@end

@implementation VolumeView

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
        NSUInteger sliderTopMargin = 40;
        
        NSUInteger sliderWidth = 40;
        NSUInteger sliderHeight = 250;
        
        NSUInteger sliderHorizontalMargin = 80;

        
        NSUInteger leftSliderPosX = sliderHorizontalMargin;
        NSUInteger rightSliderPosX = mainFrame.size.width - sliderHorizontalMargin - sliderWidth;
        
        self.leftVolumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftSliderPosX, topMargin, 50, 30)];
        self.rightVolumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(rightSliderPosX, topMargin, 50, 30)];
        self.leftVolumeLabel.text = @"100%";
        self.rightVolumeLabel.text = @"100%";
        
        self.leftVolumeSlider = [[VolumeSlider alloc] initWithPosStyle:CGRectMake(leftSliderPosX, topMargin+sliderTopMargin, sliderWidth, sliderHeight) posStyle:SliderPosVertical];
        self.rightVolumeSlider = [[VolumeSlider alloc] initWithPosStyle:CGRectMake(rightSliderPosX, topMargin+sliderTopMargin, sliderWidth, sliderHeight) posStyle:SliderPosVertical];
        
        [self addSubview:self.leftVolumeSlider];
        [self addSubview:self.rightVolumeSlider];
        
        [self addSubview:self.leftVolumeLabel];
        [self addSubview:self.rightVolumeLabel];
        
        NSUInteger channHorizontalMargin = 65;
        NSUInteger channTopMargin = 20;
        NSUInteger channButtonHeight = 35;
        NSUInteger channButtonPosY = topMargin + sliderTopMargin + sliderHeight + channTopMargin;
        
        UIView* channButtonView = [self createChannButtonView];
        channButtonView.frame = CGRectMake(channHorizontalMargin, channButtonPosY, mainFrame.size.width - 2*channHorizontalMargin, channButtonHeight);
        
        NSUInteger labelsViewHorizontalMargin = 80;
        NSUInteger labelsViewTopMargin = 2;
        NSUInteger labelsViewHeight = 35;
        NSUInteger labelsViewPosY = channButtonPosY + channButtonHeight + labelsViewTopMargin;
        
        UIView* labelsView = [self createLabelsView];
        labelsView.frame = CGRectMake(labelsViewHorizontalMargin, labelsViewPosY, mainFrame.size.width - 2*labelsViewHorizontalMargin, labelsViewHeight);
        
        [self addSubview:channButtonView];
        [self addSubview:labelsView];
        
        self.hidden = true;
    }
    return self;
}

- (UIView*) createChannButtonView
{
    UIStackView* stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionFillEqually;
    
    self.leftChannButton = [[UIButton alloc] init];
    [self.leftChannButton setImage:[UIImage imageNamed:@"左"] forState:UIControlStateNormal];
    
    self.rightChannButton = [[UIButton alloc] init];
    [self.rightChannButton setImage:[UIImage imageNamed:@"右"] forState:UIControlStateNormal];
    
    self.allChanButton = [[UIButton alloc] init];
    [self.allChanButton setImage:[UIImage imageNamed:@"链接选中"] forState:UIControlStateNormal];
    
    [stackView addArrangedSubview:self.leftChannButton];
    [stackView addArrangedSubview:self.allChanButton];
    [stackView addArrangedSubview:self.rightChannButton];
    
    return (UIView*)stackView;
}

- (UIView*) createLabelsView
{
    UIStackView* stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionEqualCentering;
    
    self.leftChannLabel = [[UILabel alloc] init];
    self.rightChannLabel = [[UILabel alloc] init];
    
    self.leftChannLabel.text = @"左耳";
    self.rightChannLabel.text = @"右耳";
    
    [stackView addArrangedSubview:self.leftChannLabel];
    [stackView addArrangedSubview:self.rightChannLabel];
    
    return stackView;
}

@end
