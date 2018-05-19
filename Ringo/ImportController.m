//
//  ImportController.m
//  Ringo
//
//  Created by Alexander Ivanov on 09.09.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import "ImportController.h"
#import "Ad.h"
#import "Push.h"
#import "AudioController+Import.h"
#import "AudioItem+Import.h"
#import "Global.h"
#import "Localized.h"
#import "TabBarController.h"
//#import "VKFeaturedController.h"

#import "NSRateController.h"
#import "NSURL+Convenience.h"
#import "UIBarButtonItem+Convenience.h"
//#import "VKHelper.h"

#import "CKDatabase+Convenience.h"
#import "NSArray+Convenience.h"
#import "NSAttributedString+Convenience.h"
#import "NSObject+Convenience.h"
#import "UIActivityIndicatorView+Convenience.h"
#import "UIAlertController+Convenience.h"
#import "UIApplication+Convenience.h"
#import "UIColor+Convenience.h"
#import "UITableView+Convenience.h"
#import "Dispatch+Convenience.h"
#import "MediaPlayer+Convenience.h"
#import "SafariServices+Convenience.h"
#import "UserNotifications+Convenience.h"

#import "NotificationService.h"

@import StoreKit;

#import <Crashlytics/Answers.h>

@interface ImportController ()
@property (strong, nonatomic) IBOutlet UIView *importView;

@property (strong, nonatomic, readonly) MPMediaPickerController *mediaPicker;
@property (strong, nonatomic, readonly) MPMusicPlayerController *musicPlayer;

@property (strong, nonatomic) AudioItem *nowPlayingItem;

@property (assign, nonatomic) BOOL playbackNotifications;

@property (assign, nonatomic) BOOL badge;
@end

@implementation ImportController

@synthesize importView = _importView;

__synthesize(MPMediaPickerController *, mediaPicker, ({ MPMediaPicker *x = [[MPMediaPicker alloc] initWithMediaTypes:MPMediaTypeMusic]; x.showsCloudItems = NO; __weak ImportController *__self = self; x.completion = ^(MPMediaPickerController *sender, MPMediaItemCollection *mediaItemCollection) { if (mediaItemCollection) [__self vkCreateTone:[AudioItem createWithMediaItem:mediaItemCollection.items.firstObject]]; }; x; }))

- (MPMusicPlayerController *)musicPlayer {
	return [SKCloudServiceController authorizationStatus] != SKCloudServiceAuthorizationStatusAuthorized ? Nil : [MPMusicPlayerController systemMusicPlayer];
}

- (void)setPlaybackNotifications:(BOOL)playbackNotifications {
	if (!self.musicPlayer)
		return;

	if (playbackNotifications && !_playbackNotifications) {
		[self.musicPlayer beginGeneratingPlaybackNotificationsForObserver:self selector:@selector(nowPlayingItemDidChange:)];

		_playbackNotifications = playbackNotifications;
	} else if (_playbackNotifications && !playbackNotifications) {
		[self.musicPlayer endGeneratingPlaybackNotificationsForObserver:self];

		_playbackNotifications = playbackNotifications;
	}
}

- (void)setBadge:(BOOL)badge {
	if (_badge == badge)
		return;

	_badge = badge;

	if (__screenshot)
		return;
	
	idx(self.navigationItem.leftBarButtonItems, 1).image = [UIImage templateImage:badge ? IMG_BELL_FULL : IMG_BELL_LINE];
	if (badge)
		[idx(self.navigationItem.leftBarButtonItems, 1).buttonView animate:CGAffineTransformMakeScale(0.0, 0.0) duration:1.0 damping:0.5 velocity:ANIMATION_VELOCITY options:ANIMATION_OPTIONS completion:Nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger numberOfRowsInSection = [super tableView:tableView numberOfRowsInSection:section];

	self.tableView.emptyState = numberOfRowsInSection <= 0 ? self.importView : Nil;
//	self.navigationController.navigationBar.translucent = numberOfRowsInSection;
//	self.navigationController.toolbar.translucent = numberOfRowsInSection;

	return numberOfRowsInSection;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
//	[self picker];

	[self.navigationController.toolbar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nowPlayingBarButtonItemAction:)]];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[[CKContainer defaultContainer] fetchUserRecordID:^(CKRecordID *recordID) {
		NSArray *subscriptions = [NSArray arrayWithObject:[defaults objectForKey:STR_SUBSCRIPTION_ID_TONE] ? Nil : [Tone subscription:recordID] withObject:[defaults objectForKey:STR_SUBSCRIPTION_ID_PUSH] ? Nil : [Push subscription] withObject:[defaults objectForKey:STR_SUBSCRIPTION_ID_AD] ? Nil : [Ad subscription]];
//		NSLog(@"subscriptions: %@", subscriptions);

		if (subscriptions.count)
			[[[CKContainer defaultContainer] publicCloudDatabase] modifySubscriptions:subscriptions completionHandler:^(NSArray<CKSubscription *> *savedSubscriptions, NSArray<NSString *> *deletedSubscriptionIDs) {
				NSArray<NSString *> *savedSubscriptionIDs = [savedSubscriptions map:^id(CKSubscription *obj) {
					return obj.subscriptionID;
				}];

				for (CKSubscription *subscription in savedSubscriptions)
					[defaults setObject:@YES forKey:subscription.subscriptionID];
				for (NSString *subscriptionID in deletedSubscriptionIDs)
					[defaults setObject:Nil forKey:subscriptionID];

				[Answers logCustomEventWithName:@"Modify Subscriptions" customAttributes:dic__(@"+", [savedSubscriptionIDs componentsJoinedByString:STR_COMMA], @"-", [deletedSubscriptionIDs componentsJoinedByString:STR_COMMA])];
			}];
	}];
/*
	[VKFeaturedController getPosts:^(NSInteger newPosts) {
		[GCD main:^{
			self.badge = [UIApplication sharedApplication].applicationIconBadgeNumber || newPosts;
		}];
	}];
*/}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	self.badge = [UIApplication sharedApplication].applicationIconBadgeNumber/* || [VKFeaturedController newPosts]*/;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[self nowPlayingItemDidChange:[NSNotification notificationWithName:STR_EMPTY object:self.musicPlayer]];
	self.playbackNotifications = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	self.playbackNotifications = NO;
	self.nowPlayingItem = Nil;
	[self setToolbar:Nil];
}

- (IBAction)nowPlayingItemDidChange:(NSNotification *)notification {
	if (!self.musicPlayer) {
		if (![self.toolbarItems.lastObject.title isEqualToString:[Localized allowMediaLibrary]]) {
			[self setToolbar:@[ [[UIBarButtonItem alloc] initWithImage:[UIImage templateImage:IMG_MUSIC_LINE] style:UIBarButtonItemStylePlain target:self action:@selector(nowPlayingBarButtonItemAction:)], [[UIBarButtonItem alloc] initWithTitle:[Localized allowMediaLibrary] style:UIBarButtonItemStylePlain target:self action:@selector(nowPlayingBarButtonItemAction:)] ]];

			[self.toolbarItems.firstObject.buttonView animate:CGAffineTransformMakeRotation(DEG_360 / 10) duration:1.0 damping:0.2 velocity:ANIMATION_VELOCITY options:ANIMATION_OPTIONS completion:Nil];
		}
	} else {
		[UNUserNotificationCenter getNotificationSettings:^(UNNotificationSettings *settings) {
			[GCD main:^{
				if (settings.authorization.boolValue) {
					MPMediaItem *mediaItem = cls(MPMusicPlayerController, notification.object).nowPlayingItem;

					if (mediaItem == Nil) {
//						[self setToolbar:[NSRateController instance].action ? Nil : @[ [[UIBarButtonItem alloc] initWithImage:[UIImage templateImage:IMG_HELP_LINE] style:UIBarButtonItemStylePlain target:self action:@selector(helpBarButtonItemAction:)], [[UIBarButtonItem alloc] initWithTitle:[Localized howToInstallToneToPhone] style:UIBarButtonItemStylePlain target:self action:@selector(helpBarButtonItemAction:)] ]];
						[self setToolbar:Nil];

						[self.toolbarItems.firstObject.buttonView animate:CGAffineTransformMakeScale(0.0, 0.0) duration:1.0 damping:0.5 velocity:ANIMATION_VELOCITY options:ANIMATION_OPTIONS completion:Nil];
					} else if (self.nowPlayingItem.mediaItem != mediaItem)
						self.nowPlayingItem = [AudioItem createWithMediaItem:mediaItem completion:^(UIImage *image) {
							[GCD main:^{
								if (self.nowPlayingItem)
									[self setToolbar:@[ [[UIBarButtonItem alloc] initWithImage:[[self.nowPlayingItem.image imageWithSize:CGSizeMake(30.0, 30.0) mode:UIImageScaleAspectFit] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(nowPlayingBarButtonItemAction:)], [[UIBarButtonItem alloc] initWithTitle:[self.nowPlayingItem description] style:UIBarButtonItemStylePlain target:self action:@selector(nowPlayingBarButtonItemAction:)] ]];
							}];
						}];
				} else {
					if (![self.toolbarItems.lastObject.title isEqualToString:[Localized allowNotifications]]) {
						[self setToolbar:@[ [[UIBarButtonItem alloc] initWithImage:[UIImage templateImage:IMG_BELL_LINE] style:UIBarButtonItemStylePlain target:self action:@selector(nowPlayingBarButtonItemAction:)], [[UIBarButtonItem alloc] initWithTitle:[Localized allowNotifications] style:UIBarButtonItemStylePlain target:self action:@selector(nowPlayingBarButtonItemAction:)] ]];

						[self.toolbarItems.firstObject.buttonView animate:CGAffineTransformMakeRotation(DEG_360 / 10) duration:1.0 damping:0.2 velocity:ANIMATION_VELOCITY options:ANIMATION_OPTIONS completion:Nil];
					}
				}
				
			}];
		}];
	}
}

- (IBAction)nowPlayingBarButtonItemAction:(UIBarButtonItem *)sender {
	if (!self.musicPlayer) {
		self.toolbarItems.firstObject.image = [UIImage templateImage:IMG_MUSIC_FULL];

		if ([SKCloudServiceController authorizationStatus] != SKCloudServiceAuthorizationStatusNotDetermined)
			[self presentAlertWithTitle:[Localized allowMediaLibrary] message:[Localized allowPlayMediaLibrary] cancelActionTitle:[Localized allow] destructiveActionTitle:Nil otherActionTitles:Nil configuration:^(UIAlertController *instance) {
				[instance.actions.firstObject setActionImage:[UIImage templateImage:IMG_MUSIC_LINE]];
				[instance.actions.firstObject setActionColor:GLOBAL.globalTintColor];

				[instance.actions.lastObject setActionColor:[UIColor color:HEX_IOS_DARK_GRAY]];
			} completion:^(UIAlertController *instance, NSInteger index) {
				[UIApplication openSettings];
			}];
		else
			[SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
				[GCD main:^{
					[self nowPlayingItemDidChange:[NSNotification notificationWithName:STR_EMPTY object:self.musicPlayer]];
				}];
			}];
	} else {
		[UNUserNotificationCenter getNotificationSettings:^(UNNotificationSettings *settings) {
			[GCD main:^{
				if (settings.authorization.boolValue) {
					NSTimeInterval duration = self.musicPlayer.nowPlayingItem.playbackDuration;
					NSTimeInterval startTime = self.musicPlayer.currentPlaybackTime;
					NSTimeInterval endTime = startTime + AUDIO_SEGMENT_LENGTH;
					if (duration > 0.0)
						endTime = fmin(endTime, duration);
					self.nowPlayingItem.segment = [[AudioSegment alloc] initWithStartTime:startTime endTime:endTime duration:duration];

					[self vkCreateTone:self.nowPlayingItem silent:NO];
				} else if (settings.authorization) {
					self.toolbarItems.firstObject.image = [UIImage templateImage:IMG_BELL_FULL];

					[self presentAlertWithTitle:[Localized allowNotifications] message:[Localized allowSendNotifications] cancelActionTitle:[Localized allow] destructiveActionTitle:Nil otherActionTitles:Nil configuration:^(UIAlertController *instance) {
						[instance.actions.firstObject setActionImage:[UIImage templateImage:IMG_BELL_LINE]];
						[instance.actions.firstObject setActionColor:GLOBAL.globalTintColor];

						[instance.actions.lastObject setActionColor:[UIColor color:HEX_IOS_DARK_GRAY]];
					} completion:^(UIAlertController *instance, NSInteger index) {
						[UIApplication openSettings];
					}];
				} else {
					self.toolbarItems.firstObject.image = [UIImage templateImage:IMG_BELL_FULL];

					[UNUserNotificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAll completionHandler:^(BOOL granted) {
						[GCD main:^{
							[self nowPlayingItemDidChange:[NSNotification notificationWithName:STR_EMPTY object:self.musicPlayer]];
						}];

						[Answers logCustomEventWithName:@"User Prompt" customAttributes:@{ @"Remote Notifications" : granted ? @"YES" : @"NO" }];
					}];
				}
			}];
		}];
	}
}

- (IBAction)helpBarButtonItemAction:(UIBarButtonItem *)sender {
//	[self performSegueWithIdentifier:GUI_HELP sender:sender];
	self.tabBarController.selectedIndex = TAB_HELP;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	[self nowPlayingItemDidChange:[NSNotification notificationWithName:STR_EMPTY object:self.musicPlayer]];

//	[Answers logCustomEventWithName:@"Remote Notification" customAttributes:@{ @"didRegisterForRemoteNotifications" : @"YES" }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	[error log:@"didFailToRegisterForRemoteNotificationsWithError:"];

//	[Answers logCustomEventWithName:@"Remote Notification" customAttributes:@{ @"didRegisterForRemoteNotifications" : [error debugDescription] ?: @"NO" }];
}

- (void)presentMediaPicker {
	SKCloudServiceAuthorizationStatus status = [SKCloudServiceController authorizationStatus];

	if (status == SKCloudServiceAuthorizationStatusAuthorized)
		[self presentViewController:self.mediaPicker animated:YES completion:Nil];
	else if (status == SKCloudServiceAuthorizationStatusNotDetermined)
		[SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
			[GCD main:^{
				[self nowPlayingItemDidChange:[NSNotification notificationWithName:STR_EMPTY object:self.musicPlayer]];
			}];

			if (self.mediaPicker)
				[self presentViewController:self.mediaPicker animated:YES completion:^{
				}];

			[Answers logCustomEventWithName:@"User Prompt" customAttributes:@ { @"Media Library" : status == SKCloudServiceAuthorizationStatusAuthorized ? @"YES" : @"NO" }];
		}];
	else
		[self presentAlertWithTitle:[Localized allowMediaLibrary] message:[Localized allowPlayMediaLibrary] cancelActionTitle:[Localized allow] destructiveActionTitle:Nil otherActionTitles:Nil configuration:^(UIAlertController *instance) {
			[instance.actions.firstObject setActionImage:[UIImage templateImage:IMG_MUSIC_LINE]];
			[instance.actions.firstObject setActionColor:GLOBAL.globalTintColor];

			[instance.actions.lastObject setActionColor:[UIColor color:HEX_IOS_DARK_GRAY]];
		} completion:^(UIAlertController *instance, NSInteger index) {
			[UIApplication openSettings];
		}];
}

- (IBAction)importButtonAction:(UIButton *)sender {
	[self presentMediaPicker];
}

- (IBAction)musicBarButtonItemAction:(UIBarButtonItem *)sender {
//	[self vkExportAudio:[AudioItem createWithURLAsset:[AVURLAsset assetWithURL:[[NSBundle mainBundle] URLForResource:@"sound" withExtension:@"m4a"]]]];

	[self presentMediaPicker];
}

- (IBAction)chartBarButtonItemAction:(UIBarButtonItem *)sender {
	[self performSegueWithIdentifier:/*GLOBAL.vkEnabled ? GUI_VK_CHARTS : */GUI_CHARTS sender:sender];
}

- (BOOL)openAudioItem:(AudioItem *)item {
	if (!item.artist.length || !item.title.length)
		return NO;

	[self dismissViewControllerAnimated:YES completion:Nil];

	[item lookupInMediaLibrary];
//	item.segment = [AudioSegment createWithDictionary:query];

	[self vkCreateTone:item];

	return YES;
}

- (BOOL)openURL:(NSURL *)url {
	NSDictionary *query = [[NSURL URLWithString:[NSAttributedString attributedStringWithHTMLString:url.absoluteString encoding:NSUnicodeStringEncoding].string] queryDictionary];

	return [self openAudioItem:[AudioItem createWithDictionary:query]];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
	if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb])
		return [self openURL:userActivity.webpageURL];

	if ([userActivity.activityType isEqualToString:STR_TONE])
		return [self openURL:userActivity.webpageURL];

	return NO;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
	id contentAvailable = notification.request.content.userInfo[@"aps"][@"content-available"];

	if (completionHandler)
		completionHandler([contentAvailable boolValue] ? UNNotificationPresentationOptionNone : UNNotificationPresentationOptionAll);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
	CKQueryNotification *query = [CKQueryNotification notificationFromRemoteNotificationDictionary:response.notification.request.content.userInfo];

	if (query) {
		if ([query.subscriptionID isEqualToString:STR_SUBSCRIPTION_ID_TONE])
			[self performSegueWithIdentifier:/*GLOBAL.vkEnabled ? GUI_VK_CHARTS : */GUI_CHARTS sender:query.recordID.recordName];
		else if ([query.subscriptionID isEqualToString:STR_SUBSCRIPTION_ID_PUSH])
			[Push loadByRecordID:query.recordID completion:^(Push *result) {
				[GCD main:^{
					[self openAudioItem:[AudioItem createWithTone:result.tone]];
				}];
			}];
		else if ([query.subscriptionID isEqualToString:STR_SUBSCRIPTION_ID_AD])
			[Ad loadByRecordID:query.recordID completion:^(Ad *result) {
				[GCD main:^{
					[self presentSafariWithURL:result.url];
				}];
			}];

		if (!response.notification.request.content.title)
			[Answers logCustomEventWithName:@"Remote Notification" customAttributes:@{ query.subscriptionID : query.alertLocalizationArgs ? [query.alertLocalizationArgs componentsJoinedByString:@" - "] : query.alertBody, @"databaseScope" : @(query.databaseScope), @"content-available" : @"NO" }];
	}

	if (completionHandler)
		completionHandler();
}

- (IBAction)select:(UIStoryboardSegue *)segue {
	[self performSelector:@selector(vkCreateTone:) withObject:ret(segue.sourceViewController, selectedItem) afterDelay:0.1];
}

- (IBAction)unwind:(UIStoryboardSegue *)segue {

}

- (IBAction)import:(UIStoryboardSegue *)segue {
	AudioItem *item = ret(segue.sourceViewController, selectedItem);
	if (!item)
		return;

	if (__screenshot) {
		[self setItems:@[ item ] animated:YES];

		return;
	}
	
	NSUInteger count = [self.tableView numberOfRowsInSection:self.tableView.lastSection];

	[self setItems:Nil animated:NO];

	NSURL *url = [item toneURL];
	if (!url)
		return;

	NSUInteger row = [self.items first:^BOOL(AudioItem *item) {
		return [item.assetURL.lastPathComponent isEqualToString:url.lastPathComponent];
	}];
	if (row == NSNotFound)
		return;

//	if (count == self.items.count)
//		[self.tableView reloadRow:row inSection:self.tableView.lastSection];
//	else
	if (self.items.count == count + 1) {
		NSUInteger numberOfSections = [self numberOfSectionsInTableView:self.tableView];
		[self.tableView beginUpdates];
		if (self.tableView.numberOfSections > numberOfSections)
			[self.tableView deleteSection:0];
		else if (self.tableView.numberOfSections < numberOfSections)
			[self.tableView insertSection:0];
		[self.tableView insertRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:numberOfSections - 1]];
		[self.tableView endUpdates];
	} else
		[self.tableView reloadData];
	
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:self.tableView.lastSection]];
}

- (void)createTone:(AudioItem *)item silent:(BOOL)silent {
	if (item.segment && silent)
		[self performSegueWithIdentifier:GUI_IMPORT sender:item];
	else
		[self performSegueWithIdentifier:GUI_TRIM sender:item];
}

- (void)vkCreateTone:(AudioItem *)item silent:(BOOL)silent {
	if (item.assetURL && !item.assetURL.isWebAddress) {
		[self createTone:item silent:silent];
/*	} else if ([[VKHelper instance] wakeUpSession] && GLOBAL.vkEnabled) {
		[self startActivityIndication:UIActivityIndicatorViewStyleWhiteLarge message:[Localized waiting]];
		
		[item lookupInVK:^(VKAudioItem *vkAudioItem) {
			if (vkAudioItem)
				[item.assetURL cache:^(NSURL *url) {
					[GCD main:^{
						[self stopActivityIndication];
						
						if (url)
							[self createTone:item silent:silent];
						else
							[self presentITunesStoreAlert:item];
					}];
				}];
			else
				[GCD main:^{
					[self stopActivityIndication];
					
					[self presentITunesStoreAlert:item];
				}];
		}];
*/	} else {
		[self presentITunesStoreAlert:item];
	}
}

- (void)vkCreateTone:(AudioItem *)item {
	[self vkCreateTone:item silent:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToAnyString:@[ GUI_IMPORT/*, GUI_VK_IMPORT*/, GUI_TRIM ]])
		[segue.destinationViewController forwardSelector:@selector(setSelectedItem:) withObject:sender nextTarget:UIViewControllerNextTarget(YES)];
	else if ([segue.identifier isEqualToAnyString:@[ GUI_CHARTS/*, GUI_VK_CHARTS*/ ]] && [sender isKindOfClass:[NSString class]])
		[segue.destinationViewController forwardSelector:@selector(setRecordName:) withObject:sender nextTarget:UIViewControllerNextTarget(YES)];
	else
		[super prepareForSegue:segue sender:sender];
}

@end
