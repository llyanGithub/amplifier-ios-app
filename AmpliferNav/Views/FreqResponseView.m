//
//  FreqResponseView.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/10.
//

#import "FreqResponseView.h"
#import "VolumeSlider.h"
#import "PacketProto.h"
#import "BleProfile.h"
#import "ScreenAdapter.h"
#import "SelectedButton.h"


int freqResponseValues[5] = {50, 50, 50, 50, 50};

@interface FreqResponseView ()

@property (nonatomic) VolumeSlider* slider500;
@property (nonatomic) VolumeSlider* slider1K;
@property (nonatomic) VolumeSlider* slider2K;
@property (nonatomic) VolumeSlider* slider3K;
@property (nonatomic) VolumeSlider* slider4K;
@property (nonatomic) NSArray* sliderGroup;

@property (nonatomic) UILabel* valueLabel500;
@property (nonatomic) UILabel* valueLabel1K;
@property (nonatomic) UILabel* valueLabel2K;
@property (nonatomic) UILabel* valueLabel3K;
@property (nonatomic) UILabel* valueLabel4K;
@property (nonatomic) NSArray* valueLabelGroup;

@property (nonatomic) UILabel* label500;
@property (nonatomic) UILabel* label1K;
@property (nonatomic) UILabel* label2K;
@property (nonatomic) UILabel* label3K;
@property (nonatomic) UILabel* label4K;

@property (nonatomic) SelectedButton* leftEarSelectedButton;
@property (nonatomic) SelectedButton* rightEarSelectedButton;

@property (nonatomic) UILabel* leftChannLabel;
@property (nonatomic) UILabel* rightChannLabel;

@property (nonatomic) NSArray* buttonGroup;

@property (nonatomic) NSUInteger horizontalMargin;
@property (nonatomic) NSUInteger labelHeight;
@property (nonatomic) NSUInteger sliderHeight;

@end

@implementation FreqResponseView

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
        NSUInteger topMargin = SHReadValue(30);
        
        self.horizontalMargin = SWReadValue(30);
        self.labelHeight = SHReadValue(20);
        self.sliderHeight = SHReadValue(280);
        
        self.valueLabel500 = [self createValueLabel:0 posY:topMargin];
        self.valueLabel1K = [self createValueLabel:1 posY:topMargin];
        self.valueLabel2K = [self createValueLabel:2 posY:topMargin];
        self.valueLabel3K = [self createValueLabel:3 posY:topMargin];
        self.valueLabel4K = [self createValueLabel:4 posY:topMargin];
        self.valueLabelGroup = @[self.valueLabel500, self.valueLabel1K, self.valueLabel2K, self.valueLabel3K, self.valueLabel4K];
                
        NSUInteger sliderTopMargin = SHReadValue(10);
        NSUInteger sliderPosY = topMargin + self.labelHeight + sliderTopMargin;
        
        self.slider500 = [self createSlider:0 posY:sliderPosY];
        self.slider1K = [self createSlider:1 posY:sliderPosY];
        self.slider2K = [self createSlider:2 posY:sliderPosY];
        self.slider3K = [self createSlider:3 posY:sliderPosY];
        self.slider4K = [self createSlider:4 posY:sliderPosY];
        
        self.sliderGroup = @[self.slider500, self.slider1K, self.slider2K, self.slider3K, self.slider4K];
        
        [self updateAllFreqResponseValues];
        
        NSUInteger labelTopMargin = SHReadValue(10);
        NSUInteger labelPosY = sliderPosY + self.sliderHeight + labelTopMargin;
        
        self.label500 = [self createFreqLabel:0 posY:labelPosY title:@"500HZ"];
        self.label1K = [self createFreqLabel:1 posY:labelPosY title:@"1kHZ"];
        self.label2K = [self createFreqLabel:2 posY:labelPosY title:@"2kHZ"];
        self.label3K = [self createFreqLabel:3 posY:labelPosY title:@"3kHz"];
        self.label4K = [self createFreqLabel:4 posY:labelPosY title:@"4kHz"];
        
        NSUInteger channHorizontalMargin = SWReadValue(65);
        NSUInteger channTopMargin = SHReadValue(20);
        NSUInteger channButtonHeight = SHReadValue(35);
        NSUInteger channButtonPosY = self.label500.frame.origin.y + self.labelHeight + channTopMargin;
        
        UIView* channButtonView = [self createSelectedButtonView];
        CGRect mainFrame = [UIScreen mainScreen].bounds;
        channButtonView.frame = CGRectMake(channHorizontalMargin, channButtonPosY, mainFrame.size.width - 2*channHorizontalMargin, channButtonHeight);
        
        NSUInteger labelsViewHorizontalMargin = SWReadValue(120);
        NSUInteger labelsViewTopMargin = SHReadValue(2);
        NSUInteger labelsViewHeight = SHReadValue(35);
        NSUInteger labelsViewPosY = channButtonView.frame.origin.y + channButtonView.frame.size.height + labelsViewTopMargin;
        
        UIView* labelsView = [self createLabelsView];
        labelsView.frame = CGRectMake(labelsViewHorizontalMargin, labelsViewPosY, mainFrame.size.width - 2*labelsViewHorizontalMargin, labelsViewHeight);
        
        [self addSubview:self.valueLabel500];
        [self addSubview:self.valueLabel1K];
        [self addSubview:self.valueLabel2K];
        [self addSubview:self.valueLabel3K];
        [self addSubview:self.valueLabel4K];
        
        [self addSubview:self.slider500];
        [self addSubview:self.slider1K];
        [self addSubview:self.slider2K];
        [self addSubview:self.slider3K];
        [self addSubview:self.slider4K];
        
        [self addSubview:self.label500];
        [self addSubview:self.label1K];
        [self addSubview:self.label2K];
        [self addSubview:self.label3K];
        [self addSubview:self.label4K];
        
        [self addSubview:channButtonView];
        [self addSubview:labelsView];
        
        self.hidden = true;
    }
    return self;
}

- (UIView*) createSelectedButtonView
{
    UIStackView* stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionFillEqually;
    
    self.leftEarSelectedButton = [[SelectedButton alloc] initWithImage:[UIImage imageNamed:@"左"] unCheckedImage:[UIImage imageNamed:@"左耳灰"]];
    self.rightEarSelectedButton = [[SelectedButton alloc] initWithImage:[UIImage imageNamed:@"右"] unCheckedImage:[UIImage imageNamed:@"右耳灰"]];
    
    [stackView addArrangedSubview:self.leftEarSelectedButton];
    [stackView addArrangedSubview:self.rightEarSelectedButton];
    
    self.buttonGroup = @[self.leftEarSelectedButton, self.rightEarSelectedButton];
    
    for (SelectedButton* button in self.buttonGroup) {
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchDown];
    }
    
    self.leftEarSelectedButton.checked = NO;
    self.rightEarSelectedButton.checked = NO;
    
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

- (void) buttonClicked:(SelectedButton*)sender
{
    if (sender.checked) {
        return;
    }
    
    if (!self.leftEarSelectedButton.checked) {
        self.leftEarSelectedButton.checked = YES;
        self.rightEarSelectedButton.checked = NO;
    } else {
        self.leftEarSelectedButton.checked = NO;
        self.rightEarSelectedButton.checked = YES;
    }
    
//    self.leftEarSelectedButton.checked = !self.leftEarSelectedButton.checked;
//    self.rightEarSelectedButton.checked = !self.rightEarSelectedButton.checked;
}


- (NSUInteger) getPosX:(NSUInteger)index horizontalMargin:(NSUInteger)horizontalMargin widthValue:(NSUInteger)widthValue
{
    CGRect mainFrame = [UIScreen mainScreen].bounds;
    
    NSUInteger width = mainFrame.size.width - horizontalMargin*2 - widthValue;
    NSUInteger unitWidth = width / 4;
    
    return unitWidth*index + horizontalMargin;
}

- (VolumeSlider*) createSlider:(NSUInteger)index posY:(NSUInteger)posY
{
//    NSUInteger sliderHorizontalMargin = 20;
    NSUInteger sliderWidth = SWReadValue(50);
    
    NSUInteger posX = [self getPosX:index horizontalMargin:self.horizontalMargin widthValue:sliderWidth];
    VolumeSlider* slider = [[VolumeSlider alloc] initWithPosStyle:CGRectMake(posX, posY, sliderWidth, self.sliderHeight) posStyle:SliderPosVertical];
    
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [slider addTarget:self action:@selector(sliderReleased:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
    slider.minimumValue = 0;
    slider.maximumValue = 100;
    
    return slider;
}

- (void)sliderValueChanged:(VolumeSlider*)sender
{
    NSUInteger roundedValue = round(sender.value / sender.step) * sender.step;
    sender.value = roundedValue;
    
    NSUInteger index = [self.sliderGroup indexOfObject:sender];
    [self setFreqResponseValue:index value:roundedValue];
}

- (void) sliderReleased:(VolumeSlider*) sender
{
    unsigned char value[5];
    
    for (int i=0; i<5; i++) {
        VolumeSlider* slider = [self.sliderGroup objectAtIndex:i];
        value[i] = (int)slider.value;
    }
    
    [PacketProto getInstance].leftFreqs = [[NSData alloc] initWithBytes:value length:sizeof(value)];
    
    NSData* freqsSet = [[PacketProto getInstance] packFreqSet];
    
    [[BleProfile getInstance] writeDeviceData:freqsSet callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
        NSLog(@"写入频响控制指令成功");
    }];
}

- (void)setLeftFreqResponseValue:(NSData*) data
{
    for (int i=0; i<5; i++) {
        unsigned char* bytes = (unsigned char*)data.bytes;
        [self setFreqResponseValue:i value:bytes[i]];
    }
}

- (void) setFreqResponseValue:(NSUInteger)index value:(NSUInteger)value
{
    VolumeSlider* slider = [self.sliderGroup objectAtIndex:index];
    UILabel* valueLabel = [self.valueLabelGroup objectAtIndex:index];
    
    slider.value = value;
    valueLabel.text = [NSString stringWithFormat:@"%ld%%", value];
}

- (void) updateAllFreqResponseValues
{
    for (int i=0; i<5; i++) {
        [self setFreqResponseValue:i value:freqResponseValues[i]];
    }
}

- (UILabel*) createValueLabel:(NSUInteger)index posY:(NSUInteger)posY
{
    NSUInteger valueLabelWidth = SWReadValue(45);
    
    NSUInteger posX = [self getPosX:index horizontalMargin:self.horizontalMargin widthValue:valueLabelWidth];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(posX, posY, valueLabelWidth, self.labelHeight)];
    
    label.text = @"100%";
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
}

- (UILabel*) createFreqLabel:(NSUInteger)index posY:(NSUInteger)posY title:(NSString*)title
{
    NSUInteger labelWidth = SWReadValue(50);
    
    NSUInteger posX = [self getPosX:index horizontalMargin:self.horizontalMargin widthValue:labelWidth];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(posX, posY, labelWidth, self.labelHeight)];
    
    label.text = title;
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
}


@end
