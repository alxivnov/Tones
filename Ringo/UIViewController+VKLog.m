//
//  UIViewController+VKLog.m
//  Ringtonic
//
//  Created by Alexander Ivanov on 04.12.16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import "UIViewController+VKLog.h"

#import "User.h"

#import <Crashlytics/Answers.h>

@implementation UIViewController (VKLog)

- (void)vkLog:(VKAccessToken *)newToken {
	[[CKContainer defaultContainer] fetchUserRecordID:^(CKRecordID *recordID) {
		[User query:[NSPredicate predicateWithCreatorUserRecordID:recordID] completion:^(NSArray<User *> *results) {
//			[[Crashlytics sharedInstance] setUserIdentifier:newToken.userId];

			if (results.firstObject.vkUserID)
				[Answers logLoginWithMethod:@"VK" success:@(newToken != Nil) customAttributes:dic__(@"VC", [[self class] description], @"VK", newToken.userId)];
			else
				[Answers logSignUpWithMethod:@"VK" success:@(newToken != Nil) customAttributes:dic__(@"VC", [[self class] description], @"VK", newToken.userId)];

			if ([newToken.userId integerValue] > 0) {
				User *user = results.count ? results.firstObject : [User new];
				user.vkUserID = [newToken.userId integerValue];
				[user update:Nil];
			}
		}];
	}];
}

- (void)vkLogReceivedNewToken:(VKAccessToken *)newToken {
	[self vkLog:newToken];

	NSLog(@"VK token: %@", newToken);
}

- (void)vkLogUserDeniedAccess:(VKError *)authorizationError {
	[self vkLog:Nil];

	NSLog(@"VK error: %@", authorizationError);
}

@end
