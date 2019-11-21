//
//  AudioManager.h
//  monitor
//
//  Created by LZP on 16/7/9.
//  Copyright © 2016年 LZP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface AudioManager : NSObject
singleton_interface(AudioManager)

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;


/** 播放警告音*/
- (void)playWarningSound;
/** 停止警告音*/
- (void)stopSound;

- (void)playSound:(NSString *)name;
- (void)playSound:(NSString *)name numberOfLoops:(NSInteger)numberOfLoops;

/** 启动警告*/
- (void)warningOn;
/** 接触警告*/
- (void)warningOff;
@end
