//
//  AudioItem+Share.h
//  Ringo
//
//  Created by Alexander Ivanov on 06.09.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import "AudioItem.h"
#import "Tone.h"

@interface AudioItem (Export)

- (NSArray *)metadataWithComment:(NSString *)comment;

@property (strong, nonatomic, readonly) NSURL *shareURL;
@property (strong, nonatomic, readonly) NSURL *fbShareURL;
@property (strong, nonatomic, readonly) NSURL *vkShareURL;

- (NSString *)shareDescription;

- (NSString *)identifier;

- (void)becomeCurrentActivity:(NSDate *)expirationDate;

@end
