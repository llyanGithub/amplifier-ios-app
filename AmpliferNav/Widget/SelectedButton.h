//
//  SelectedButton.h
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SelectedButton : UIButton

@property (nonatomic) BOOL checked;

- (instancetype)initWithImage:(UIImage*)checkedImage unCheckedImage:(UIImage*)unCheckedImage;

@end

NS_ASSUME_NONNULL_END
