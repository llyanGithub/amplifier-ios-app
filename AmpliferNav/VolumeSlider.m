//
//  VolumeSlider.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/10.
//

#import "VolumeSlider.h"

@implementation VolumeSlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithPosStyle:(CGRect)frame posStyle:(SliderPosStyle)posStyle
{
    frame = [VolumeSlider GetTransFrame:frame];
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        self.posStyle = posStyle;
        if (posStyle == SliderPosVertical) {
            // 将控件旋转90度
            CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI*1.5);
            self.transform = trans;
        }
        UIImage* thumbImage = [UIImage imageNamed:@"滑块"];
        [self setThumbImage:thumbImage forState:UIControlStateNormal];
        
//        [self.layer setMasksToBounds:YES];
//        [self.layer setCornerRadius:10.0];
//        [self.layer setBorderWidth:5];
//        [self.layer setBorderColor:[UIColor.grayColor CGColor]];
    }
    
    return self;
}

+ (CGRect) GetTransFrame:(CGRect)frame
{
    CGFloat x = frame.origin.x - ((frame.size.height-frame.size.width)/2);
    CGFloat y = frame.origin.y + ((frame.size.height-frame.size.width)/2);
    CGFloat width = frame.size.height;
    CGFloat height = frame.size.width;
    
    return CGRectMake(x, y, width, height);
}

@end
