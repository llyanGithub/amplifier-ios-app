//
//  VolumeView.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/10.
//

#import "VolumeView.h"
#import "VolumeSlider.h"
#import "SelectedButton.h"

@interface VolumeView ()

@property (nonatomic) UISlider* leftVolumeSlider;
@property (nonatomic) UISlider* rightVolumeSlider;

@property (nonatomic) NSArray* sliderArray;
@property (nonatomic) NSUInteger leftVolumeValue;
@property (nonatomic) NSUInteger rightVolumeValue;

@property (nonatomic) UILabel* leftVolumeLabel;
@property (nonatomic) UILabel* rightVolumeLabel;

@property (nonatomic) SelectedButton* leftChannButton;
@property (nonatomic) SelectedButton* rightChannButton;
@property (nonatomic) SelectedButton* allChanButton;

@property (nonatomic) NSArray* buttonGroup;

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
        
        self.leftVolumeSlider = [[VolumeSlider alloc] initWithPosStyle:CGRectMake(leftSliderPosX, topMargin+sliderTopMargin, sliderWidth, sliderHeight) posStyle:SliderPosVertical];
        self.rightVolumeSlider = [[VolumeSlider alloc] initWithPosStyle:CGRectMake(rightSliderPosX, topMargin+sliderTopMargin, sliderWidth, sliderHeight) posStyle:SliderPosVertical];
        
        
        [self.leftVolumeSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.rightVolumeSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        self.leftVolumeSlider.minimumValue = 0;
        self.leftVolumeSlider.maximumValue = 100;
        self.leftVolumeValue = 50;
        
        self.rightVolumeSlider.minimumValue = 0;
        self.rightVolumeSlider.maximumValue = 100;
        self.rightVolumeValue = 50;
        
        self.sliderArray = @[self.leftVolumeSlider, self.rightVolumeSlider];
        
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

- (void)setLeftVolumeValue:(NSUInteger)leftVolumeValue
{
    _leftVolumeValue = leftVolumeValue;
    self.leftVolumeSlider.value = _leftVolumeValue;
    self.leftVolumeLabel.text = [NSString stringWithFormat:@"%ld%%", _leftVolumeValue];
}

- (void)setRightVolumeValue:(NSUInteger)rightVolumeValue
{
    _rightVolumeValue = rightVolumeValue;
    self.rightVolumeSlider.value = _rightVolumeValue;
    self.rightVolumeLabel.text = [NSString stringWithFormat:@"%ld%%", _rightVolumeValue];
}

- (void)sliderValueChanged:(VolumeSlider*)sender
{
    NSUInteger roundedValue = round(sender.value / sender.step) * sender.step;
    sender.value = roundedValue;
    
    NSUInteger index = [self.sliderArray indexOfObject:sender];
    if (index == 0) {
        self.leftVolumeLabel.text = [NSString stringWithFormat:@"%ld%%", roundedValue];
        NSLog(@"Left Volume Changed: value: %ld", roundedValue);
    } else if (index == 1) {
        self.rightVolumeLabel.text = [NSString stringWithFormat:@"%ld%%", roundedValue];
        NSLog(@"Right Volume Changed: value: %ld", roundedValue);
    }
}

- (UIView*) createChannButtonView
{
    UIStackView* stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionFillEqually;
    
    self.leftChannButton = [[SelectedButton alloc] initWithImage:[UIImage imageNamed:@"左"] unCheckedImage:[UIImage imageNamed:@"左耳灰"]];
    
    self.rightChannButton = [[SelectedButton alloc] initWithImage:[UIImage imageNamed:@"右"] unCheckedImage:[UIImage imageNamed:@"右耳灰"]];
    
    self.allChanButton = [[SelectedButton alloc] initWithImage:[UIImage imageNamed:@"链接选中"] unCheckedImage:[UIImage imageNamed:@"链接"]];
    
    [stackView addArrangedSubview:self.leftChannButton];
    [stackView addArrangedSubview:self.allChanButton];
    [stackView addArrangedSubview:self.rightChannButton];
    
    self.buttonGroup = @[self.leftChannButton, self.rightChannButton, self.allChanButton];
    
    for (SelectedButton* button in self.buttonGroup) {
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchDown];
    }
    
    return (UIView*)stackView;
}

- (void) buttonClicked:(SelectedButton*)sender
{
    NSUInteger index = [self.buttonGroup indexOfObject:sender];
    if (index == 0 || index == 1) {
        sender.checked = !sender.checked;
        if (self.leftChannButton.checked && self.rightChannButton.checked) {
            self.allChanButton.checked = true;
        } else if (!self.leftChannButton.checked && !self.rightChannButton.checked) {
            self.allChanButton.checked = false;
        }

    } else if (index == 2) {
        BOOL checked = !sender.checked;
        for (SelectedButton* button in self.buttonGroup) {
            button.checked = checked;
        }
    }
    
    self.leftVolumeSlider.enabled = self.leftChannButton.checked;
    self.rightVolumeSlider.enabled = self.rightChannButton.checked;
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
