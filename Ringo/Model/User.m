//
//  User.m
//  Ringtonic
//
//  Created by Alexander Ivanov on 03.08.16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import "User.h"

#define FIELD_TITLE @"title"
#define FIELD_VK_USER_ID @"vk_user_id"

@implementation User

- (instancetype)initWithRecordFields:(NSDictionary *)dictionary {
	self = [super initWithRecordFields:dictionary];

	if (self) {
		self.title = dictionary[FIELD_TITLE];
		self.vkUserID = [dictionary[FIELD_VK_USER_ID] integerValue];
	}

	return self;
}

- (NSDictionary *)recordFields {
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:3];

	dictionary[FIELD_TITLE] = self.title;
	dictionary[FIELD_VK_USER_ID] = @(self.vkUserID);

	return dictionary;
}

- (NSString *)description {
	return self.title;
}

@end
