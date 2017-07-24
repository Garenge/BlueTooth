//
//  diyModel.h
//  demo_blueTooth
//
//  Created by LZP on 2017/7/21.
//  Copyright © 2017年 LZP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface PeriModel : NSObject

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign) int aRSSI;
@property (nonatomic, assign) float avgRSSIf;
@property (nonatomic, assign) float distance;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral index:(NSInteger)index aRSSI:(int)aRSSI;
+ (instancetype)ModelWithPeripheral:(CBPeripheral *)peripheral index:(NSInteger)index aRSSI:(int)aRSSI;
@end
