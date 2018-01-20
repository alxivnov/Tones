//
//  Tone.m
//  Ringo
//
//  Created by Alexander Ivanov on 27.06.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import "Tone.h"
#import "Localized.h"

#import "CommonCrypto+Convenience.h"
#import "CKDatabase+Convenience.h"
#import "NSBundle+Convenience.h"

#define FIELD_START_TIME @"start_time"
#define FIELD_END_TIME @"end_time"

#define FIELD_IMPORT_COUNT @"import_count"
#define FIELD_EXPORT_COUNT @"export_count"
#define FIELD_LOCALIZATION @"localization"

@import CloudKit;

@implementation Tone

+ (NSString *)identifierWithArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title duration:(NSTimeInterval)duration startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime {
	NSArray *array = @[ title ? title.lowercaseString : STR_EMPTY,
						album ? album.lowercaseString : STR_EMPTY,
						artist ? artist.lowercaseString : STR_EMPTY,
						@(round(duration)),
						@(round(startTime * 4)),
						@(round(endTime * 4)) ];
	NSString *description = [array componentsJoinedByString:STR_NEW_LINE];
	NSData *data = [description dataUsingEncoding:NSUnicodeStringEncoding];
	NSData *hash = [data hash:MD5];
	NSUUID *uuid = [[NSUUID alloc] initWithUUIDBytes:hash.bytes];
	return uuid.UUIDString;
}

- (instancetype)initWithRecordFields:(NSDictionary *)dictionary {
	self = [super initWithRecordFields:dictionary];
	
	if (self) {
		self.title = dictionary[FIELD_TITLE];
		self.album = dictionary[FIELD_ALBUM];
		self.artist = dictionary[FIELD_ARTIST];
		self.duration = [dictionary[FIELD_DURATION] doubleValue];

		self.startTime = [dictionary[FIELD_START_TIME] doubleValue];
		self.endTime = [dictionary[FIELD_END_TIME] doubleValue];

		self.importCount = [dictionary[FIELD_IMPORT_COUNT] unsignedIntegerValue];
		self.exportCount = [dictionary[FIELD_EXPORT_COUNT] unsignedIntegerValue];
		self.localization = dictionary[FIELD_LOCALIZATION];
	}
	
	return self;
}

- (NSDictionary *)recordFields {
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:9];

	[dictionary setValue:self.title forKey:FIELD_TITLE];
	[dictionary setValue:self.album forKey:FIELD_ALBUM];
	[dictionary setValue:self.artist forKey:FIELD_ARTIST];
	[dictionary setValue:@(self.duration) forKey:FIELD_DURATION];

	[dictionary setValue:@(self.startTime) forKey:FIELD_START_TIME];
	[dictionary setValue:@(self.endTime) forKey:FIELD_END_TIME];

	[dictionary setValue:@(self.importCount) forKey:FIELD_IMPORT_COUNT];
	[dictionary setValue:@(self.exportCount) forKey:FIELD_EXPORT_COUNT];

	[dictionary setValue:self.localization forKey:FIELD_LOCALIZATION];

	return dictionary;
}

- (NSString *)recordName {
	return [[self class] identifierWithArtist:self.artist album:self.album title:self.title duration:self.duration startTime:self.startTime endTime:self.endTime];
}

+ (instancetype)createWithArtist:(NSString *)artist title:(NSString *)title startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime {
	if (!artist.length || !title.length)
		return Nil;

	Tone *instance = [Tone new];
	instance.title = title;
	instance.artist = artist;
	instance.startTime = startTime;
	instance.endTime = endTime;

	instance.localization = [NSBundle mainLocalization];
	return instance;
}

+ (CKQueryOperation *)loadWithArtist:(NSString *)artist title:(NSString *)title completion:(void (^)(NSArray<__kindof Tone *> *))completion {
	NSPredicate *predicate = [NSPredicate predicateWithKeys:@{ FIELD_ARTIST : artist ? artist : STR_EMPTY, FIELD_TITLE : title ? title : STR_EMPTY }];
	return [self query:predicate completion:completion];
}

+ (CKQueryOperation *)loadFeatured:(NSArray<NSString *> *)localizations resultsLimit:(NSUInteger)resultsLimit completion:(void (^)(NSArray<__kindof Tone *> *))completion {
	NSPredicate *predicate = localizations.count ? [NSPredicate predicateWithKey:FIELD_LOCALIZATION values:localizations] : Nil;
	return [self query:predicate sortDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:FIELD_EXPORT_COUNT ascending:NO] ] resultsLimit:resultsLimit completion:completion];
}

+ (CKQueryOperation *)loadRecent:(NSArray<NSString *> *)localizations resultsLimit:(NSUInteger)resultsLimit completion:(void (^)(NSArray<__kindof Tone *> *))completion {
	NSPredicate *predicate = localizations.count ? [NSPredicate predicateWithKey:FIELD_LOCALIZATION values:localizations] : Nil;
	return [self query:predicate sortDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:KEY_CREATION_DATE ascending:NO] ] resultsLimit:resultsLimit completion:completion];
}

+ (void)loadProfile:(void (^)(NSArray<__kindof Tone *> *))completion {
	[[CKContainer defaultContainer] fetchUserRecordID:^(CKRecordID *recordID) {
		NSPredicate *predicate = [NSPredicate predicateWithCreatorUserRecordID:recordID];
		[self query:predicate sortDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:FIELD_EXPORT_COUNT ascending:NO] ] completion:completion];
	}];
}

- (void)deleteFromPublicCloudDatabase:(void (^)(BOOL))completion {
	[[[CKContainer defaultContainer] publicCloudDatabase] deleteRecordWithID:self.record.recordID completionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
		[error log:@"deleteRecordWithID:"];
		
		if (completion)
			completion([recordID.recordName isEqualToString:self.record.recordID.recordName]);
	}];
}

- (NSComparisonResult)compare:(Tone *)otherTone {
	return [@(otherTone.exportCount) compare:@(self.exportCount)];
}

- (NSString *)description {
	return self.artist.length && self.title.length ? [@[ self.artist, STR_HYPHEN, self.title ] componentsJoinedByString:STR_SPACE] : self.artist.length ? self.artist : self.title.length ? self.title : STR_EMPTY;
}

- (NSString *)debugDescription {
	return [NSString stringWithFormat:@"%@: %@", self.record.recordID.recordName, self.description];
}

+ (NSPredicate *)subscriptionPredicate:(CKRecordID *)recordID {
	return [NSPredicate predicateWithCreatorUserRecordID:recordID];
}

+ (CKSubscription *)subscription:(CKRecordID *)recordID {
//	[[CKContainer defaultContainer].publicCloudDatabase fetchSubscriptionsWithIDs:Nil completionHandler:^(NSDictionary<NSString *,CKSubscription *> *subscriptionsBySubscriptionID, NSError *operationError) {
//		[operationError log:@"fetchSubscriptionsWithIDs:"];

//		if (subscriptionsBySubscriptionID.count)
//			return;

		CKNotificationInfo *notificationInfo = [CKNotificationInfo new];
		notificationInfo.soundName = CKNotificationInfoSoundNameDefault;

		notificationInfo.alertLocalizationKey = [Localized somebodyUsedYourToneWithArgs];
		notificationInfo.alertLocalizationArgs = @[ FIELD_ARTIST, FIELD_TITLE ];

		notificationInfo.shouldBadge = YES;
//		notificationInfo.desiredKeys = @[ TYPE_TONE ];

		notificationInfo.shouldSendContentAvailable = YES;

		if (@available(iOS 11.0, *))
			notificationInfo.shouldSendMutableContent = YES;

		NSPredicate *predicate = [self subscriptionPredicate:recordID];
		return [self subscriptionWithPredicate:predicate ID:STR_SUBSCRIPTION_ID_TONE options:CKQuerySubscriptionOptionsFiresOnRecordUpdate notificationInfo:notificationInfo];
//	}];
}

@end
