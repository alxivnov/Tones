//
//  Push.m
//  Ringtonic
//
//  Created by Alexander Ivanov on 09/06/16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import "Push.h"
#import "Localized.h"

#import "NSObject+Convenience.h"

#define FIELD_STATE @"state"

@implementation Push

- (instancetype)initWithRecordFields:(NSDictionary *)dictionary {
	self = [super initWithRecordFields:dictionary];

	if (self) {
		self.state = [dictionary[FIELD_STATE] integerValue];

		self.artist = dictionary[FIELD_ARTIST];
		self.title = dictionary[FIELD_TITLE];
	}

	return self;
}

- (NSDictionary *)recordFields {
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:3];

	dictionary[FIELD_STATE] = @(self.state);

	dictionary[TYPE_TONE] = [self.tone reference:CKReferenceActionDeleteSelf];

	dictionary[FIELD_ARTIST] = self.tone.artist;
	dictionary[FIELD_TITLE] = self.tone.title;

	return dictionary;
}

- (NSString *)recordName {
	return [[NSArray arrayWithObject:[[self class] description] withObject:[self.tone recordName]] componentsJoinedByString:STR_PLUS];
}

- (void)load:(void (^)(void))completion {
	CKReference *reference = [self.record objectForKey:TYPE_TONE];

	[Tone findByRecordID:reference.recordID completion:^(__kindof CKObjectBase *result) {
		self.tone = result;

//		__weak Featured *__self = self;
		if (completion)
			completion(/*__self*/);
	}];
}

+ (instancetype)createWithTone:(Tone *)tone {
	Push *push = [self new];
	push.tone = tone;
	return push;
}

+ (NSPredicate *)subscriptionPredicate {
	return [NSPredicate predicateWithKey:FIELD_STATE greaterThan:@0];
}

+ (CKSubscription *)subscription {
	CKNotificationInfo *notificationInfo = [CKNotificationInfo new];
	notificationInfo.soundName = CKNotificationInfoSoundNameDefault;

	notificationInfo.alertLocalizationKey = [Localized newToneIsAvailableWithArgs];
	notificationInfo.alertLocalizationArgs = @[ FIELD_ARTIST, FIELD_TITLE ];

	notificationInfo.shouldSendContentAvailable = YES;

	if (@available(iOS 11.0, *))
		notificationInfo.shouldSendMutableContent = YES;

	NSPredicate *predicate = [self subscriptionPredicate];
	return [self subscriptionWithPredicate:predicate ID:STR_SUBSCRIPTION_ID_PUSH options:CKQuerySubscriptionOptionsFiresOnRecordUpdate notificationInfo:notificationInfo];
}

- (NSString *)description {
	return self.title;
}

@end
