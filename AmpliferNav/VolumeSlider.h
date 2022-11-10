//
//  VolumeSlider.h
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SliderPosStyle){
    SliderPosHorizontal = 0,  //水平方向的滑动
    SliderPosVertical,     //垂直方向滑动
};

@interface VolumeSlider : UISlider

@property (nonatomic, assign) SliderPosStyle posStyle;

- (instancetype)initWithPosStyle:(CGRect)frame posStyle:(SliderPosStyle)posStyle;

@end

NS_ASSUME_NONNULL_END
