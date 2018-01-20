//
//  AudioSegment+Export.h
//  Ringo
//
//  Created by Alexander Ivanov on 07.09.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import "AudioSegment.h"

@interface AudioSegment (Export)

- (NSString *)comment;

+ (instancetype)createFromComment:(NSString *)comment;

@end
