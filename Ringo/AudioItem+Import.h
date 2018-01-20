//
//  AudioItem+VK.h
//  Ringo
//
//  Created by Alexander Ivanov on 24.09.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "AudioItem.h"
#import "Tone.h"

#import "Affiliates+Convenience.h"

@interface AudioItem (Import)

- (BOOL)search:(void(^)(NSArray<AFMediaItem *> *items))handler;
- (BOOL)lookup:(void (^)(AFMediaItem *))handler;

- (BOOL)lookupInMediaLibrary;

- (void)lookupInVK:(void (^)(VKAudioItem *vkAudioItem))handler;

- (void)cacheArtwork:(void(^)(UIImage *artwork))handler;

+ (instancetype)createWithWallItem:(VKWallItem *)item;

+ (instancetype)createWithTone:(Tone *)tone;

@end
