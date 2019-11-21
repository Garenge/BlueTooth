//
//  AudioManager.m
//  monitor
//
//  Created by LZP on 16/7/9.
//  Copyright © 2016年 LZP. All rights reserved.
//

#import "AudioManager.h"

@interface AudioManager()

@property (nonatomic, strong) NSString *audioName;

@property (nonatomic, assign) NSInteger numberOfLoops;

@end

@implementation AudioManager
singleton_implementation(AudioManager)


- (NSString *)audioName {
    if(nil == _audioName) {
        _audioName = @"0005.wav";
    }
    return _audioName;
}

- (AVAudioPlayer *)audioPlayer {
    if(nil == _audioPlayer) {
        NSURL *audioFilePath = [[NSBundle mainBundle] URLForResource:self.audioName withExtension:nil];
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFilePath error:nil];
        _audioPlayer.numberOfLoops = self.numberOfLoops;
    }
    return _audioPlayer;
}

/** 播放警告音*/
- (void)playWarningSound {
    self.audioName = @"0005.wav";
    self.numberOfLoops = -1;
    if([self.audioPlayer prepareToPlay]) {
        //可以将音频文件的数据读到内存中(快)
        [self.audioPlayer play];
    }
}
/** 停止警告音*/
- (void)stopSound {
    if(self.audioPlayer.playing) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
}

- (void)playSound:(NSString *)name {
    [self playSound:name numberOfLoops:0];
}

- (void)playSound:(NSString *)name numberOfLoops:(NSInteger)numberOfLoops {
    
    self.audioName = name;
    self.numberOfLoops = numberOfLoops;
    [self stopSound];
    self.audioPlayer = nil;
    if([self.audioPlayer prepareToPlay]) {
        //可以将音频文件的数据读到内存中(快)
        [self.audioPlayer play];
    }
}


/** 启动警告*/
- (void)warningOn {
    [self playWarningSound];
}
/** 接触警告*/
- (void)warningOff {
    [self stopSound];
}

@end
