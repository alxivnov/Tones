//
//  AudioItem.m
//  Ringo
//
//  Created by Alexander Ivanov on 08.07.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import "AudioItem.h"
#import "AudioItem+Export.h"
#import "AudioSegment.h"
#import "AudioSegment+Export.h"
#import "Global.h"
#import "Tone.h"

#import "NSCharacterSet+Convenience.h"
#import "NSRateController.h"
//#import "VKHelper.h"

#import "Affiliates+Convenience.h"
#import "MediaPlayer+Convenience.h"
#import "AVAsset+Convenience.h"
#import "NSArray+Convenience.h"
#import "NSFileManager+Convenience.h"
#import "NSObject+Convenience.h"
#import "SKInAppPurchase.h"

#import "CoreMedia+Convenience.h"

#import <Crashlytics/Answers.h>

#define STR_REG_EX @"((\\(|\\[|\\{|\\<)(.*)(\\.com|\\.net|\\.org|\\.ru|\\.su|\\.kz|\\.ua|\\.uz)(.*)(\\)|\\]|\\}|\\>))|(([ ]*-[ ]*)(.*)(\\.com|\\.net|\\.org|\\.ru|\\.su|\\.kz|\\.ua|\\.uz))|((.*)(\\.com|\\.net|\\.org|\\.ru|\\.su|\\.kz|\\.ua|\\.uz)([ ]*-[ ]*))|(([^ ]*)(\\.com|\\.net|\\.org|\\.ru|\\.su|\\.kz|\\.ua|\\.uz)([^ ]*))"

@interface AudioItem ()
@property (strong, nonatomic) AVURLAsset *URLAsset;
@property (strong, nonatomic) MPMediaItem *mediaItem;
//@property (strong, nonatomic) VKAudioItem *audioItem;

@property (strong, nonatomic) NSURL *assetURL;
@property (strong, nonatomic) NSString *artist;
@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) NSTimeInterval duration;

@property (strong, nonatomic) NSString *album;

@property (strong, nonatomic) CGWaveform *waveform;
@property (strong, nonatomic) NSArray *tones;
@end

@implementation AudioItem

- (instancetype)initWithArtist:(NSString *)artist title:(NSString *)title album:(NSString *)album {
	self = [super init];

	if (self) {
		self.artist = artist;
		self.title = title;
		self.album = album;
	}

	return self;
}

+ (instancetype)createWithURLAsset:(AVURLAsset *)urlAsset {
	if (!urlAsset)
		return Nil;
	
	AudioItem *instance = [self new];
	instance.URLAsset = urlAsset;
	
	instance.artwork = [urlAsset artwork];

	instance.segment = [AudioSegment createFromComment:urlAsset.comment];
	return instance;
}

+ (instancetype)createWithMediaItem:(MPMediaItem *)mediaItem completion:(void (^)(UIImage *image))completion {
	if (!mediaItem) {
		if (completion)
			completion(Nil);

		return Nil;
	}

	AudioItem *instance = [self new];
	instance.mediaItem = mediaItem;

	UIImage *image = [mediaItem.artwork imageWithSize:MPMediaItemArtworkSize];
	instance.artwork = image;
	if (!image)
		[mediaItem.artwork fetchImage:^(UIImage *image) {
			instance.artwork = image;

			if (completion)
				completion(image);
		}];
	else if (completion)
		completion(image);

	return instance;
}

+ (instancetype)createWithMediaItem:(MPMediaItem *)mediaItem {
	return [self createWithMediaItem:mediaItem completion:Nil];
}
/*
+ (instancetype)createWithAudioItem:(VKAudioItem *)audioItem {
	if (!audioItem)
		return Nil;
	
	AudioItem *instance = [self new];
	instance.audioItem = audioItem;
	return instance;
}
*/
+ (instancetype)createWithDictionary:(NSDictionary *)dictionary {
	if (!dictionary)
		return Nil;

	AudioItem *instance = [[self alloc] initWithArtist:dictionary[KEY_ARTIST] title:dictionary[KEY_TITLE] album:dictionary[KEY_ALBUM]];
	instance.segment = [AudioSegment createWithDictionary:dictionary];
	return instance;
}

- (NSURL *)assetURL {
	return self.URLAsset ? self.URLAsset.URL : self.mediaItem.assetURL && [AVURLAsset assetWithURL:self.mediaItem.assetURL].canRead ? self.mediaItem.assetURL : /*self.audioItem.assetURL ? (self.audioItem.assetURL.cacheURL ? self.audioItem.assetURL.cacheURL : self.audioItem.assetURL) :*/ _assetURL;
}

- (NSTimeInterval)duration {
	return self.URLAsset ? self.URLAsset.seconds : self.mediaItem.playbackDuration ? self.mediaItem.playbackDuration : /*self.audioItem ? self.audioItem.duration :*/ _duration;
}

- (NSString *)process:(NSString *)string pattern:(NSString *)pattern {
	if (!pattern.length)
		return string;

	string = [string stringByReplacingMatches:pattern options:NSRegularExpressionCaseInsensitive withTemplate:STR_EMPTY];

	NSArray<NSString *> *components = [string componentsSeparatedByString:STR_UNDERSCORE];
	if (components.count > 2)
		string = [components componentsJoinedByString:STR_SPACE];

	string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return string;
}

- (NSString *)artist:(NSString *)pattern {
	NSString *string = _artist.length ? _artist : self.mediaItem.artist.length ? self.mediaItem.artist : self.URLAsset.artist.length ? self.URLAsset.artist : /*self.audioItem.artist.length ? self.audioItem.artist :*/ STR_EMPTY;

	return [self process:string pattern:pattern];
}

- (NSString *)artist {
	return [self artist:STR_REG_EX];
}

- (NSString *)title:(NSString *)pattern {
	NSString *string = _title.length ? _title : self.mediaItem.title.length ? self.mediaItem.title : self.URLAsset.title.length ? self.URLAsset.title : /*self.audioItem.title.length ? self.audioItem.title :*/ STR_EMPTY;

	return [self process:string pattern:pattern];
}

- (NSString *)title {
	return [self title:STR_REG_EX];
}

- (NSString *)album:(NSString *)pattern {
	NSString *string = _album.length ? _album : self.mediaItem.albumTitle.length ? self.mediaItem.albumTitle : self.URLAsset.album.length ? self.URLAsset.album : STR_EMPTY;

	return [self process:string pattern:pattern];
}

- (NSString *)album {
	return [self album:STR_REG_EX];
}

- (UIImage *)image {
	return self.artwork ? self.artwork : [UIImage originalImage:IMG_RINGO_128];
}

- (NSUInteger)numberOfChannels {
	return [self.URLAsset tracksWithMediaType:AVMediaTypeAudio].firstObject.channelsPerFrame;
}

- (NSString *)description {
	NSString *artist = [self.artist stringByReplacingOccurrencesOfString:STR_NULL withString:STR_EMPTY];
	NSString *title = [self.title stringByReplacingOccurrencesOfString:STR_NULL withString:STR_EMPTY];

	NSString *description = artist.length && title.length ? [@[ artist, STR_HYPHEN, title ] componentsJoinedByString:STR_SPACE] : artist.length ? artist : title.length ? title : STR_EMPTY;
	description = [description stringByRemovingCharactersInSet:[NSCharacterSet illegalCharacterSet]];
	return description;
}

- (NSArray<NSString *> *)recordNames:(Tone *)tone {
	NSMutableArray<NSString *> *recordNames = [NSMutableArray arrayWithCapacity:4];

	NSString *recordName = [tone recordName];
	if (recordName)
		[recordNames addObject:recordName];

	recordName = [[Tone class] identifierWithArtist:self.artist album:Nil title:self.title duration:self.segment.duration startTime:self.segment.startTime endTime:self.segment.endTime];
	if (recordName)
		[recordNames addObject:recordName];

	recordName = [[Tone class] identifierWithArtist:[self artist:Nil] album:[self album:Nil] title:[self title:Nil] duration:self.segment.duration startTime:self.segment.startTime endTime:self.segment.endTime];
	if (recordName)
		[recordNames addObject:recordName];

	recordName = [[Tone class] identifierWithArtist:[self artist:Nil] album:Nil title:[self title:Nil] duration:self.segment.duration startTime:self.segment.startTime endTime:self.segment.endTime];
	if (recordName)
		[recordNames addObject:recordName];

	return recordNames;
}

- (void)updateTone:(NSArray *)tones completion:(void(^)(Tone *, BOOL))completion {
	if ([self.segment segmentDuration] > 0.0 && [self.segment segmentDuration] < AUDIO_SEGMENT_LENGTH && self.artist.length && self.title.length) {
		[AFMediaItem searchForSong:[@[ self.artist, self.title ] componentsJoinedByString:STR_SPACE] handler:^(NSArray<AFMediaItem *> *results) {
			if (results.count) {
				Tone *tone = [Tone createWithArtist:self.artist title:self.title startTime:self.segment.startTime endTime:self.segment.endTime];
				tone.album = self.album;
				tone.duration = self.segment.duration;

				NSArray<NSString *> *recordNames = [self recordNames:tone];
				Tone *existing = [self.tones firstObject:^BOOL(Tone *obj) {
					return [[obj recordName] isEqualToAnyString:recordNames];
				}];
				if (existing) {
					if (![existing.record.creatorUserRecordID.recordName isEqualToString:CKDefaultOwnerRecordName])
						[[CKContainer defaultContainer] fetchUserRecordID:^(CKRecordID *recordID) {
							if ([existing.record.creatorUserRecordID.recordName isEqualToString:recordID.recordName]) {
								if (completion)
									completion(existing, NO);
							} else {
								existing.exportCount++;
								[existing update:Nil];

								if (completion)
									completion(existing, NO);
							}
						}];
					else if (completion)
						completion(existing, NO);
				} else {
					tone.importCount = self.tones.count;
					[tone update:Nil];
					
					if (completion)
						completion(tone, YES);
				}
			} else {
				if (completion)
					completion(Nil, NO);
			}
		}];
	} else {
		if (completion)
			completion(Nil, NO);
	}
}

- (void)internalUpdateTone:(NSArray *)tones completion:(void(^)(BOOL))completion {
	[self updateTone:tones completion:^(Tone *t, BOOL n) {
		NSLog(@"export: %@, import: %@", t ? @(t.exportCount) : Nil, t ? @(t.importCount) : Nil);
//		if (t)
			[Answers logRating:@((t.exportCount + 1) * (t.importCount + 1)) contentName:[t description] contentType:/*self.audioItem.assetURL ? @"audio" :*/ self.mediaItem.assetURL ? @"media" : self.URLAsset ? @"asset" : Nil contentId:[t recordName] customAttributes:@{ @"export" : @(t.exportCount), @"import" : @(t.importCount), @"action" : @([NSRateController instance].action) }];
//		else
//			[Answers logContentViewWithName:[self description] contentType:self.audioItem.assetURL ? @"audio" : self.mediaItem.assetURL ? @"media" : self.URLAsset ? @"asset" : Nil contentId:Nil customAttributes:Nil];

		if (completion)
			completion(n);
	}];
}

- (void)updateTone:(void(^)(BOOL))completion {
	if (self.tones)
		[self internalUpdateTone:self.tones completion:completion];
	else
		[self fetchTones:^(NSArray *tones) {
			[self internalUpdateTone:tones completion:completion];
		}];
}

- (void)fetchTones:(void (^)(NSArray *))handler {
	if (self.artist || self.title)
		[Tone loadWithArtist:[self artist:Nil] title:[self title:Nil] completion:^(NSArray *results) {
			self.tones = [results sortedArray];

			if (handler)
				handler(results);
		}];
	else
		self.tones = [NSArray new];
}

- (AVURLAsset *)returnURLAsset {
	self.URLAsset = [AVURLAsset assetWithURL:self.assetURL];
	return self.URLAsset;
}

- (void)generateWaveform:(void (^)(CGWaveform *))handler {
	if (self.assetURL)
//		[self.assetURL cache:^(NSURL *url) {
//			if (url)
				[[self returnURLAsset] readWithSettings:@{ AVFormatIDKey : @(kAudioFormatLinearPCM), AVLinearPCMBitDepthKey : @(32), AVLinearPCMIsFloatKey : @YES, AVNumberOfChannelsKey : @(1) } handler:^(NSData *data) {
					self.waveform = [CGWaveform waveformFromData:data frame:CGRectNull flag:[[NSUserDefaults standardUserDefaults] boolForKey:STR_LOGARITHMIC_WAVEFORM]];

					if (handler)
						handler(self.waveform);
				}];
//			else
//				self.waveform = [UIImage new];
//		}];
	else
		self.waveform = [CGWaveform new];
}

- (AVAssetWriter *)exportAudio:(void (^)(double progress, NSURL *url))handler {
	BOOL purchased = [IAP_IDS any:^BOOL(id obj) {
		return [SKInAppPurchase purchaseWithProductIdentifier:obj].purchased;
	}];

	AudioSegment *segment = self.segment ? self.segment : [AudioSegment createWithDuration:self.duration];
	
	NSURL *outputURL = [self toneURL];
	if ([outputURL isExistingItem])
		[outputURL removeItem];

	AVAsset *asset = [self returnURLAsset];
	NSTimeInterval assetDuration = asset.seconds;
	if (segment.endTime > assetDuration)
		segment = [[AudioSegment alloc] initWithStartTime:fmax(assetDuration - segment.segmentDuration, 0.0) endTime:assetDuration duration:assetDuration];

	CMTimeRange timeRange = CMTimeRangeFromTimeIntervalToTimeInterval(segment.startTime, segment.endTime);
	NSArray *metadata = [self metadataWithComment:[segment comment]];
//	[self.assetURL cache:^(NSURL *url) {

	AVAssetWriter *writer = [asset exportAudioWithSettings:purchased ? AVAudioSettingsMPEG4AACStereo : AVAudioSettingsMPEG4AACMono timeRange:timeRange metadata:metadata to:outputURL handler:^(double progress) {
		if (handler)
			handler(progress, progress < 1.0 ? Nil : outputURL);
	}];
//	}];

	return writer;
}

- (NSURL *)toneURL {
	NSString *description = [self description];
	description = [description stringByApplyingTransform:NSStringTransformToLatin];
	description = [description stringByApplyingTransform:NSStringTransformStripCombiningMarks];
	description = [description fileSystemString];

	return [[[NSFileManager URLForDirectory:NSDocumentDirectory] URLByAppendingPathComponent:description] URLByAppendingPathExtension:EXT_M4R];
}

- (void)copyTo:(AudioItem *)item {
	if (!item)
		return;

	if (!item.URLAsset)
		item.URLAsset = _URLAsset;
	if (!item.mediaItem)
		item.mediaItem = _mediaItem;
/*	if (!item.audioItem)
		item.audioItem = _audioItem;
*/
	if (!item.assetURL)
		item.assetURL = _assetURL;
	if (!item.artist)
		item.artist = _artist;
	if (!item.title)
		item.title = _title;
	if (!item.duration)
		item.duration = _duration;

	if (!item.album)
		item.album = _album;
	if (!item.artwork)
		item.artwork = _artwork;

//	if (!item.segment)
//		item.segment = _segment;
}

@end
