//
//  AudioSegment.m
//  Ringo
//
//  Created by Alexander Ivanov on 20.07.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "AudioSegment.h"
#import "Global.h"

#import "NSObject+Convenience.h"

#import "NSFormatter+Convenience.h"

@interface AudioSegment ()
@property (assign, nonatomic) NSTimeInterval startTime;
@property (assign, nonatomic) NSTimeInterval endTime;
@property (assign, nonatomic) NSTimeInterval duration;
@end

@implementation AudioSegment

- (instancetype)initWithStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime duration:(NSTimeInterval)duration {
	self = [self init];
	
	if (self) {
		self.startTime = startTime;
		self.endTime = endTime;
		self.duration = duration;
	}
	
	return self;
}

- (NSTimeInterval)segmentDuration {
	return self.endTime - self.startTime;
}

- (NSString *)description {
	return [@[ [[NSDateComponentsFormatter mmssFormatter] stringFromTimeInterval:self.startTime], STR_HYPHEN, [[NSDateComponentsFormatter mmssFormatter] stringFromTimeInterval:self.endTime] ] componentsJoinedByString:STR_SPACE];
}

+ (instancetype)createWithDuration:(NSTimeInterval)duration {
	return [[self alloc] initWithStartTime:0.0 endTime:fmin(AUDIO_SEGMENT_LENGTH, duration) duration:duration];
}

+ (instancetype)createWithDictionary:(NSDictionary *)dictionary {
	if (!dictionary)
		return Nil;

	AudioSegment *instance = [self createWithDuration:0.0];
	
	if (dictionary[KEY_START_TIME])
		instance.startTime = [dictionary[KEY_START_TIME] doubleValue];
	if (dictionary[KEY_END_TIME])
		instance.endTime = [dictionary[KEY_END_TIME] doubleValue];
	if (dictionary[KEY_DURATION])
		instance.duration = [dictionary[KEY_DURATION] doubleValue];
	
	return [instance segmentDuration] > 0.0 && [instance segmentDuration] < AUDIO_SEGMENT_LENGTH ? instance : Nil;
}

@end
