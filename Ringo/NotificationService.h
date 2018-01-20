//
//  NotificationService.h
//  Notification Service Extension
//
//  Created by Alexander Ivanov on 11.11.16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>

#import <UIKit/UIKit.h>

@interface NotificationService : UNNotificationServiceExtension

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;

@end
