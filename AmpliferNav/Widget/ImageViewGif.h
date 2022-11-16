//
//  ImageViewGif.h
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/16.
//

#import <UIKit/UIKit.h>
#import "GifViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImageViewGif : UIImageView
{
@private
    NSTimer* _timer;
}

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic) id<GifViewDelegate> delegate;
- (instancetype)initWithDuration:(NSTimeInterval)duration delegate:(id<GifViewDelegate>)delegate;
- (void) startGif;
- (void) stopGif;
@end

NS_ASSUME_NONNULL_END
