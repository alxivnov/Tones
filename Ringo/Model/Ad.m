//
//  Ad.m
//  Ringtonic
//
//  Created by Alexander Ivanov on 09/06/16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import "Ad.h"

#define FIELD_URL @"url"

#define FIELD_TITLE @"title"
#define FIELD_MESSAGE @"message"

#define FIELD_STATE @"state"

@implementation Ad

- (instancetype)initWithRecordFields:(NSDictionary *)dictionary {
	self = [super initWithRecordFields:dictionary];

	if (self) {
		self.state = [dictionary[FIELD_STATE] integerValue];

		self.url = [NSURL URLWithString:dictionary[FIELD_URL]];

		self.title = dictionary[FIELD_TITLE];
		self.message = dictionary[FIELD_MESSAGE];
	}

	return self;
}

- (NSDictionary *)recordFields {
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:3];

	dictionary[FIELD_STATE] = @(self.state);

	dictionary[FIELD_URL] = self.url.absoluteString;

	dictionary[FIELD_TITLE] = self.title;
	dictionary[FIELD_MESSAGE] = self.message;

	return dictionary;
}

+ (NSPredicate *)subscriptionPredicate {
	return [NSPredicate predicateWithKey:FIELD_STATE greaterThan:@0];
}

+ (CKSubscription *)subscription {
	CKNotificationInfo *notificationInfo = [CKNotificationInfo new];
	notificationInfo.soundName = CKNotificationInfoSoundNameDefault;

	notificationInfo.alertLocalizationKey = @"%1$@";
	notificationInfo.alertLocalizationArgs = @[ FIELD_TITLE ];

	notificationInfo.shouldSendContentAvailable = YES;

	if (@available(iOS 11.0, *))
		notificationInfo.shouldSendMutableContent = YES;

	NSPredicate *predicate = [self subscriptionPredicate];
	return [self subscriptionWithPredicate:predicate ID:STR_SUBSCRIPTION_ID_AD options:CKQuerySubscriptionOptionsFiresOnRecordUpdate notificationInfo:notificationInfo];
}

- (NSString *)description {
	return self.title;
}

@end
