//
//  HomeViewController.h
//  Amplifer
//
//  Created by 鄢陵龙 on 2022/11/19.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController : UIViewController

@property (nonatomic) SWRevealViewController* revealViewController;

+ (HomeViewController*) getInstance;

@end

NS_ASSUME_NONNULL_END
