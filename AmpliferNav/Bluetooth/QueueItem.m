//
//  QueueItem.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/15.
//

#import "QueueItem.h"
#import <Foundation/Foundation.h>

@implementation QueueItem


- (instancetype)initWithDataBlock:(NSData*)data block:(WriteDoneCallback)block
{
    self = [super init];
    if (self) {
        self.data = data;
        self.block = block;
    }
    return self;
}

@end
