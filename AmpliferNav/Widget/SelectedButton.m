//
//  SelectedButton.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/12.
//

#import "SelectedButton.h"

@interface SelectedButton ()

@property (nonatomic) UIImage* checkedImage;
@property (nonatomic) UIImage* unCheckedImage;

@end

@implementation SelectedButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithImage:(UIImage*)checkedImage unCheckedImage:(UIImage*)unCheckedImage
{
    self = [super init];
    if (self) {
        self.checkedImage = checkedImage;
        self.unCheckedImage = unCheckedImage;
        self.checked = true;
    }
    return self;
}

- (void)setChecked:(BOOL)checked
{
    if (_checked == checked) {
        return;
    }
    
    _checked = checked;
    if (_checked) {
        [self setImage:self.checkedImage forState:UIControlStateNormal];
    } else {
        [self setImage:self.unCheckedImage forState:UIControlStateNormal];
    }
}

@end
