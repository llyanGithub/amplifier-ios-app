//
//  ProtectEarView.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/11.
//

#import "ProtectEarView.h"
#import "ProtectEarSlider.h"
#import "SelectedButton.h"
#import "PacketProto.h"
#import "BleProfile.h"
#import "ScreenAdapter.h"


@interface ProtectEarView ()

@property (nonatomic) ProtectEarSlider* leftSlider;
@property (nonatomic) ProtectEarSlider* rightSlider;

@property (nonatomic) NSUInteger leftEarCompressValue;
@property (nonatomic) NSUInteger rightEarCompressValue;

@property (nonatomic) NSUInteger topMargin;
@property (nonatomic) NSUInteger horizontalMargin;

@property (nonatomic) UILabel* leftChannLabel;
@property (nonatomic) UILabel* rightChannLabel;

@property (nonatomic) UILabel* descriptionLabel;

@property (nonatomic) UILabel* leftCompressLabel;
@property (nonatomic) UILabel* rightCompressLabel;

@property (nonatomic) UITapGestureRecognizer* leftSliderTapGesture;
@property (nonatomic) UITapGestureRecognizer* rightSliderTapGesture;

@property (nonatomic) SelectedButton* allSelectedButton;

@end

@implementation ProtectEarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSUInteger labelWidth = SWReadValue(40);
        NSUInteger labelHeight = SHReadValue(40);
        self.topMargin = SHReadValue(80);
        self.horizontalMargin = SWReadValue(40);
        
        CGRect mainFrame = [UIScreen mainScreen].bounds;
        
//        if ([localeLanguageCode isEqualToString:@"ko-CN"]) {
//            self.rightBatLabel.numberOfLines = 3;
//        }
        
        NSString *localeLanguageCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"][0];
        
        NSLog(@"language: %@", localeLanguageCode);
        
        UIFont* font = [UIFont systemFontOfSize:14];
        
        if ([localeLanguageCode isEqualToString:@"en-CN"]) {
            self.leftChannLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.horizontalMargin/2, self.topMargin, labelWidth*2, labelHeight)];
        } else {
            self.leftChannLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.horizontalMargin, self.topMargin, labelWidth, labelHeight)];
        }

        self.leftChannLabel.text = NSLocalizedString(@"leftEar", nil);
        self.leftChannLabel.font = font;
        
        NSUInteger sliderLeftMargin = SWReadValue(10);
        NSUInteger sliderHeight = SHReadValue(40);
        NSUInteger slidePosX = self.horizontalMargin+labelWidth+sliderLeftMargin;
        NSUInteger sliderWidth = mainFrame.size.width - 2*self.horizontalMargin - labelWidth - sliderLeftMargin;
        
        self.leftSlider = [[ProtectEarSlider alloc] initWithFrame:CGRectMake(slidePosX, self.topMargin, sliderWidth, sliderHeight)];
        UIImageView* leftSliderPointView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"级点"]];
        
        NSUInteger pointHorizontalMargin = SWReadValue(15);
        leftSliderPointView.contentMode = UIViewContentModeScaleAspectFit;
        leftSliderPointView.frame = CGRectMake(slidePosX + pointHorizontalMargin, self.topMargin, sliderWidth - 2*pointHorizontalMargin, sliderHeight);
        
        [self.leftSlider addTarget:self action:@selector(leftSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.leftSlider addTarget:self action:@selector(sliderReleased) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        
        self.leftSliderTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftSliderTapped:)];
        self.leftSliderTapGesture.delegate = self;
        [self.leftSlider addGestureRecognizer:self.leftSliderTapGesture];
        
        UIView* leftEarScaleView = [self createScaleView];
        NSUInteger scalePosX = slidePosX + SWReadValue(9);
        NSUInteger scaleWidth = sliderWidth - SWReadValue(20);
        NSUInteger scaleTopMargin = SHReadValue(5);
        NSUInteger scaleViewHeight = SHReadValue(20);
        NSUInteger leftScalePosY = self.topMargin + sliderHeight + scaleTopMargin;
        leftEarScaleView.frame = CGRectMake(scalePosX, leftScalePosY, scaleWidth, scaleViewHeight);
        
        if ([localeLanguageCode isEqualToString:@"en-CN"]) {
            self.leftCompressLabel = [[UILabel alloc] initWithFrame:CGRectMake(mainFrame.size.width - self.horizontalMargin - SWReadValue(40)*3, leftScalePosY + scaleViewHeight + SHReadValue(5), SWReadValue(150), SHReadValue(20))];
        } else {
            self.leftCompressLabel = [[UILabel alloc] initWithFrame:CGRectMake(mainFrame.size.width - self.horizontalMargin - SWReadValue(40), leftScalePosY + scaleViewHeight + SHReadValue(5), SWReadValue(100), SHReadValue(20))];
        }
        self.leftCompressLabel.text = NSLocalizedString(@"compressDegree", nil);
        self.leftCompressLabel.font = [UIFont systemFontOfSize:11];
        
        
        NSUInteger rightSliderPosY = leftScalePosY + scaleViewHeight + SHReadValue(80);
        
        self.rightSlider = [[ProtectEarSlider alloc] initWithFrame:CGRectMake(slidePosX, rightSliderPosY, sliderWidth, sliderHeight)];
        
//        NSUInteger pointHorizontalMargin = SWReadValue(15);
        UIImageView* rightSliderPointView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"级点"]];
        rightSliderPointView.contentMode = UIViewContentModeScaleAspectFit;
        rightSliderPointView.frame = CGRectMake(slidePosX + pointHorizontalMargin, rightSliderPosY, sliderWidth - 2*pointHorizontalMargin, sliderHeight);
        
        [self.rightSlider addTarget:self action:@selector(rightSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self.rightSlider addTarget:self action:@selector(sliderReleased) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        
        self.rightSliderTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightSliderTapped:)];
        self.rightSliderTapGesture.delegate = self;
        [self.rightSlider addGestureRecognizer:self.rightSliderTapGesture];
        
        if ([localeLanguageCode isEqualToString:@"en-CN"]) {
            self.rightChannLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.horizontalMargin/2, rightSliderPosY, labelWidth*2, labelHeight)];
        } else {
            self.rightChannLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.horizontalMargin, rightSliderPosY, labelWidth, labelHeight)];
        }

        self.rightChannLabel.text = NSLocalizedString(@"rightEar", nil);
        self.rightChannLabel.font = font;
        
        UIView* rightEarScaleView = [self createScaleView];
        NSUInteger rightScalePosY = rightSliderPosY + sliderHeight + scaleTopMargin;
        rightEarScaleView.frame = CGRectMake(scalePosX, rightScalePosY, scaleWidth, scaleViewHeight);
        
        if ([localeLanguageCode isEqualToString:@"en-CN"]) {
            self.rightCompressLabel = [[UILabel alloc] initWithFrame:CGRectMake(mainFrame.size.width - self.horizontalMargin - SWReadValue(40)*3, rightScalePosY + scaleViewHeight + SHReadValue(5), SWReadValue(150), SHReadValue(20))];
        } else {
            self.rightCompressLabel = [[UILabel alloc] initWithFrame:CGRectMake(mainFrame.size.width - self.horizontalMargin - SWReadValue(40), rightScalePosY + scaleViewHeight + SHReadValue(5), SWReadValue(100), SHReadValue(20))];
        }

        self.rightCompressLabel.text = NSLocalizedString(@"compressDegree", nil);
        self.rightCompressLabel.font = [UIFont systemFontOfSize:11];
        
        
        NSUInteger descriptionLabelTopMargin = SHReadValue(40);
        NSUInteger descriptionLabelPosY = self.rightCompressLabel.frame.origin.y + self.rightCompressLabel.frame.size.height + descriptionLabelTopMargin;
        
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.horizontalMargin/2, descriptionLabelPosY, mainFrame.size.width - self.horizontalMargin, SHReadValue(40))];
        self.descriptionLabel.text = NSLocalizedString(@"earProtectionComment", nil);
        self.descriptionLabel.numberOfLines = 2;
        self.descriptionLabel.font = [UIFont systemFontOfSize:14];
        
        UILabel* descriptionLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(self.horizontalMargin - SWReadValue(10), descriptionLabelPosY + SHReadValue(20), mainFrame.size.width - self.horizontalMargin*2, SWReadValue(40))];
        descriptionLabel2.text = NSLocalizedString(@"earProtectionComment2", nil);
        descriptionLabel2.numberOfLines = 2;
        [descriptionLabel2 setFont:[UIFont systemFontOfSize:14]];
        
        self.allSelectedButton = [[SelectedButton alloc] initWithImage:[UIImage imageNamed:@"护耳链接选中"] unCheckedImage:[UIImage imageNamed:@"护耳链接"]];
        self.allSelectedButton.frame = CGRectMake(self.horizontalMargin, self.topMargin+SHReadValue(60), SWReadValue(30), SHReadValue(54));
        
        [self.allSelectedButton addTarget:self action:@selector(selectedButtonClicked) forControlEvents:UIControlEventTouchDown];
        self.allSelectedButton.checked = NO;
        
        [self addSubview:self.leftSlider];
        [self addSubview:self.rightSlider];
        [self addSubview:self.leftChannLabel];
        [self addSubview:self.rightChannLabel];
        [self addSubview:self.descriptionLabel];
//        [self addSubview:descriptionLabel2];
        
        [self addSubview:leftEarScaleView];
        [self addSubview:rightEarScaleView];
        
        [self addSubview:self.leftCompressLabel];
        [self addSubview:self.rightCompressLabel];
        
        [self addSubview:self.allSelectedButton];
        
        [self addSubview:leftSliderPointView];
        [self addSubview:rightSliderPointView];
        
        self.leftEarCompressValue = 0;
        self.rightEarCompressValue = 0;
        
        self.hidden = true;
    }
    return self;
}

- (void) selectedButtonClicked
{
    self.allSelectedButton.checked = !self.allSelectedButton.checked;
//    self.leftSlider.enabled = self.allSelectedButton.checked;
//    self.rightSlider.enabled = self.allSelectedButton.checked;
}

- (void) leftSliderValueChanged:(ProtectEarSlider*)sender
{
    NSUInteger roundedValue = round(sender.value / sender.step) * sender.step;
    sender.value = roundedValue;
    
    _leftEarCompressValue = roundedValue;
    if (self.allSelectedButton.checked) {
        self.rightSlider.value = roundedValue;
        _rightEarCompressValue = roundedValue;
    }
}

- (void)leftSliderTapped:(UITapGestureRecognizer *)sender
{
    CGPoint touchPoint = [sender locationInView:self.leftSlider];
    CGFloat value = (self.leftSlider.maximumValue - self.leftSlider.minimumValue) * (touchPoint.x / self.leftSlider.frame.size.width );
    NSUInteger roundedValue = round(value / self.leftSlider.step) * self.leftSlider.step;
    
    [self.leftSlider setValue:roundedValue animated:YES];
    _leftEarCompressValue = roundedValue;
    
    if (self.allSelectedButton.checked) {
        
        [self.rightSlider setValue:roundedValue animated:YES];
        _rightEarCompressValue = roundedValue;
    }
    [self sliderReleased];
}

- (void)rightSliderTapped:(UITapGestureRecognizer *)sender
{
    CGPoint touchPoint = [sender locationInView:self.leftSlider];
    CGFloat value = (self.rightSlider.maximumValue - self.rightSlider.minimumValue) * (touchPoint.x / self.rightSlider.frame.size.width );
    NSUInteger roundedValue = round(value / self.rightSlider.step) * self.rightSlider.step;

    [self.rightSlider setValue:roundedValue animated:YES];
    _rightEarCompressValue = roundedValue;
    
    if (self.allSelectedButton.checked) {
        [self.leftSlider setValue:roundedValue animated:YES];
        _leftEarCompressValue = roundedValue;
    }
    
    [self sliderReleased];
}

- (void) sliderReleased
{
    PacketProto* packetProto = [PacketProto getInstance];
    packetProto.leftEarProtection = _leftEarCompressValue;
    packetProto.rightEarProtection = _rightEarCompressValue;
    
    NSLog(@"leftEarProtection: %ld rightEarProtection: %ld", _leftEarCompressValue, _rightEarCompressValue);
    
    NSData* data = [packetProto packEarProtectModeSet];
    [[BleProfile getInstance] writeDeviceData:data callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
        NSLog(@"写入护耳控制指令成功");
    }];
}

- (void) setEarCompressValue:(NSUInteger)leftEarCompressValue rightEarCompressValue:(NSUInteger)rightEarCompressValue
{
    _leftEarCompressValue = leftEarCompressValue;
    _rightEarCompressValue = rightEarCompressValue;
    
    self.leftSlider.value = _leftEarCompressValue;
    self.rightSlider.value = _rightEarCompressValue;
}

- (void) rightSliderValueChanged:(ProtectEarSlider*)sender
{
    NSUInteger roundedValue = round(sender.value / sender.step) * sender.step;
    sender.value = roundedValue;
    
    _rightEarCompressValue = roundedValue;
    
    if (self.allSelectedButton.checked) {
        self.leftSlider.value = roundedValue;
        _leftEarCompressValue = roundedValue;
    }
}

- (void) setLeftEarCompressValue:(NSUInteger)leftEarCompressValue
{
    _leftEarCompressValue = leftEarCompressValue;
    self.leftSlider.value = _leftEarCompressValue;
}

- (void) setRightEarCompressValue:(NSUInteger)rightEarCompressValue
{
    _rightEarCompressValue = rightEarCompressValue;
    self.rightSlider.value = _rightEarCompressValue;
}

- (UIView*) createScaleView
{
    UILabel* label0 = [[UILabel alloc] init];
    UILabel* label1 = [[UILabel alloc] init];
    UILabel* label2 = [[UILabel alloc] init];
    UILabel* label3 = [[UILabel alloc] init];
    
    label0.text = @"0";
    label1.text = @"1";
    label2.text = @"2";
    label3.text = @"3";
    
    UIStackView* stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionEqualCentering;
    
    [stackView addArrangedSubview:label0];
    [stackView addArrangedSubview:label1];
    [stackView addArrangedSubview:label2];
    [stackView addArrangedSubview:label3];
    
    return (UIView*)stackView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
