//
//  ProtectEarSlider.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/11.
//

#import "ProtectEarSlider.h"

@interface ProtectEarSlider ()

@property (nonatomic) NSUInteger step;

@end

@implementation ProtectEarSlider

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
        UIImage* thumbImage = [UIImage imageNamed:@"护耳滑块"];
        [self setThumbImage:thumbImage forState:UIControlStateNormal];
        
        [self setMinimumTrackImage:[UIImage imageNamed:@"滑条蓝"] forState:UIControlStateNormal];
        [self setMaximumTrackImage:[UIImage imageNamed:@"滑条"] forState:UIControlStateNormal];
        
        self.step = 1;
        self.minimumValue = 0;
        self.maximumValue = 4;
        
        [self addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

// 改变偏移滑块的位置
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    rect.origin.x = rect.origin.x - 5 ;
    rect.size.width = rect.size.width +10;
    return CGRectInset ([super thumbRectForBounds:bounds trackRect:rect value:value], 5 , 5);
}

- (void)sliderValueChanged:(UISlider*)sender
{
    NSUInteger roundedValue = round(sender.value / self.step) * self.step;
    sender.value = roundedValue;
}

@end
