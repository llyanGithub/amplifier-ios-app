//
//  NavButton.h
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ZJButtonImageStyle){
    ZJButtonImageStyleTop = 0,  //图片在上，文字在下
    ZJButtonImageStyleLeft,     //图片在左，文字在右
    ZJButtonImageStyleBottom,   //图片在下，文字在上
    ZJButtonImageStyleRight     //图片在右，文字在左
};

@interface NavButton : UIButton

@property (nonatomic) NSString* titleName;
@property (nonatomic, assign) BOOL checked;
@property (nonatomic) UIImage* checkedImage;
@property (nonatomic) UIImage* unCheckedImage;


/**
设置button的imageView和titleLabel的布局样式及它们的间距
@param style imageView和titleLabel的布局样式
@param space imageView和titleLabel的间距
*/
- (void)layoutButtonWithImageStyle:(ZJButtonImageStyle)style
                   imageTitleToSpace:(CGFloat)space;
- (instancetype)initWithCheckedImage:(CGRect)frame checkedImage:(UIImage*)checkedImage unCheckedImage:(UIImage*)unCheckedImage;
- (void)setCheckImage:(UIImage*)checkedImage unCheckedImage:(UIImage*)unCheckedImage;
- (void)setCornerRadius:(CGFloat)radius;

@end

NS_ASSUME_NONNULL_END
