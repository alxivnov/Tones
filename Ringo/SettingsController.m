//
//  SettingsController.m
//  Ringo
//
//  Created by Alexander Ivanov on 16.08.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import "SettingsController.h"
#import "Global.h"
#import "Localized.h"
//#import "UIViewController+VKLog.h"

#import "UIRateController+Answers.h"
#import "UIViewController+Answers.h"
#import "UIViewController+Stereo.h"

#import "Affiliates+Convenience.h"
#import "Dispatch+Convenience.h"
#import "MessageUI+Convenience.h"
#import "SafariServices+Convenience.h"
#import "StoreKit+Convenience.h"
#import "NSBundle+Convenience.h"
#import "NSObject+Convenience.h"
#import "SKInAppPurchase.h"
#import "UIActivityViewController+Convenience.h"
#import "UINavigationController+Convenience.h"
#import "UITableView+Convenience.h"
#import "UITableViewCell+Convenience.h"
#import "FBSDKShareKit+Convenience.h"
#import "UIView+Convenience.h"

//#import "VKHelper.h"

#import "Ad.h"
#import "Push.h"
#import "Tone.h"
#import "User.h"

#import <Crashlytics/Answers.h>

#define URL_FB_APP_LINK @"http://apptag.me/tones/"//@"https://fb.me/1834277420229702"
#define URL_FB_PREVIEW_IMAGE @"http://apptag.me/tones/ringtonic.jpg"

#define IDX_APPS 5
#define DEV_ID 734258593

@interface SettingsController ()
@property (assign, nonatomic) NSUInteger vkEnabled;

@property (weak, nonatomic) IBOutlet UISwitch *waveformSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *toneSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *pushSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *adSwitch;

@property (strong, nonatomic) NSArray<AFMediaItem *> *apps;
@end

@implementation SettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;

	[[self class] query];

	NSURL *url = [[NSFileManager URLForDirectory:NSCachesDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%ul.plist", DEV_ID]];
	self.apps = [[NSArray arrayWithContentsOfURL:url] map:^id(id obj) {
		return [[AFMediaItem alloc] initWithDictionary:obj];
	}];

	[AFMediaItem lookup:@{ KEY_ID : @(DEV_ID), KEY_MEDIA : kMediaSoftware, KEY_ENTITY : kEntitySoftware } handler:^(NSArray<AFMediaItem *> *results) {
		self.apps = [results query:^BOOL(AFMediaItem *obj) {
			return [obj.wrapperType isEqualToString:kMediaSoftware] && obj.trackId.unsignedIntegerValue != APP_ID_RINGO;
		}];
		[[self.apps map:^id(AFMediaItem *obj) {
			return obj.dictionary;
		}] writeToURL:url];

		if (self.apps.count)
			[GCD main:^{
				if (self.tableView.numberOfSections > IDX_APPS)
					[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:IDX_APPS] withRowAnimation:UITableViewRowAnimationAutomatic];
				else
					[self.tableView insertSections:[NSIndexSet indexSetWithIndex:IDX_APPS] withRowAnimation:UITableViewRowAnimationAutomatic];
			}];
	}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)loggingName {
	return @"Settings";
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self startLogging];

	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:NSIndexPathMake(0, 0)];
	cell.detailTextLabel.text = [NSBundle bundleShortVersionString];

//	[self setup:Nil];



	UITableViewCell *community = [self.tableView cellForRowAtIndexPath:NSIndexPathMake(0, 2)];
	if (community) {
		community.textLabel.text = [Localized openCommunity];
		community.detailTextLabel.text = STR_SPACE;//[@(VK_GROUP_ID) description];
		[community.imageView setImage:[UIImage originalImage:IMG_USERS_LINE]];
		[community.imageView setHighlightedImage:[UIImage originalImage:IMG_USERS_FULL]];
	}

	[self productsRequest:Nil didReceiveResponse:Nil];



	[[self.tableView cellForRowAtIndexPath:NSIndexPathMake(1, 0)].imageView animate:CGAffineTransformMakeRotation(DEG_360 / 4) duration:1.25 damping:0.1 velocity:ANIMATION_VELOCITY options:ANIMATION_OPTIONS completion:Nil];



	[[[CKContainer defaultContainer] publicCloudDatabase] fetchSubscriptionsWithIDs:@[ STR_SUBSCRIPTION_ID_TONE, STR_SUBSCRIPTION_ID_PUSH, STR_SUBSCRIPTION_ID_AD ] completionHandler:^(NSDictionary<NSString *,CKSubscription *> *subscriptionsBySubscriptionID, NSError *operationError) {
		[GCD main:^{
			self.toneSwitch.on = subscriptionsBySubscriptionID[STR_SUBSCRIPTION_ID_TONE] != Nil;
			self.pushSwitch.on = subscriptionsBySubscriptionID[STR_SUBSCRIPTION_ID_PUSH] != Nil;
			self.adSwitch.on = subscriptionsBySubscriptionID[STR_SUBSCRIPTION_ID_AD] != Nil;
		}];

		for (NSString *subscriptionID in subscriptionsBySubscriptionID)
			[[NSUserDefaults standardUserDefaults] setObject:@YES forKey:subscriptionID];

		[operationError log:@"fetchSubscriptionsWithIDs:"];
	}];

	if (IS_DEBUGGING)
		[self.tableView cellForRowAtIndexPath:NSIndexPathMake(0, 1)].accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)setupInAppPurchase {
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:NSIndexPathMake(1, 0)];

	SKInAppPurchase *purchase = [SKInAppPurchase purchaseWithProductIdentifier:GLOBAL.purchaseID];

	if (purchase.localizedTitle)
		cell.textLabel.text = purchase.localizedTitle;

	if (purchase.purchased)
		cell.detailTextLabel.text = [Localized purchased];
	else if (purchase.localizedPrice)
		cell.detailTextLabel.text = purchase.localizedPrice;

	if (purchase.localizedDescription)
		[self.tableView setFooterText:purchase.localizedDescription forSection:1];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
	[self setupInAppPurchase];
}

- (void)requestDidFinish:(SKRequest *)request {
	[self setupInAppPurchase];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
	[self setupInAppPurchase];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[self endLogging];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return IS_DEBUGGING ? 8 : 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return section == 1 ? 2 : section == IDX_APPS ? self.apps.count : section == 7 ? 3 : 1;
//	return [super tableView:tableView numberOfRowsInSection:section] - (!section && !GLOBAL.vkEnabled ? 2 : 0);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return section == 0 ? loc(@"About") : section == 1 ? loc(@"Stereo") : section == 2 ? loc(@"Feedback") : section == 3 ? loc(@"Share") : section == 4 ? loc(@"Rate") : section == IDX_APPS ? loc(@"Apps") : section == 6 ? loc(@"GUI") : section == 7 ? loc(@"Notifications") : Nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	//	return !section && GLOBAL.vkEnabled && ![VKSdk isLoggedIn] ? [Localized logInToGetAccess] : [super tableView:tableView titleForFooterInSection:section];
	return Nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indexPath.section == 5 ? [NSString stringWithFormat:@"%ld", indexPath.section] : [NSString stringWithFormat:@"%ld%ld", indexPath.section, indexPath.row] forIndexPath:indexPath];

	if (indexPath.section == IDX_APPS) {
		AFMediaItem *app = self.apps[indexPath.row];

		NSArray *titles = [app.trackName componentsSeparatedByString:@" - "];
		cell.textLabel.text = titles.count > 1 ? titles.firstObject : app.trackName;
		cell.detailTextLabel.text = titles.count > 1 ? titles.lastObject : [app.dictionary[@"genres"] firstObject];
/*		if (URL_CACHE(app.artworkUrl100).isExistingFile)
			cell.imageView.image = [[UIImage image:URL_CACHE(app.artworkUrl100)] imageWithSize:CGSizeMake(30.0, 30.0) mode:UIImageScaleAspectFit];
		else
*/			[app.artworkUrl100 cache:^(NSURL *url) {
				[GCD main:^{
					cell.imageView.image = [[UIImage image:url] imageWithSize:CGSizeMake(30.0, 30.0) mode:UIImageScaleAspectFit];
				}];
			}];
	} else if (indexPath.section == 6 && indexPath.row == 0) {
		self.waveformSwitch = cell.accessorySwitch;
		[self.waveformSwitch addTarget:self action:@selector(waveformSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
		self.waveformSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:STR_LOGARITHMIC_WAVEFORM];
	} else if (indexPath.section == 7 && indexPath.row == 0) {
		self.toneSwitch = cell.accessorySwitch;
		[self.toneSwitch addTarget:self action:@selector(toneSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
		self.toneSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:STR_SUBSCRIPTION_ID_TONE] boolValue];
	} else if (indexPath.section == 7 && indexPath.row == 1) {
		self.pushSwitch = cell.accessorySwitch;
		[self.pushSwitch addTarget:self action:@selector(pushSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
		self.pushSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:STR_SUBSCRIPTION_ID_PUSH] boolValue];
	} else if (indexPath.section == 7 && indexPath.row == 2) {
		self.adSwitch = cell.accessorySwitch;
		[self.adSwitch addTarget:self action:@selector(adSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
		self.adSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:STR_SUBSCRIPTION_ID_AD] boolValue];
	}

	[cell.imageView.layer roundCorners:indexPath.section == IDX_APPS ? 6.0 : 0.0];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath isEqualToSection:0 row:0]) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		cell.detailTextLabel.text = [cell.detailTextLabel.text isEqualToString:[NSBundle bundleShortVersionString]] ? [NSBundle bundleVersion] : [NSBundle bundleShortVersionString];
/*
		self.vkEnabled++;
		if (self.vkEnabled % 20 == 0)
			if (![[VKHelper instance] wakeUpSession])
				[[VKHelper instance] authorize];
*/	} else if ([indexPath isEqualToSection:0 row:1]) {
		if (IS_DEBUGGING)
			[self performSegueWithIdentifier:@"login"];
/*		else if ([[VKHelper instance] wakeUpSession])
			[VKSdk forceLogout];
		else
			[[VKHelper instance] authorize];
*/
//		[self setup:Nil];
	} else if ([indexPath isEqualToSection:0 row:2])
		[self presentSafariWithURL:[NSURL URLWithString:VK_GROUP_URL] entersReaderIfAvailable:NO animated:YES completion:^{
			[Answers logCustomEventWithName:@"Group" customAttributes:@{ @"opened" : @"VK" }];
		}];
	else if ([indexPath isEqualToSection:1 row:0])
		[self presentPurchase:^(BOOL success) {
			if (success)
				[self.tableView cellForRowAtIndexPath:NSIndexPathMake(1, 0)].detailTextLabel.text = [Localized purchased];

			[GLOBAL setPurchaseSuccess:success];
		}];
	else if ([indexPath isEqualToSection:1 row:1])
		[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
	else if ([indexPath isEqualToSection:2 row:0])
		[self presentMailComposeWithRecipients:arr_(STR_EMAIL) subject:[NSBundle bundleDisplayNameAndShortVersion] body:Nil attachments:dic_(@"screenshot.jpg", [[self.navigationController.lowerViewController.view snapshotImageAfterScreenUpdates:YES] jpegRepresentation]) completionHandler:Nil];
	else if ([indexPath isEqualToSection:3 row:0])
		[self presentWebActivityWithActivityItems:@[ [NSBundle bundleDisplayName], [NSURL URLForMobileAppWithIdentifier:APP_ID_RINGO affiliateInfo:GLOBAL.affiliateInfo] ] excludedTypes:Nil completionHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
			[Answers logInviteWithMethod:activityType customAttributes:@{ @"version" : [NSBundle bundleVersion], @"success" : completed ? @"YES" : @"NO", @"error" : activityError.localizedDescription ?: STR_EMPTY }];
		} sourceView:[tableView cellForRowAtIndexPath:indexPath]];
	else if ([indexPath isEqualToSection:4 row:0])
		[UIApplication openURL:[NSURL URLForMobileAppWithIdentifier:APP_ID_RINGO affiliateInfo:GLOBAL.affiliateInfo] options:Nil completionHandler:^(BOOL success) {
			if (success) {
				GLOBAL.openReviewCount++;

				[UIRateController logRateWithMethod:@"SettingsController" success:YES];
			} else {
				[UIRateController logRateWithMethod:@"SettingsController" success:NO];
			}
		}];
	else if (indexPath.section == IDX_APPS)
		[self presentProductWithIdentifier:[self.apps[indexPath.row].trackId integerValue] parameters:GLOBAL.affiliateInfo];

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
/*
- (void)setup:(VKAccessToken *)newToken {
	if (!newToken)
		newToken = [[VKHelper instance] wakeUpSession];

	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:NSIndexPathMake(0, 1)];
	if (!cell)
		return;

	if (newToken) {
		cell.textLabel.text = [Localized logOutFromVK];
		cell.detailTextLabel.text = STR_SPACE;//newToken.userId;
		[VKHelper getUsers:arr_(newToken.userId) fields:Nil handler:^(NSArray<VKUser *> *users) {
			[GCD main:^{
				cell.detailTextLabel.text = [users.firstObject fullName];
			}];
		}];
	} else {
		cell.textLabel.text = [Localized logInToVK];
		cell.detailTextLabel.text = Nil;
	}
	cell.imageView.image = [UIImage originalImage:IMG_VK_30];

	[VKHelper getGroupsByIDs:@[ @(VK_GROUP_ID) ] fields:@[ VK_PARAM_MEMBERS_COUNT ] handler:^(NSArray<VKGroup *> *groups) {
		[GCD main:^{
			[self.tableView cellForRowAtIndexPath:NSIndexPathMake(0, 2)].detailTextLabel.text = [Localized followers:[groups.firstObject.members_count integerValue]];
		}];
	}];
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
	[self setup:newToken];

	[self vkLogReceivedNewToken:newToken];
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
	[self vkLogUserDeniedAccess:authorizationError];
}
*/
- (IBAction)waveformSwitchValueChanged:(UISwitch *)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:STR_LOGARITHMIC_WAVEFORM];
}

- (void)switchValueChanged:(UISwitch *)sender subscription:(CKSubscription *)subscription {
	NSString *subscriptionID = subscription.subscriptionID;
	void (^completionHandler)(NSArray<CKSubscription *> *, NSArray<NSString *> *, NSError *) = ^(NSArray<CKSubscription *> *savedSubscriptions, NSArray<NSString *> *deletedSubscriptionIDs, NSError *operationError) {
		if (operationError)
			[[[CKContainer defaultContainer] publicCloudDatabase] fetchSubscriptionsWithIDs:@[ subscriptionID ] completionHandler:^(NSDictionary<NSString *,CKSubscription *> *subscriptionsBySubscriptionID, NSError *operationError) {
				[GCD main:^{
					sender.on = subscriptionsBySubscriptionID[subscriptionID] != Nil;
				}];
			}];

		for (CKSubscription *subscription in savedSubscriptions)
			[[NSUserDefaults standardUserDefaults] setObject:@YES forKey:subscription.subscriptionID];
		for (NSString *subscriptionID in deletedSubscriptionIDs)
			[[NSUserDefaults standardUserDefaults] setObject:@NO forKey:subscriptionID];
	};

	if (sender.on)
		[[[CKContainer defaultContainer] publicCloudDatabase] saveSubscriptions:@[ subscription ] completionHandler:completionHandler];
	else
		[[[CKContainer defaultContainer] publicCloudDatabase] deleteSubscriptionsWithIDs:@[ subscription.subscriptionID ] completionHandler:completionHandler];
}

- (IBAction)toneSwitchValueChanged:(UISwitch *)sender {
	[[CKContainer defaultContainer] fetchCurrentUserRecord:^(CKRecord *record) {
		[self switchValueChanged:sender subscription:[Tone subscription:record.recordID]];
	}];
}

- (IBAction)pushSwitchValueChanged:(UISwitch *)sender {
	[self switchValueChanged:sender subscription:[Push subscription]];
}

- (IBAction)adSwitchValueChanged:(UISwitch *)sender {
	[self switchValueChanged:sender subscription:[Ad subscription]];
}

+ (void)query {
	[Push query:[Push subscriptionPredicate] sortDescriptors:Nil resultsLimit:1 completion:^(NSArray<__kindof CKObjectBase *> *results) {
//		NSLog(@"pushes by state: %@", results);

		[Push query:[NSPredicate predicateWithRecordID:results.firstObject.record.recordID] completion:^(NSArray<__kindof CKObjectBase *> *results) {
//			NSLog(@"pushes by id: %@", results);
		}];
	}];
	[Ad query:[Ad subscriptionPredicate] sortDescriptors:Nil resultsLimit:1 completion:^(NSArray<__kindof CKObjectBase *> *results) {
//		NSLog(@"ads by state: %@", results);

		[Ad query:[NSPredicate predicateWithRecordID:results.firstObject.record.recordID] completion:^(NSArray<__kindof CKObjectBase *> *results) {
//			NSLog(@"ads by id: %@", results);
		}];
	}];
	[[CKContainer defaultContainer] fetchUserRecordID:^(CKRecordID *recordID) {
		[Tone query:[Tone subscriptionPredicate:recordID] sortDescriptors:Nil resultsLimit:1 completion:^(NSArray<Tone *> *results) {
//			NSLog(@"tones by creator: %@", results);

			[Tone query:[NSPredicate predicateWithKeys:@{ @"artist" : results.firstObject.artist ? results.firstObject.artist : @"Saski", @"title" : results.firstObject.title ? results.firstObject.title : @"Faking Bright" }] sortDescriptors:Nil resultsLimit:1 completion:^(NSArray<__kindof CKObjectBase *> *results) {
//				NSLog(@"tones by artist and title: %@", results);
			}];
		}];
		[User query:[NSPredicate predicateWithCreatorUserRecordID:recordID] sortDescriptors:Nil resultsLimit:1 completion:^(NSArray<__kindof CKObjectBase *> *results) {
/*			if ([[[VKHelper instance] wakeUpSession].userId integerValue]) {
				User *user = results.count ? results.firstObject : [User new];
				user.vkUserID = [[[VKHelper instance] wakeUpSession].userId integerValue];
				[user update:Nil];
			}
*/
//			NSLog(@"users by creator: %@", results);
		}];
	}];
}

@end
