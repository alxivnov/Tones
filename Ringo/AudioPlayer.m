//
//  AudioPlayer.m
//  Ringo
//
//  Created by Alexander Ivanov on 05.09.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import "AudioPlayer.h"
#import "AudioItem+Import.h"

#import "CoreMedia+Convenience.h"
#import "Dispatch+Convenience.h"
#import "MediaPlayer+Convenience.h"
#import "AVPlayer+Convenience.h"
#import "NSObject+Convenience.h"
#import "NSTimer+Convenience.h"

@interface AudioPlayer ()
@property (strong, nonatomic) AVAudioSegmentPlayer *player;

@property (strong, nonatomic) AVPlayer *onlinePlayer;
@property (strong, nonatomic) id timeObserver;

@property (strong, nonatomic) MPMusicPlayerController *musicPlayer;

@property (strong, nonatomic) NSNumber *startTime;
@property (strong, nonatomic) NSNumber *endTime;
@end

@implementation AudioPlayer

- (void)play:(NSURL *)url startTime:(NSNumber *)startTime endTime:(NSNumber *)endTime numberOfLoops:(NSInteger)numberOfLoops handler:(void(^)(NSTimeInterval))handler {
	[self stop];

	if (url.isWebAddress) {
		self.onlinePlayer = [AVPlayer playerWithURL:url];
		__weak AudioPlayer *__self = self;
		__weak AVPlayer *__onlinePlayer = self.onlinePlayer;
		__weak id __timeObserver = Nil;
		self.timeObserver = [self.onlinePlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithTimeInterval(0.1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
			NSTimeInterval currentTime = CMTimeGetTimeInterval(time);
			if (endTime && endTime.doubleValue <= currentTime) {
				[__onlinePlayer pause];

				[__onlinePlayer seekToTime:CMTimeMakeWithTimeInterval(startTime.doubleValue)];
			}
			
			if (![__onlinePlayer isPlaying:time]) {
				currentTime = NSTimeIntervalSince1970;
				
				[__onlinePlayer removeTimeObserver:__timeObserver];//__self.timeObserver];
			}

			__self.currentTime = currentTime;
			if (handler)
				handler(currentTime);
		}];
		__timeObserver = self.timeObserver;

		if (startTime && endTime)
			[self.onlinePlayer seekToTime:CMTimeMakeWithTimeInterval(startTime.doubleValue)];

		[self.onlinePlayer play];
	} else {
		self.player = [AVAudioSegmentPlayer playerWithContentsOfURL:url];
		self.player.numberOfLoops = numberOfLoops;
		
		__weak AudioPlayer *__self = self;
		self.player.timeChange = ^(AVAudioSegmentPlayer *sender) {
			__self.currentTime = sender.isPlaying ? sender.currentTime : NSTimeIntervalSince1970;
			if (handler)
				handler(__self.currentTime);
		};
		self.player.statusChange = ^(AVAudioSegmentPlayer *sender) {
			__self.currentTime = sender.isPlaying ? sender.currentTime : NSTimeIntervalSince1970;
			if (handler)
				handler(__self.currentTime);
		};

		if (startTime && endTime)
			[self.player setSegmentStart:startTime.doubleValue andSegmentEnd:endTime.doubleValue];

		[self.player play];
	}

	self.startTime = startTime;
	self.endTime = endTime;
}

- (void)stop {
	if (self.player) {
		[self.player stop];

		self.player = Nil;
	}

	if (self.onlinePlayer) {
		[self.onlinePlayer pause];

		self.onlinePlayer = Nil;
	}

	if (self.musicPlayer) {
		[self.musicPlayer stop];

		self.musicPlayer = Nil;
	}

	self.startTime = Nil;
	self.endTime = Nil;
}

- (BOOL)isPlaying:(NSURL *)url {
	return (self.player.isPlaying && (url.query.length ? [self.player.url.query isEqualToString:url.query] : [self.player.url.lastPathComponent isEqualToString:url.lastPathComponent])) || (self.onlinePlayer.isPlaying && [self.onlinePlayer.url.lastPathComponent isEqualToString:url.lastPathComponent]);
}

- (BOOL)isPlaying {
	return self.player.isPlaying || self.onlinePlayer.isPlaying;
}

- (void)dealloc {
	self.player = Nil;

	self.onlinePlayer = Nil;
	self.timeObserver = Nil;

	self.musicPlayer = Nil;
}

- (void)playItem:(AudioItem *)item segment:(AudioSegment *)segment numberOfLoops:(NSInteger)numberOfLoops handler:(void (^)(NSTimeInterval))handler {
	if (item.assetURL)
		[self play:item.assetURL startTime:segment ? @(segment.startTime) : Nil endTime:segment ? @(segment.endTime) : Nil numberOfLoops:numberOfLoops handler:handler];
	else if ([item mediaItem])
		[self playSomething:[item mediaItem] segment:segment numberOfLoops:numberOfLoops handler:handler];
	else
		[item lookup:^(AFMediaItem *mediaItem) {
			[self playSomething:mediaItem segment:segment numberOfLoops:numberOfLoops handler:handler];
		}];
}

- (void)playSomething:(NSObject *)something segment:(AudioSegment *)segment numberOfLoops:(NSInteger)numberOfLoops handler:(void (^)(NSTimeInterval))handler {
	void (^completionHandler)(NSString *, NSString *) = ^void(NSString *artist, NSString *title) {
		[GCD main:^{
			if (handler)
				[[[NSTimerBlock alloc] initWithBlock:^BOOL(MPMusicPlayerController *player) {
					NSTimeInterval time = player.currentPlaybackTime;

					if (!isfinite(time) || time > segment.endTime)
						[player stop];

					handler(player.isPlaying && (([player.nowPlayingItem.artist.lowercaseString isEqualToString:artist.lowercaseString] && [player.nowPlayingItem.title.lowercaseString isEqualToString:title.lowercaseString]) || (artist == Nil && title == Nil)) ? time : NSTimeIntervalSince1970);

					return (!isfinite(time) || time == 0.0 || time - segment.startTime > 0.1) && !player.isPlaying;
				}] scheduledTimerWithTimeInterval:0.1 userInfo:self.musicPlayer repeats:YES];
		}];
	};

	[self stop];

	if (@available(iOS 10.3, *))
		self.musicPlayer = [MPMusicPlayerController applicationQueuePlayer];
	else
		self.musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
	if ([something isKindOfClass:[MPMediaItem class]]) {
		MPMediaItem *mpItem = cls(MPMediaItem, something);
		[self.musicPlayer playItem:mpItem startTime:segment.startTime endTime:segment.endTime completionHandler:^(BOOL success) {
			completionHandler(success ? mpItem.artist : Nil, success ? mpItem.title : Nil);
		}];
	} else if ([something isKindOfClass:[AFMediaItem class]]) {
		AFMediaItem *afItem = cls(AFMediaItem, something);
		[self.musicPlayer playStoreID:[afItem.trackId description] startTime:segment.startTime endTime:segment.endTime completionHandler:^(MPMediaItem *item) {
			completionHandler(afItem.artistName, afItem.trackName);
		}];
	}

	self.startTime = @(segment.startTime);
	self.endTime = @(segment.endTime);
}

- (BOOL)stopItem:(AudioItem *)item segment:(AudioSegment *)segment {
	if (item && ![self isPlayingItem:item segment:segment])
		return NO;

	[self stop];

	return YES;
}

- (BOOL)stopItem:(AudioItem *)item {
	return [self stopItem:item segment:Nil];
}

- (BOOL)isPlayingItem:(AudioItem *)item segment:(AudioSegment *)segment {
	if (segment && !(DBL_EQUALS(segment.startTime, self.startTime.doubleValue) && DBL_EQUALS(segment.endTime, self.endTime.doubleValue)))
		return NO;

	if (item.assetURL || ![item mediaItem])
		return [self isPlaying:item.assetURL];
	else
		return self.musicPlayer.isPlaying && (![item mediaItem] || self.musicPlayer.nowPlayingItem == [item mediaItem]);
}

- (BOOL)isPlayingItem:(AudioItem *)item {
	return [self isPlayingItem:item segment:Nil];
}

@end
