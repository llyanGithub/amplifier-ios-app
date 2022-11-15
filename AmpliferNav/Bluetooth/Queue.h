//
//  Queue.h
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/15.
//

#import <Foundation/Foundation.h>
#import "BleCentralManager.h"
#import "QueueItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface Queue : NSObject

@property (readonly) NSUInteger count;

- (void) push:(QueueItem*)item;
- (QueueItem*) pop;
- (BOOL)isEmpty;
- (QueueItem*) peekItem;

@end

NS_ASSUME_NONNULL_END
