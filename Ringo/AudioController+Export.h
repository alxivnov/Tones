//
//  AudioConroller+Export.h
//  Ringo
//
//  Created by Alexander Ivanov on 04.11.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "AudioController.h"

@interface AudioController (Export)

- (void)addCurrentActivities:(NSTimeInterval)expirationInterval;

@end
