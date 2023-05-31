//
//  CBPeripheral+fullname.h
//  Amplifer
//
//  Created by 鄢陵龙 on 2023/5/31.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBPeripheral (fullname)
@property (atomic, copy) NSString* fullname;

@end

NS_ASSUME_NONNULL_END
