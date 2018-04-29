//
//  AppDelegate.m
//  ringo
//
//  Created by Alexander Ivanov on 14.02.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <TwitterKit/TwitterKit.h>
//#import <VKSdk/VKSdk.h>

#import "AppDelegate.h"
#import "Global.h"

#import "NotificationService.h"

#import "UIViewController+Answers.h"
//#import "VKHelper.h"

#import "NSFileManager+iCloud.h"
#import "NSObject+Convenience.h"
#import "SKInAppPurchase.h"
#import "UIApplication+Convenience.h"
#import "UIViewController+Convenience.h"
#import "Dispatch+Convenience.h"
#import "UserNotifications+Convenience.h"

//#import "VKAPI.h"

//#import "CSSearchableIndex+Convenience.h"
//#import "GSTouchesShowingWindow.h"

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate
/*
- (GSTouchesShowingWindow *)window {
	static GSTouchesShowingWindow *window = Nil;
	if (!window)
		window = [[GSTouchesShowingWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	return window;
}
*/

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	return [self application:application openURL:url options:dic__(UIApplicationLaunchOptionsSourceApplicationKey, sourceApplication, UIApplicationLaunchOptionsAnnotationKey, annotation)];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
	NSString *sourceApplication = options[UIApplicationLaunchOptionsSourceApplicationKey];
	id annotation = options[UIApplicationLaunchOptionsAnnotationKey];

	if ([[FBSDKApplicationDelegate sharedInstance] application:app openURL:url sourceApplication:sourceApplication annotation:annotation])
		return YES;

	if ([[Twitter sharedInstance] application:app openURL:url options:options])
		return YES;

/*	if ([VKSdk processOpenURL:url fromApplication:sourceApplication])
		return YES;
*/
	return [[[app.rootViewController presentRootViewController] forwardSelector:@selector(openURL:) withObject:url nextTarget:UIViewControllerNextTarget(YES)] boolValue];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.

//	[[CSSearchableIndex defaultSearchableIndex] deleteAllSearchableItems];

	[GLOBAL fetchVKEnabled:^(BOOL reload) {
		if (!reload)
			return;
		
		UIViewController *vc = application.rootViewController.lastViewController;
		UITableView *tableView = cls(UITableViewController, vc).tableView;
		if (!tableView)
			return;
		
		[GCD main:^{
			[tableView reloadData];
		}];
	}];

	[Fabric with:@[ [Crashlytics class] ]];
	
	[[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];

	[[Twitter sharedInstance] startWithConsumerKey:@"auVb4jBeyTcvYOdJieWWe9l5x" consumerSecret:@"NhWbMXQEX1SJjR2vnBAcpTMfv03p9kqzWkxxr7GPLDGhoyT9r2"];

//	[VKHelper initializeWithAppId:GLOBAL.vkEnabled ? GLOBAL.vkAppId : VK_APP_ID apiVersion:GLOBAL.vkVersion permissions:VK_PERMISSIONS];

//	[[Crashlytics sharedInstance] setUserIdentifier:[[VKHelper instance] wakeUpSession].userId];
/*
	if (GLOBAL.vkEnabled) {
		[VKAPI api].version = GLOBAL.vkVersion;
		[VKAPI api].userAgent = GLOBAL.vkUserAgent;
	}
*/
	[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:Nil handler:Nil];
	
	[application registerForRemoteNotifications];

	[UNUserNotificationCenter setDelegate:self];
	
	[GLOBAL update];
	
	[SKInAppPurchase purchasesWithProductIdentifiers:IAP_IDS];

//	NSLog(@"documents: %@", [NSFileManager URLForDirectory:NSDocumentDirectory]);
//	[[NSFileManager URLForDirectory:NSCachesDirectory] clearDirectory];

	return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@", deviceToken);

	[application.rootViewController forwardSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:) withObject:application withObject:deviceToken nextTarget:UIViewControllerNextTarget(YES)];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error);

	[application.rootViewController forwardSelector:@selector(application:didFailToRegisterForRemoteNotificationsWithError:) withObject:application withObject:error nextTarget:UIViewControllerNextTarget(YES)];
}

- (BOOL)application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType {
	return [[[application.rootViewController presentRootViewController] forwardSelector:@selector(application:willContinueUserActivityWithType:) withObject:application withObject:userActivityType nextTarget:UIViewControllerNextTarget(YES)] boolValue];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
	return [[application.rootViewController forwardSelector:@selector(application:continueUserActivity:restorationHandler:) withObject:application withObject:userActivity withObject:restorationHandler nextTarget:UIViewControllerNextTarget(YES)] boolValue];
}

- (void)application:(UIApplication *)application didFailToContinueUserActivityWithType:(NSString *)userActivityType error:(NSError *)error {
	[error log:@"didFailToContinueUserActivityWithType:"];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[Answers logCustomEventWithName:@"Memory Warning" customAttributes:@{ @"VC" : [[application.rootViewController.lastViewController class] description], @"model" : [UIDevice currentDevice].model, @"version" : [UIDevice currentDevice].systemVersion }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	
	[application.rootViewController.lastViewController forwardSelector:@selector(endLogging) nextTarget:Nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	
	[application.rootViewController.lastViewController forwardSelector:@selector(startLogging) nextTarget:Nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	
	[FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
	[[UIApplication sharedApplication].rootViewController.lastViewController forwardSelector:@selector(userNotificationCenter:willPresentNotification:withCompletionHandler:) withObject:center withObject:notification withObject:completionHandler nextTarget:Nil];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
	[[[UIApplication sharedApplication].rootViewController presentRootViewController] forwardSelector:@selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:) withObject:center withObject:response withObject:completionHandler nextTarget:Nil];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	NotificationService *service = [NotificationService new];
	[UIApplication performBackgroundTaskWithName:@"Remote Notification" handler:^{
		[service application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
	} expirationHandler:^{
		[service serviceExtensionTimeWillExpire];
	}];

	NSLog(@"application:didReceiveRemoteNotification:fetchCompletionHandler: %@", userInfo);
}

@end
