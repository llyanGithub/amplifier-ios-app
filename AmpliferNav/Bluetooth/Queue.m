//
//  Queue.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/15.
//

#import "Queue.h"

@interface Queue ()

@property (nonatomic) NSMutableArray* array;

@end

@implementation Queue

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.array = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) push:(QueueItem*)item
{
    [self.array addObject:item];
}

- (QueueItem*) pop
{
    QueueItem* item = [self.array firstObject];
    [self.array removeObjectAtIndex:0];
    
    return item;
}

- (BOOL)isEmpty
{
    return self.array.count == 0;
}

- (NSUInteger)count
{
    return self.array.count;
}

- (QueueItem*) peekItem
{
    return [self.array firstObject];
}

@end
