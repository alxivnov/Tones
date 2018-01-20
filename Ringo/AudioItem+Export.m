//
//  AudioItem+Share.m
//  Ringo
//
//  Created by Alexander Ivanov on 06.09.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import "AudioItem+Export.h"
#import "Global.h"
#import "Localized.h"

#import "AVAsset+Convenience.h"
#import "NSObject+Convenience.h"
#import "NSUserActivity+Convenience.h"
#import "NSURL+Convenience.h"

@implementation AudioItem (Export)

- (NSArray *)metadataWithComment:(NSString *)comment {
	NSMutableArray *metadata = [NSMutableArray new];
	if (self.title.length)
		[metadata addObject:[AVMetadataItem metadataItemWithKey:AVMetadataCommonKeyTitle value:self.title]];
	if (self.artist.length)
		[metadata addObject:[AVMetadataItem metadataItemWithKey:AVMetadataCommonKeyArtist value:self.artist]];

	if (self.album.length)
		[metadata addObject:[AVMetadataItem metadataItemWithKey:AVMetadataCommonKeyAlbumName value:self.album]];

	UIImage *artwork = [[self.image imageWithBackground:[UIColor whiteColor]] imageWithSize:CGSizeMake(256.0, 256.0) mode:UIImageScaleAspectFit];
	NSData *data = UIImageJPEGRepresentation(artwork, 0.85);
	if (data.length)
		[metadata addObject:[AVMutableMetadataItem metadataItemWithKey:AVMetadataCommonKeyArtwork value:data]];

	if (comment.length)
		[metadata addObject:[AVMetadataItem metadataItemWithKey:AVMetadataCommonKeyDescription value:comment]];

	return metadata;
}

- (NSDictionary *)queryDictionary {
	NSMutableDictionary *query = [NSMutableDictionary new];

	if (self.artist.length)
		query[KEY_ARTIST] = self.artist;
	if (self.title.length)
		query[KEY_TITLE] = self.title;
	if (self.album.length && ![self.album isEqualToString:self.artist] && ![self.album isEqualToString:self.title])
		query[KEY_ALBUM] = self.album;

	if (self.segment) {
//		if (self.segment.startTime != 0.0)
			query[KEY_START_TIME] = [NSString stringWithFormat:@"%f", self.segment.startTime];
//		if (self.segment.endTime != AUDIO_SEGMENT_LENGTH)
			query[KEY_END_TIME] = [NSString stringWithFormat:@"%f", self.segment.endTime];
		if (self.segment.duration != 0.0)
			query[KEY_DURATION] = [NSString stringWithFormat:@"%f", self.segment.duration];
	}

	return query;
}

- (NSURL *)shareURL {
	return [[NSURL URLWithString:URL_PHP] URLByAppendingQueryDictionary:[self queryDictionary] allowedCharacters:Nil];
}

- (NSURL *)fbShareURL {
	return [[NSURL URLWithString:URL_PHP_FB] URLByAppendingQueryDictionary:[self queryDictionary] allowedCharacters:Nil];
}

- (NSURL *)vkShareURL {
	return [[NSURL URLWithString:URL_PHP] URLByAppendingQueryDictionary:[self queryDictionary] allowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
}

- (NSString *)shareDescription {
	return [@[ [self description], URL_HASHTAG ] componentsJoinedByString:STR_SPACE];
}

- (void)becomeCurrentActivity:(NSDate *)expirationDate {
	NSUserActivity *activity = [[NSUserActivity alloc] initWithActivityType:STR_TONE];

//	[activity addUserInfoEntriesFromDictionary:@{ STR_URL : [self shareURL] }];
	activity.title = self.title;
	[activity setContentDescription:[[NSArray arrayWithObject:self.artist withObject:self.segment.description] componentsJoinedByString:STR_NEW_LINE]];
	[activity setThumbnailData:[self.artwork jpegRepresentation:0.75]];
	activity.allKeywords = [Localized keywords];
	activity.eligibility = NSUserActivityEligibleForSearch | NSUserActivityEligibleForPublicIndexing;
	if (expirationDate)
		activity.expirationDate = expirationDate;
	activity.webpageURL = self.shareURL;

	[activity becomeCurrent:YES];
}

- (NSString *)identifier {
	return [Tone identifierWithArtist:self.artist album:self.album title:self.title duration:self.duration startTime:self.segment.startTime endTime:self.segment.endTime];
}

@end
