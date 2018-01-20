//
//  AudioSegment.h
//  Ringo
//
//  Created by Alexander Ivanov on 20.07.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KEY_START_TIME @"s"
#define KEY_END_TIME @"e"
#define KEY_DURATION @"d"

#define AUDIO_SEGMENT_LENGTH 40.0

@interface AudioSegment : NSObject

- (instancetype)initWithStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime duration:(NSTimeInterval)duration;

@property (assign, nonatomic, readonly) NSTimeInterval startTime;
@property (assign, nonatomic, readonly) NSTimeInterval endTime;
@property (assign, nonatomic, readonly) NSTimeInterval duration;

- (NSTimeInterval)segmentDuration;

+ (instancetype)createWithDuration:(NSTimeInterval)duration;
+ (instancetype)createWithDictionary:(NSDictionary *)dictionary;

@end
