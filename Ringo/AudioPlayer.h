//
//  AudioPlayer.h
//  Ringo
//
//  Created by Alexander Ivanov on 05.09.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AudioItem.h"

@interface AudioPlayer : NSObject

@property (assign, nonatomic) NSTimeInterval currentTime;

//- (void)play:(NSURL *)url startTime:(NSNumber *)startTime endTime:(NSNumber *)endTime handler:(void(^)(NSTimeInterval time))handler;
//- (void)stop;
//- (BOOL)isPlaying:(NSURL *)url;
//- (BOOL)isPlaying;

- (void)playItem:(AudioItem *)item segment:(AudioSegment *)segment numberOfLoops:(NSInteger)numberOfLoops handler:(void (^)(NSTimeInterval))handler;

- (BOOL)stopItem:(AudioItem *)item segment:(AudioSegment *)segment;
- (BOOL)stopItem:(AudioItem *)item;

- (BOOL)isPlayingItem:(AudioItem *)item segment:(AudioSegment *)segment;
- (BOOL)isPlayingItem:(AudioItem *)item;

@end
