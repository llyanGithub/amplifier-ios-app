//
//  ProtectEarView.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/11.
//

#import "ProtectEarView.h"
#import "ProtectEarSlider.h"

@interface ProtectEarView ()

@property (nonatomic) ProtectEarSlider* leftSlider;
@property (nonatomic) ProtectEarSlider* rightSlider;

@property (nonatomic) NSUInteger topMargin;
@property (nonatomic) NSUInteger horizontalMargin;

@property (nonatomic) UILabel* leftChannLabel;
@property (nonatomic) UILabel* rightChannLabel;

@property (nonatomic) UILabel* descriptionLabel;

@property (nonatomic) UILabel* leftCompressLabel;
@property (nonatomic) UILabel* rightCompressLabel;

@property (nonatomic) UIButton* allSelectedButton;

@end

@implementation ProtectEarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSUInteger labelWidth = 40;
        NSUInteger labelHeight = 40;
        self.topMargin = 40;
        self.horizontalMargin = 20;
        
        CGRect mainFrame = [UIScreen mainScreen].bounds;
        
        UIFont* font = [UIFont systemFontOfSize:14];
        self.leftChannLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.horizontalMargin, self.topMargin, labelWidth, labelHeight)];
        self.leftChannLabel.text = @"左耳";
        self.leftChannLabel.font = font;
        
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.horizontalMargin, self.topMargin+250, mainFrame.size.width - self.horizontalMargin*2, labelHeight*2)];
        self.descriptionLabel.text = @"护耳模式能够压缩响度过大声音的增益。\n例如：汽车鸣笛声、爆竹声等，防止给您带来不适。";
        self.descriptionLabel.numberOfLines = 3;
        self.descriptionLabel.font = [UIFont systemFontOfSize:12];
        
        NSUInteger sliderLeftMargin = 10;
        NSUInteger sliderHeight = 40;
        NSUInteger slidePosX = self.horizontalMargin+labelWidth+sliderLeftMargin;
        NSUInteger sliderWidth = mainFrame.size.width - 2*self.horizontalMargin - labelWidth - sliderLeftMargin;
        
        self.leftSlider = [[ProtectEarSlider alloc] initWithFrame:CGRectMake(slidePosX, self.topMargin, sliderWidth, sliderHeight)];
        
        UIView* leftEarScaleView = [self createScaleView];
        NSUInteger scalePosX = slidePosX + 9;
        NSUInteger scaleWidth = sliderWidth - 20;
        NSUInteger scaleTopMargin = 5;
        NSUInteger scaleViewHeight = 20;
        NSUInteger leftScalePosY = self.topMargin + sliderHeight + scaleTopMargin;
        leftEarScaleView.frame = CGRectMake(scalePosX, leftScalePosY, scaleWidth, scaleViewHeight);
        
        self.leftCompressLabel = [[UILabel alloc] initWithFrame:CGRectMake(mainFrame.size.width - self.horizontalMargin - 40, leftScalePosY + scaleViewHeight + 5, 100, 20)];
        self.leftCompressLabel.text = @"压缩程度";
        self.leftCompressLabel.font = [UIFont systemFontOfSize:11];
        
        
        NSUInteger rightSliderPosY = leftScalePosY + scaleViewHeight + 80;
        
        self.rightSlider = [[ProtectEarSlider alloc] initWithFrame:CGRectMake(slidePosX, rightSliderPosY, sliderWidth, sliderHeight)];
        
        self.rightChannLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.horizontalMargin, rightSliderPosY, labelWidth, labelHeight)];
        self.rightChannLabel.text = @"右耳";
        self.rightChannLabel.font = font;
        
        UIView* rightEarScaleView = [self createScaleView];
        NSUInteger rightScalePosY = rightSliderPosY + sliderHeight + scaleTopMargin;
        rightEarScaleView.frame = CGRectMake(scalePosX, rightScalePosY, scaleWidth, scaleViewHeight);
        
        self.rightCompressLabel = [[UILabel alloc] initWithFrame:CGRectMake(mainFrame.size.width - self.horizontalMargin - 40, rightScalePosY + scaleViewHeight + 5, 100, 20)];
        self.rightCompressLabel.text = @"压缩程度";
        self.rightCompressLabel.font = [UIFont systemFontOfSize:11];
        
        self.allSelectedButton = [[UIButton alloc] initWithFrame:CGRectMake(self.horizontalMargin, self.topMargin+60, 30, 54)];
        [self.allSelectedButton setImage:[UIImage imageNamed:@"护耳链接选中"] forState:UIControlStateNormal];
        
        
        [self addSubview:self.leftSlider];
        [self addSubview:self.rightSlider];
        [self addSubview:self.leftChannLabel];
        [self addSubview:self.rightChannLabel];
        [self addSubview:self.descriptionLabel];
        
        [self addSubview:leftEarScaleView];
        [self addSubview:rightEarScaleView];
        
        [self addSubview:self.leftCompressLabel];
        [self addSubview:self.rightCompressLabel];
        
        [self addSubview:self.allSelectedButton];
        
        self.hidden = true;
    }
    return self;
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
