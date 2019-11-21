//
//  diyModel.m
//  demo_blueTooth
//
//  Created by LZP on 2017/7/21.
//  Copyright © 2017年 LZP. All rights reserved.
//

#import "PeriModel.h"

#define RSSITODISTANCE(x) pow(10, (labs(x)-52)/(10*4.0))

@implementation PeriModel

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral index:(NSInteger)index aRSSI:(int)aRSSI {
    if(self = [super init]) {
        self.peripheral = peripheral;
        self.index = index;
        self.aRSSI = aRSSI;
        // self.distance // 算出来的
    }
    return self;
}

+ (instancetype)ModelWithPeripheral:(CBPeripheral *)peripheral index:(NSInteger)index aRSSI:(int)aRSSI {
    return [[self alloc] initWithPeripheral:peripheral index:index aRSSI:aRSSI];
}

- (void)setARSSI:(int)aRSSI {
    // 计算distance
    _aRSSI = aRSSI;

    _distance = RSSITODISTANCE(aRSSI);
}

@end
