//
//  NotificationService.m
//  Notification Service Extension
//
//  Created by Alexander Ivanov on 11.11.16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import "NotificationService.h"
#import "Global.h"
#import "Localized.h"
#import "Ad.h"
#import "Push.h"
#import "Tone.h"
#import "User.h"

#import "VKHelper.h"

#import "Affiliates+Convenience.h"
#import "UserNotifications+Convenience.h"

#import <Crashlytics/Answers.h>

#define SEPARATOR @" - "

@import CloudKit;

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	id nid = userInfo[@"ck"][@"nid"];
	id rid = userInfo[@"ck"][@"qry"][@"rid"];

	self.contentHandler = ^(UNNotificationContent *contentToDeliver) {
		[contentToDeliver scheduleWithIdentifier:rid completion:^(BOOL success) {
			if (success)
				[UNUserNotificationCenter getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> *notifications) {
					notifications = [notifications query:^BOOL(UNNotification *obj) {
						return ![obj.request.identifier isEqualToString:rid] && [obj.request.content.userInfo[@"ck"][@"nid"] isEqualToString:nid];
					}];

					[UNUserNotificationCenter removeDeliveredNotificationWithIdentifier:notifications.firstObject.request.identifier];
				}];

			if (completionHandler)
				completionHandler(UIBackgroundFetchResultNewData);
		}];
	};

	self.bestAttemptContent = [UNMutableNotificationContent new];
	self.bestAttemptContent.body = [NSString stringWithLocalizedFormat:userInfo[@"aps"][@"alert"][@"loc-key"] arguments:userInfo[@"aps"][@"alert"][@"loc-args"]];
	self.bestAttemptContent.badge = userInfo[@"aps"][@"badge"];
	self.bestAttemptContent.sound = [UNNotificationSound defaultSound];
	self.bestAttemptContent.userInfo = [userInfo dictionaryWithValuesForKeys:@[ @"ck" ]];

	[self process:userInfo completionHandler:^{
		self.contentHandler(self.bestAttemptContent);
	}];

	CKQueryNotification *query = [CKQueryNotification notificationFromRemoteNotificationDictionary:userInfo];
	if (query)
		[Answers logCustomEventWithName:@"Remote Notification" customAttributes:@{ query.subscriptionID : query.alertLocalizationArgs ? [query.alertLocalizationArgs componentsJoinedByString:@" - "] : query.alertBody, @"databaseScope" : @(query.databaseScope), @"applicationState" : @([UIApplication sharedApplication].applicationState), @"content-available" : @"YES" }];
}

- (void)process:(NSDictionary *)userInfo completionHandler:(void (^)(void))completionHandler {
//	NSMutableDictionary *dic = [userInfo mutableCopy];
//	dic[@"aps"] = Nil;

	CKQueryNotification *notification = [CKQueryNotification notificationFromRemoteNotificationDictionary:userInfo];
	if ([notification.subscriptionID isEqualToString:STR_SUBSCRIPTION_ID_TONE]) {
		self.bestAttemptContent.title = [Localized somebodyUsedYourTone:Nil];
		self.bestAttemptContent.body = [notification.alertLocalizationArgs componentsJoinedByString:SEPARATOR];

		[Tone loadByRecordID:notification.recordID completion:^(Tone *tone) {
			self.bestAttemptContent.body = tone.description;

			[User query:[NSPredicate predicateWithCreatorUserRecordID:tone.record.lastModifiedUserRecordID] completion:^(NSArray<User *> *users) {
				self.bestAttemptContent.title = [Localized somebodyUsedYourTone:users.firstObject.title];

				[VKHelper getUsers:@[ @(users.firstObject.vkUserID) ] fields:@[ VK_PARAM_SEX ] handler:^(NSArray<VKUser *> *vkUsers) {
					if (vkUsers.count)
						self.bestAttemptContent.title = [Localized userUsedYourTone:[vkUsers.firstObject fullName] sex:vkUsers.firstObject.sex.unsignedIntegerValue];

					if (tone.description.length)
						[AFMediaItem search:tone.description handler:^(NSArray<AFMediaItem *> *results) {
							[results.firstObject.artworkUrl100 cache:^(NSURL *url) {
								self.bestAttemptContent.attachments = arr_([UNNotificationAttachment attachmentWithURL:url]);

								completionHandler();
							}];
						}];
					else
						completionHandler();
				}];
			}];
		}];
	} else if ([notification.subscriptionID isEqualToString:STR_SUBSCRIPTION_ID_PUSH]) {
		self.bestAttemptContent.title = [Localized newToneIsAvailable];
		self.bestAttemptContent.body = [notification.alertLocalizationArgs componentsJoinedByString:SEPARATOR];

		[Push loadByRecordID:notification.recordID completion:^(Push *push) {
			self.bestAttemptContent.body = push.tone.description;

			if (push.tone.description.length)
				[AFMediaItem search:push.tone.description handler:^(NSArray<AFMediaItem *> *results) {
					[results.firstObject.artworkUrl100 cache:^(NSURL *url) {
						self.bestAttemptContent.attachments = arr_([UNNotificationAttachment attachmentWithURL:url]);

						completionHandler();
					}];
				}];
			else
				completionHandler();
		}];
	} else if ([notification.subscriptionID isEqualToString:STR_SUBSCRIPTION_ID_AD]) {
//		self.bestAttemptContent.title = notification.alertLocalizationArgs.firstObject;

		[Ad loadByRecordID:notification.recordID completion:^(Ad *ad) {
			self.bestAttemptContent.title = ad.title;
			self.bestAttemptContent.body = ad.message;

			completionHandler();
		}];
	}
}

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
/*
    // Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    
    self.contentHandler(self.bestAttemptContent);
*/


	[self process:request.content.userInfo completionHandler:^{
		self.contentHandler(self.bestAttemptContent);
	}];
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
