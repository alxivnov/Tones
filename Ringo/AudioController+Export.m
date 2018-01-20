//
//  AudioConroller+Export.m
//  Ringo
//
//  Created by Alexander Ivanov on 04.11.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "AudioController+Export.h"
#import "AudioItem+Export.h"

@implementation AudioController (Export)

- (void)addCurrentActivities:(NSTimeInterval)expirationInterval {
	if (expirationInterval < 0.0)
		return;

	NSDate *expirationDate = expirationInterval > 0.0 ? [[NSDate date] dateByAddingTimeInterval:expirationInterval] : Nil;
	for (AudioItem *audioItem in self.items)
		[audioItem becomeCurrentActivity:expirationDate];
}

@end
