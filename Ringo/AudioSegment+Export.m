//
//  AudioSegment+Export.m
//  Ringo
//
//  Created by Alexander Ivanov on 07.09.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import "AudioSegment+Export.h"
#import "Global.h"

#import "NSObject+Convenience.h"

@implementation AudioSegment (Export)

- (NSString *)comment {
	NSString *startTime = [@[ KEY_START_TIME, @(self.startTime) ] componentsJoinedByString:STR_COLON];
	NSString *endTime = [@[ KEY_END_TIME, @(self.endTime) ] componentsJoinedByString:STR_COLON];
	NSString *duration = [@[ KEY_DURATION, @(self.duration) ] componentsJoinedByString:STR_COLON];
	NSString *description = [@[ startTime, endTime, duration ] componentsJoinedByString:STR_NEW_LINE];
	return description;
}

+ (instancetype)createFromComment:(NSString *)comment {
	NSTimeInterval startTime = NSTimeIntervalSince1970;
	NSTimeInterval endTime = NSTimeIntervalSince1970;
	NSTimeInterval duration = 0.0;
	
	NSArray *lines = [comment componentsSeparatedByString:STR_NEW_LINE];
	for (NSString *line in lines) {
		NSArray *keyValue = [line componentsSeparatedByString:STR_COLON];
		if (keyValue.count < 2)
			continue;
		
		if ([KEY_START_TIME isEqualToString:keyValue[0]] || [@"start-time" isEqualToString:keyValue[0]])
			startTime = [keyValue[1] doubleValue];
		else if ([KEY_END_TIME isEqualToString:keyValue[0]] || [@"end-time" isEqualToString:keyValue[0]])
			endTime = [keyValue[1] doubleValue];
		else if ([KEY_DURATION isEqualToString:keyValue[0]])
			duration = [keyValue[1] doubleValue];
	}
	
	return startTime == NSTimeIntervalSince1970 && endTime == NSTimeIntervalSince1970 ? Nil : [[AudioSegment alloc] initWithStartTime:startTime == NSTimeIntervalSince1970 ? 0.0 : startTime endTime:endTime == NSTimeIntervalSince1970 ? AUDIO_SEGMENT_LENGTH : endTime duration:duration];
}

@end
