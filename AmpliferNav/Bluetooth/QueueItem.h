//
//  QueueItem.h
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/15.
//

#import <Foundation/Foundation.h>
#import "BleCentralManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface QueueItem : NSObject

@property (nonatomic) NSData* data;
@property (nonatomic) WriteDoneCallback block;

- (instancetype)initWithDataBlock:(NSData*)data block:(WriteDoneCallback)block;

@end

NS_ASSUME_NONNULL_END
