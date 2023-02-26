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
        
        NSUInteger channTopMargin = SHReadValue(20);
        NSUInteger channButtonWidth = SWReadValue(80);
        NSUInteger channButtonHeight = SHReadValue(54);
        NSUInteger channButtonPosY = topMargin + sliderTopMargin + sliderHeight + channTopMargin;

        [self createChannButtonView];
        self.leftChannButton.frame = CGRectMake(self.leftVolumeSlider.frame.origin.x + self.leftVolumeSlider.frame.size.width/2-channButtonWidth/2, channButtonPosY, channButtonWidth, channButtonHeight);
        self.rightChannButton.frame = CGRectMake(self.rightVolumeSlider.frame.origin.x + self.leftVolumeSlider.frame.size.width/2 - channButtonWidth/2, channButtonPosY, channButtonWidth, channButtonHeight);
        
        NSUInteger allChannelButtonWidth = SWReadValue(50);
        NSUInteger allChannelButtonHeight = SWReadValue(34);
        NSUInteger allChannButtonPosX = (self.rightChannButton.frame.origin.x - self.leftChannButton.frame.origin.x)/2 + self.leftChannButton.frame.origin.x + channButtonWidth/2 - allChannelButtonWidth/2;
        NSUInteger allChannButtonPosY = self.leftChannButton.frame.origin.y + self.leftChannButton.frame.size.height/2 - allChannelButtonHeight/2;
        self.allChanButton.frame = CGRectMake(allChannButtonPosX, allChannButtonPosY, allChannelButtonWidth, allChannelButtonHeight);
        
        NSUInteger labelsViewTopMargin = SHReadValue(2);
        NSUInteger labelsViewHeight = SHReadValue(35);
        NSUInteger labelsWidth = SWReadValue(60);
        NSUInteger labelsViewPosY = channButtonPosY + channButtonHeight + labelsViewTopMargin;
        
        [self createLabelsView];
        self.leftChannLabel.frame = CGRectMake(self.leftVolumeSlider.frame.origin.x + self.leftVolumeSlider.frame.size.width/2 - labelsWidth/2, labelsViewPosY, labelsWidth*2, labelsViewHeight);
        self.rightChannLabel.frame = CGRectMake(self.rightVolumeSlider.frame.origin.x + self.rightVolumeSlider.frame.size.width/2 - labelsWidth/2, labelsViewPosY, labelsWidth*2, labelsViewHeight);
        
        [self addSubview:self.leftChannButton];
        [self addSubview:self.rightChannButton];
        [self addSubview:self.allChanButton];
        [self addSubview:self.leftChannLabel];
        [self addSubview:self.rightChannLabel];
        
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

- (void) createChannButtonView
{
    self.leftChannButton = [[SelectedButton alloc] initWithImage:[UIImage imageNamed:@"左"] unCheckedImage:[UIImage imageNamed:@"左耳灰"]];
    self.rightChannButton = [[SelectedButton alloc] initWithImage:[UIImage imageNamed:@"右"] unCheckedImage:[UIImage imageNamed:@"右耳灰"]];
    
    self.allChanButton = [[SelectedButton alloc] initWithImage:[UIImage imageNamed:@"链接选中"] unCheckedImage:[UIImage imageNamed:@"链接"]];
    self.allChanButton.checked = NO;
    
    self.buttonGroup = @[self.leftChannButton, self.rightChannButton, self.allChanButton];
    
    for (SelectedButton* button in self.buttonGroup) {
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchDown];
    }
}

- (void) buttonClicked:(SelectedButton*)sender
{
    sender.checked = !sender.checked;
    
    self.leftVolumeSlider.enabled = self.leftChannButton.checked;
    self.rightVolumeSlider.enabled = self.rightChannButton.checked;
}

- (void) createLabelsView
{
    self.leftChannLabel = [[UILabel alloc] init];
    self.rightChannLabel = [[UILabel alloc] init];
    
    self.leftChannLabel.text = NSLocalizedString(@"leftEar", nil);
    self.leftChannLabel.textAlignment = NSTextAlignmentCenter;
    self.rightChannLabel.text = NSLocalizedString(@"rightEar", nil);
    self.rightChannLabel.textAlignment = NSTextAlignmentCenter;
}

@end
