//
//  VolumeView.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/10.
//

#import "VolumeView.h"
#import "VolumeSlider.h"
#import "SelectedButton.h"
#import "PacketProto.h"
#import "BleProfile.h"
#import "ScreenAdapter.h"


@interface VolumeView ()

@property (nonatomic) UISlider* leftVolumeSlider;
@property (nonatomic) UISlider* rightVolumeSlider;

@property (nonatomic) NSArray* sliderArray;

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
        
        NSUInteger topMargin = SHReadValue(30);
        NSUInteger sliderTopMargin = SHReadValue(40);
        
        NSUInteger sliderWidth = SWReadValue(40);
        NSUInteger sliderHeight = SHReadValue(250);
        
        NSUInteger sliderHorizontalMargin = SHReadValue(80);

        
        NSUInteger leftSliderPosX = sliderHorizontalMargin;
        NSUInteger rightSliderPosX = mainFrame.size.width - sliderHorizontalMargin - sliderWidth;
        
        NSUInteger leftVolumeLabelPosX = leftSliderPosX + SWReadValue(5);
        NSUInteger rightVolumeLabelPosX = rightSliderPosX + SWReadValue(5);
        self.leftVolumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftVolumeLabelPosX, topMargin, SWReadValue(50), SHReadValue(30))];
        self.rightVolumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(rightVolumeLabelPosX, topMargin, SWReadValue(50), SHReadValue(30))];
        
        self.leftVolumeSlider = [[VolumeSlider alloc] initWithPosStyle:CGRectMake(leftSliderPosX, topMargin+sliderTopMargin, sliderWidth, sliderHeight) posStyle:SliderPosVertical];
        self.rightVolumeSlider = [[VolumeSlider alloc] initWithPosStyle:CGRectMake(rightSliderPosX, topMargin+sliderTopMargin, sliderWidth, sliderHeight) posStyle:SliderPosVertical];
        
        
        [self.leftVolumeSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.rightVolumeSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self.leftVolumeSlider addTarget:self action:@selector(sliderReleased:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
        
        [self.rightVolumeSlider addTarget:self action:@selector(sliderReleased:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
        
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
        
        NSUInteger channHorizontalMargin = SWReadValue(65);
        NSUInteger channTopMargin = SHReadValue(20);
        NSUInteger channButtonHeight = SHReadValue(35);
        NSUInteger channButtonPosY = topMargin + sliderTopMargin + sliderHeight + channTopMargin;
        
        UIView* channButtonView = [self createChannButtonView];
        channButtonView.frame = CGRectMake(channHorizontalMargin, channButtonPosY, mainFrame.size.width - 2*channHorizontalMargin, channButtonHeight);
        
        NSUInteger labelsViewHorizontalMargin = SWReadValue(100);
        NSUInteger labelsViewTopMargin = SHReadValue(2);
        NSUInteger labelsViewHeight = SHReadValue(35);
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

- (void)sliderReleased:(VolumeSlider*)sender
{
    NSLog(@"sliderReleased leftVolume: %ld rightVolume: %ld", self.leftVolumeValue, self.rightVolumeValue);
    [PacketProto getInstance].leftVolume = self.leftVolumeValue;
    [PacketProto getInstance].rightVolume = self.rightVolumeValue;
    
    NSData* volumeControl = [[PacketProto getInstance] packVolumeControl];
    [[BleProfile getInstance] writeDeviceData:volumeControl callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
        NSLog(@"写入音量控制指令成功");
    }];
}

- (void)sliderValueChanged:(VolumeSlider*)sender
{
    NSUInteger roundedValue = round(sender.value / sender.step) * sender.step;
    sender.value = roundedValue;
    
    NSUInteger index = [self.sliderArray indexOfObject:sender];
    if (index == 0) {
        _leftVolumeValue = roundedValue;
        self.leftVolumeLabel.text = [NSString stringWithFormat:@"%ld%%", roundedValue];
        
        if (self.allChanButton.checked && self.rightVolumeSlider.enabled) {
            _rightVolumeValue = roundedValue;
            self.rightVolumeSlider.value = roundedValue;
            self.rightVolumeLabel.text = [NSString stringWithFormat:@"%ld%%", roundedValue];
        }

    } else if (index == 1) {
        _rightVolumeValue = roundedValue;
        self.rightVolumeLabel.text = [NSString stringWithFormat:@"%ld%%", roundedValue];

        if (self.allChanButton.checked && self.leftVolumeSlider.enabled) {
            _leftVolumeValue = roundedValue;
            self.leftVolumeSlider.value = roundedValue;
            self.leftVolumeLabel.text = [NSString stringWithFormat:@"%ld%%", roundedValue];
        }
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
    self.allChanButton.checked = NO;
    
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
    sender.checked = !sender.checked;
    
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
    
    self.leftChannLabel.text = NSLocalizedString(@"leftEar", nil);
    self.rightChannLabel.text = NSLocalizedString(@"rightEar", nil);
    
    [stackView addArrangedSubview:self.leftChannLabel];
    [stackView addArrangedSubview:self.rightChannLabel];
    
    return stackView;
}

@end
