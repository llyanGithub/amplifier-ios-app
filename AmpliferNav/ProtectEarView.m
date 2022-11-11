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

@end

@implementation ProtectEarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSUInteger labelWidth = 40;
        NSUInteger labelHeight = 40;
        self.topMargin = 20;
        self.horizontalMargin = 20;
        
        self.leftChannLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.horizontalMargin, self.topMargin, labelWidth, labelHeight)];
        self.leftChannLabel.text = @"左耳";
        
        self.rightChannLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.horizontalMargin, self.topMargin+80, labelWidth, labelHeight)];
        self.rightChannLabel.text = @"右耳";
        
        self.leftSlider = [[ProtectEarSlider alloc] initWithFrame:CGRectMake(self.horizontalMargin+labelWidth+10, self.topMargin, 200, 40)];
        self.rightSlider = [[ProtectEarSlider alloc] initWithFrame:CGRectMake(self.horizontalMargin+labelWidth+10, self.topMargin+80, 200, 40)];
        
        [self addSubview:self.leftSlider];
        [self addSubview:self.rightSlider];
        [self addSubview:self.leftChannLabel];
        [self addSubview:self.rightChannLabel];
        
        self.hidden = true;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
