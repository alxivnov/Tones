//
//  AudioItem.h
//  Ringo
//
//  Created by Alexander Ivanov on 08.07.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AudioSegment.h"
#import "CGWaveform.h"

#import "CoreGraphics+Convenience.h"
#import "VKItem.h"

#define KEY_TITLE @"t"
#define KEY_ALBUM @"m"
#define KEY_ARTIST @"a"

#define MPMediaItemArtworkSize CGSizeMake(600.0, 600.0)

@import AVFoundation;
@import MediaPlayer;

@interface AudioItem : NSObject

- (instancetype)initWithArtist:(NSString *)artist title:(NSString *)title album:(NSString *)album;

@property (strong, nonatomic, readonly) NSURL *assetURL;
@property (assign, nonatomic, readonly) NSTimeInterval duration;
@property (strong, nonatomic, readonly) NSString *artist;
@property (strong, nonatomic, readonly) NSString *title;

@property (strong, nonatomic, readonly) NSString *album;
@property (strong, nonatomic, readonly) UIImage *image;
@property (strong, nonatomic) UIImage *artwork;

@property (assign, nonatomic, readonly) NSUInteger numberOfChannels;

+ (instancetype)createWithURLAsset:(AVURLAsset *)asset;
+ (instancetype)createWithMediaItem:(MPMediaItem *)mediaItem;
+ (instancetype)createWithAudioItem:(VKAudioItem *)audioItem;
+ (instancetype)createWithDictionary:(NSDictionary *)dictionary;

//+ (instancetype)createWithURLAsset:(AVURLAsset *)asset segment:(AudioSegment **)segmentPointer;
+ (instancetype)createWithMediaItem:(MPMediaItem *)mediaItem completion:(void (^)(UIImage *image))completion;
- (MPMediaItem *)mediaItem;

@property (strong, nonatomic) AudioSegment *segment;
@property (strong, nonatomic, readonly) NSArray *tones;
@property (strong, nonatomic, readonly) CGWaveform *waveform;

- (void)updateTone:(void(^)(BOOL tone))completion;
- (void)fetchTones:(void (^)(NSArray *tones))handler;
- (void)generateWaveform:(void (^)(CGWaveform *waveform))handler;
- (AVAssetWriter *)exportAudio:(void (^)(double progress, NSURL *url))handler;
- (NSURL *)toneURL;

- (void)copyTo:(AudioItem *)item;

@end
