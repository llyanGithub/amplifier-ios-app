//
//  ModeButton.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/10.
//

#import "ModeButton.h"

@implementation ModeButton

- (void)setChecked:(BOOL)checked
{
    UIColor* titleChckedColor = [UIColor colorWithRed:0.0 green:103/255.0 blue:182/255.0 alpha:1];

    if (checked) {
        [self setImage:self.checkedImage forState:UIControlStateNormal];
        [self setTitleColor:titleChckedColor forState:UIControlStateNormal];
        
        [self setShadow:YES];
    } else {
        [self setImage:self.unCheckedImage forState:UIControlStateNormal];
        [self setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
        
        [self setShadow:NO];
    }
    _checked = checked;
}

- (void) setShadow:(BOOL) yes
{
    if (yes) {
        self.backgroundColor = UIColor.whiteColor;
        self.layer.cornerRadius = 10.0;
        self.layer.shadowOffset =  CGSizeMake(0, 5);
        self.layer.shadowOpacity = 0.2;
        self.layer.shadowColor =  [UIColor blackColor].CGColor;
    } else {
        self.backgroundColor = [UIColor colorWithRed:232/255.0 green:233/255.0 blue:234/255.0 alpha:1];;
        self.layer.cornerRadius = 10.0;
        self.layer.shadowOffset =  CGSizeMake(0, -3);
        self.layer.shadowOpacity = 0.0;
        self.layer.shadowColor =  [UIColor blackColor].CGColor;
    }
}

- (instancetype)initWithCheckedImage:(CGRect)frame checkedImage:(UIImage*)checkedImage unCheckedImage:(UIImage*)unCheckedImage
{
    self = [super initWithFrame:frame];
    if (self) {
        self.checkedImage = checkedImage;
        self.unCheckedImage = unCheckedImage;
        self.checked = false;
//        [self addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchDown];
    }
    return self;
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

- (void)layoutButtonWithImageStyle:(ButtonImageStyle)style imageTitleToSpace:(CGFloat)space

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
        case ButtonImageStyleTop:
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, titleHeight + space / 2, -titleWidth);
            titleEdgeInsets = UIEdgeInsetsMake(imageHeight + space / 2, -imageWidth, 0, 0);
            break;

        case ButtonImageStyleLeft:
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, space / 2);
            titleEdgeInsets = UIEdgeInsetsMake(0, space / 2, 0, 0);
            break;

        case ButtonImageStyleBottom:
            imageEdgeInsets = UIEdgeInsetsMake(titleHeight + space / 2, 0, 0, -titleWidth);
            titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, imageHeight + space / 2, 0);
            break;

        case ButtonImageStyleRight:
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
