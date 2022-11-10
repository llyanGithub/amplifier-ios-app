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
        
        self.hidden = true;
    }
    return self;
}

@end
