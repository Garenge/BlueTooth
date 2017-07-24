//
//  SetFilterStringVC.h
//  demo_blueTooth
//
//  Created by LZP on 2017/7/22.
//  Copyright © 2017年 LZP. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^setFilterStr)(NSString *newString);

@interface SetFilterStringVC : UIViewController

@property (nonatomic, strong) NSString *preFilteration;

@property (nonatomic, strong) setFilterStr setFilerBlock;

@end
