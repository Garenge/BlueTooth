//
//  DataManager.m
//  demo_blueTooth
//
//  Created by LZP on 2017/7/24.
//  Copyright © 2017年 LZP. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

+ (void)getPrefrenceComplete:(void (^)(NSDictionary *, NSError *))completeHandle {
    NSError *jsonToDicError = nil;
    NSDictionary *fileContent = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CheckList" ofType:@"json"]] options:NSJSONReadingMutableContainers error:&jsonToDicError];
    
    completeHandle(fileContent, jsonToDicError);
}

@end
