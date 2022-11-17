//
//  FreqResponseView.h
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/10.
//

#import <UIKit/UIKit.h>
#import "SelectedButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface FreqResponseView : UIView

//@property (nonatomic) NSUInteger freqValue500;
//@property (nonatomic) NSUInteger freqValue1K;
//@property (nonatomic) NSUInteger freqValue2K;
//@property (nonatomic) NSUInteger freqValue3K;
//@property (nonatomic) NSUInteger freqValue4K;

@property (nonatomic) NSData* leftFreqResponseValue;
@property (nonatomic) NSData* rightFreqResponseValue;

@property (nonatomic) SelectedButton* leftEarSelectedButton;
@property (nonatomic) SelectedButton* rightEarSelectedButton;

- (void)showLeftFreqResponseValue;
- (void)showRightFreqResponseValue;

@end

NS_ASSUME_NONNULL_END
