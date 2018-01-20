//
//  AudioController+Import.h
//  Ringo
//
//  Created by Alexander Ivanov on 02.11.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "AudioController.h"

@interface AudioController (Import)

- (void)presentITunesStoreAlert:(AudioItem *)audioItem;

- (void)cacheAudioItem:(AudioItem *)item completion:(void (^)(NSURL *))handler;

@end
