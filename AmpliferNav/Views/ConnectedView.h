//
//  ConnectedView.h
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/16.
//

#import <UIKit/UIKit.h>

#define TWS_DEVICE_TYPE_D   0x01
#define TWS_DEVICE_TYPE_G   0x02

NS_ASSUME_NONNULL_BEGIN

@interface ConnectedView : UIViewController

@property (nonatomic) NSString* deviceName;
@property (nonatomic, assign) NSUInteger deviceType;

@end

NS_ASSUME_NONNULL_END
