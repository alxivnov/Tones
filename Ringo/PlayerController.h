//
//  PlayerController.h
//  Ringo
//
//  Created by Alexander Ivanov on 04.10.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "WaveformController.h"

@interface PlayerController : WaveformController

@property (assign, nonatomic, readonly) NSTimeInterval startTime;
@property (assign, nonatomic, readonly) NSTimeInterval endTime;
@property (assign, nonatomic, readonly) NSTimeInterval duration;
@property (assign, nonatomic, readonly) NSTimeInterval currentTime;
- (void)setSegmentStart:(NSTimeInterval)start andSegmentEnd:(NSTimeInterval)end;

- (void)playerDidChangeStatus:(BOOL)isPlaying;
- (void)playerDidChangeTime:(NSTimeInterval)time;

@end
