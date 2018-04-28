//
//  AudioItem+VK.m
//  Ringo
//
//  Created by Alexander Ivanov on 24.09.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "AudioItem+Import.h"
#import "Global.h"

#import "VKHelper.h"

#import "Affiliates+Convenience.h"
#import "MediaPlayer+Convenience.h"
#import "NSArray+Convenience.h"
#import "NSObject+Convenience.h"
#import "VKAPI.h"

#define LETTER_CHARACTER_SET [NSCharacterSet letterCharacterSet]

@implementation AudioItem (Import)

- (NSString *)searchDescription {
	NSString *artist = self.artist;
	NSString *title = self.title;

	if ([title hasSuffix:@" (Remastered)"])
		title = [title substringToIndex:title.length - 13];
	
	return artist.length && title.length ? [@[ title, artist ] componentsJoinedByString:STR_SPACE] : artist.length ? artist : title.length ? title : STR_EMPTY;
}

- (BOOL)search:(void (^)(NSArray<AFMediaItem *> *))handler {
	return [AFMediaItem searchForSong:[self searchDescription] handler:handler];
}

- (BOOL)lookup:(void (^)(AFMediaItem *))handler {
	if (!handler)
		return NO;

	return [self search:^(NSArray<AFMediaItem *> *items) {
		items = [items query:^BOOL(AFMediaItem *obj) {
			return obj.isTrack;
		}];

		NSString *artist = [[self.artist lowercaseString] stringBySelectingCharactersInSet:LETTER_CHARACTER_SET];
		NSArray *equal = [items query:^BOOL(AFMediaItem *obj) {
			return [artist isEqualToString:[[obj.artistName lowercaseString] stringBySelectingCharactersInSet:LETTER_CHARACTER_SET]];
		}];
		if (equal.count)
			items = equal;
		
		NSTimeInterval duration = self.segment.duration > 0.0 ? self.segment.duration : self.duration;
		if (duration > 0.0)
			items = [items sortedArrayUsingComparator:^NSComparisonResult(AFMediaItem *obj1, AFMediaItem *obj2) {
				return [@(fabs(obj1.trackTime - duration)) compare:@(fabs(obj2.trackTime - duration))];
			}];

		handler(items.firstObject);
	}];
}

- (BOOL)lookupInMediaLibrary {
	MPMediaQuery *media = [MPMediaQuery createWithComparisonType:MPMediaPredicateComparisonContains artist:self.artist album:self.album title:self.title];
	
	if (!media.items.count)
		return NO;
	
	NSArray *items = media.items;

	NSString *artist = [[self.artist lowercaseString] stringBySelectingCharactersInSet:LETTER_CHARACTER_SET];
	NSArray *equal = [items query:^BOOL(MPMediaItem *obj) {
		return [artist isEqualToString:[[obj.artist lowercaseString] stringBySelectingCharactersInSet:LETTER_CHARACTER_SET]];
	}];
	if (equal.count)
		items = equal;
	
	NSTimeInterval duration = self.segment.duration > 0.0 ? self.segment.duration : self.duration;
	if (duration > 0.0)
		items = [media.items sortedArrayUsingComparator:^NSComparisonResult(MPMediaItem *obj1, MPMediaItem *obj2) {
			return [@(fabs(obj1.playbackDuration - duration)) compare:@(fabs(obj2.playbackDuration - duration))];
		}];

	[[AudioItem createWithMediaItem:items.firstObject] copyTo:self];
	
	return YES;
}

- (void)lookupInVK:(void (^)(VKAudioItem *))handler {
	if ([[VKHelper instance] wakeUpSession]) {
		[[VKAPI api] searchAudio:[self searchDescription] handler:^(NSArray<VKAudioItem *> *items) {
			if (!items.count) {
				if (handler)
					handler(Nil);

				return;
			}

			NSString *artist = [[self.artist lowercaseString] stringBySelectingCharactersInSet:LETTER_CHARACTER_SET];
			NSArray *equal = [items query:^BOOL(VKAudioItem *obj) {
				return [artist isEqualToString:[[obj.artist lowercaseString] stringBySelectingCharactersInSet:LETTER_CHARACTER_SET]];
			}];
			if (equal.count)
				items = equal;
			
			NSString *title = [[self.title lowercaseString] stringBySelectingCharactersInSet:LETTER_CHARACTER_SET];
			equal = [items query:^BOOL(VKAudioItem *obj) {
				return [title isEqualToString:[[obj.title lowercaseString] stringBySelectingCharactersInSet:LETTER_CHARACTER_SET]];
			}];
			if (equal.count)
				items = equal;

			NSTimeInterval duration = self.segment.duration > 0.0 ? self.segment.duration : self.duration;
			if (duration > 0.0)
				items = [items sortedArrayUsingComparator:^NSComparisonResult(VKAudioItem *obj1, VKAudioItem *obj2) {
					return [@(fabs(obj1.duration - duration)) compare:@(fabs(obj2.duration - duration))];
				}];
			
			VKAudioItem *item = items.firstObject.duration >= 40.0 ? items.firstObject : Nil;

			[[AudioItem createWithAudioItem:item] copyTo:self];
			
			if (handler)
				handler(item);
		}];
		
		[self cacheArtwork:Nil];
	} else if (handler)
		handler(Nil);
}

- (void)cacheArtwork:(void(^)(UIImage *))handler {
	if (self.artwork)
		return;

	self.artwork = [self.mediaItem.artwork imageWithSize:MPMediaItemArtworkSize];

	if (!self.artwork)
//		[NSSemaphore sync:^(NSSemaphore *sema) {
			[self lookup:^(AFMediaItem *mediaItem) {
				if (mediaItem.artworkUrl60)
					[mediaItem.artworkUrl60 cache:^(NSURL *url) {
						self.artwork = [UIImage imageWithContentsOfURL:url];

//						[sema signal];
						if (handler)
							handler(self.artwork);
					}];
				else if (mediaItem.artworkUrl100)
					[mediaItem.artworkUrl100 cache:^(NSURL *url) {
						self.artwork = [UIImage imageWithContentsOfURL:url];

//						[sema signal];
						if (handler)
							handler(self.artwork);
					}];
				else
//					[sema signal];
					if (handler)
						handler(self.artwork);
			}];
//		} wait:wait ? 1.0 : -1.0];
	else
		if (handler)
			handler(self.artwork);
}

- (void)cacheArtwork {
	if (self.artwork)
		return;

	self.artwork = [self.mediaItem.artwork imageWithSize:MPMediaItemArtworkSize];
/*
	[NSSemaphore sync:^(NSSemaphore *sema) {
		[self cacheArtwork:^(UIImage *artwork) {
			[sema signal];
		}];
	} wait:1.0];
*/
}

+ (instancetype)createWithWallItem:(VKWallItem *)item {
	if (!item)
		return Nil;

	AudioItem *instance = [AudioItem createWithDictionary:[[item.linkURLs firstObject:^BOOL(NSURL *obj) {
		return [obj.absoluteString hasPrefix:URL_PHP] || [obj.absoluteString hasPrefix:URL_OLD];
	}] queryDictionary]];
//	[instance fetchTones:Nil];
	[instance lookupInMediaLibrary];
	if (item.audioItems.count)
		[[AudioItem createWithAudioItem:item.audioItems.firstObject] copyTo:instance];
//	else
//		[instance lookupInVK:Nil];
	instance.artwork = [UIImage imageWithContentsOfURL:[item.photoURLs.firstObject cache]];
	return instance;
}

+ (instancetype)createWithTone:(Tone *)tone {
	if (!tone)
		return Nil;

	AudioItem *item = [[AudioItem alloc] initWithArtist:tone.artist title:tone.title album:tone.album];
	item.segment = [[AudioSegment alloc] initWithStartTime:tone.startTime endTime:tone.endTime duration:tone.duration];
//	[item fetchTones:Nil];
	if (![item lookupInMediaLibrary] || !item.assetURL) {
//		if (![[VKHelper instance] wakeUpSession])
			[item cacheArtwork];
//		else
//			[item lookupInVK:Nil];
	}
	return item;
}

@end
