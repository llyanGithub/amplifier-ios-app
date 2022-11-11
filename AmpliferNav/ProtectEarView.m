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

@end

@implementation ProtectEarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.leftSlider = [[ProtectEarSlider alloc] initWithFrame:CGRectMake(20, 20, 200, 40)];
        self.rightSlider = [[ProtectEarSlider alloc] initWithFrame:CGRectMake(20, 80, 200, 40)];
        
        [self addSubview:self.leftSlider];
        [self addSubview:self.rightSlider];
        
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
