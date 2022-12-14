//
//  NavButton.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/8.
//

#import "NavButton.h"

@implementation NavButton

- (void)setChecked:(BOOL)checked
{
    if (checked) {
        [self setImage:self.checkedImage forState:UIControlStateNormal];
        [self setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    
        [self setShadow:YES];
//        [self setUnderLine:YES];
    } else {
        [self setImage:self.unCheckedImage forState:UIControlStateNormal];
        [self setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        
        [self setShadow:NO];
//        [self setUnderLine: NO];
    }
    _checked = checked;
}

- (void) setShadow:(BOOL) yes
{
    if (yes) {
        self.backgroundColor = UIColor.whiteColor;
        self.layer.cornerRadius = 5;
        self.layer.shadowOffset =  CGSizeMake(0, 5);
        self.layer.shadowOpacity = 0.2;
        self.layer.shadowColor =  [UIColor blackColor].CGColor;
    } else {
        self.backgroundColor = nil;
        self.layer.cornerRadius = 0;
        self.layer.shadowOffset =  CGSizeMake(0, -3);
        self.layer.shadowOpacity = 0.0;
        self.layer.shadowColor =  [UIColor blackColor].CGColor;
    }
}

- (void) setUnderLine:(BOOL) yes
{
    if (!self.titleName) {
        return;
    }
    
    NSDictionary *attribtDic;
    if (yes) {
        attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleThick]};
    } else {
        attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleNone]};
    }
        
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:self.titleName attributes:attribtDic];
    [self setAttributedTitle:attribtStr forState:UIControlStateNormal];
    
}

- (instancetype)initWithCheckedImage:(CGRect)frame checkedImage:(UIImage*)checkedImage unCheckedImage:(UIImage*)unCheckedImage
{
    self = [super initWithFrame:frame];
    if (self) {
        self.checkedImage = checkedImage;
        self.unCheckedImage = unCheckedImage;
        self.checked = false;
    }
    return self;
}

- (void)setTitleName:(NSString *)titleName
{
    _titleName = titleName;
    [self setUnderLine:NO];
}

- (void)setCheckImage:(UIImage*)checkedImage unCheckedImage:(UIImage*)unCheckedImage
{
    self.checkedImage = checkedImage;
    self.unCheckedImage = unCheckedImage;
}

- (void)setCornerRadius:(CGFloat)radius
{
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:radius];
}

- (void)buttonClicked
{
    if (self.checked) {
        self.checked = false;
    } else {
        self.checked = true;
    }
}

- (void)layoutButtonWithImageStyle:(ZJButtonImageStyle)style imageTitleToSpace:(CGFloat)space

{
    //1、获取imageView和titleLabel的高和宽
    CGFloat imageWidth = self.imageView.frame.size.width;
    CGFloat imageHeight = self.imageView.frame.size.height;
    CGFloat titleWidth = self.titleLabel.frame.size.width;
    CGFloat titleHeight = self.titleLabel.frame.size.height;
    
    //2、初始化一个内偏移
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets titleEdgeInsets = UIEdgeInsetsZero;

    //3、不同的样式处理不同的内偏移
    switch (style) {
        case ZJButtonImageStyleTop:
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, titleHeight + space / 2, -titleWidth);
            titleEdgeInsets = UIEdgeInsetsMake(imageHeight + space / 2, -imageWidth, 0, 0);
            break;

        case ZJButtonImageStyleLeft:
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, space / 2);
            titleEdgeInsets = UIEdgeInsetsMake(0, space / 2, 0, 0);
            break;

        case ZJButtonImageStyleBottom:
            imageEdgeInsets = UIEdgeInsetsMake(titleHeight + space / 2, 0, 0, -titleWidth);
            titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, imageHeight + space / 2, 0);
            break;

        case ZJButtonImageStyleRight:
            imageEdgeInsets = UIEdgeInsetsMake(0, titleWidth + space / 2, 0, -titleWidth);
            titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth - space / 2, 0, imageWidth);
            break;

        default:
            break;
    }

    //4、赋值
    self.imageEdgeInsets = imageEdgeInsets;
    self.titleEdgeInsets = titleEdgeInsets;
}

@end
