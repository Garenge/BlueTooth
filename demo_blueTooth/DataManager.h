//
//  DataManager.h
//  demo_blueTooth
//
//  Created by LZP on 2017/7/24.
//  Copyright © 2017年 LZP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

+ (void)getPrefrenceComplete:(void(^)(NSDictionary *prefrenceDic, NSError *error))completeHandle;

@end
