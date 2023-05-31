//
//  CBPeripheral+fullname.m
//  Amplifer
//
//  Created by 鄢陵龙 on 2023/5/31.
//

#import "CBPeripheral+fullname.h"
#import <objc/runtime.h>

#ifndef MY_KEY
#define MY_KEY @"_my_key"
#endif


//@interface CBPeripheral (fullname)
//
//@end

@implementation CBPeripheral (fullname)
- (NSString*) fullname
{
    return objc_getAssociatedObject(self, MY_KEY);
}

- (void) setFullname:(NSString *)name
{
    objc_setAssociatedObject(self, MY_KEY, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
@end
