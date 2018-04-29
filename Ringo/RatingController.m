//
//  RatingController.m
//  Ringo
//
//  Created by Alexander Ivanov on 09.09.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import "RatingController.h"
#import "Global.h"
#import "Localized.h"
//#import "UIViewController+VKLog.h"

#import "UIRateController+Answers.h"

#import "SafariServices+Convenience.h"
#import "FBAudienceNetwork+Convenience.h"
#import "NSArray+Convenience.h"
#import "NSFileManager+Convenience.h"
#import "NSLayoutConstraint+Convenience.h"
#import "SKInAppPurchase.h"
#import "UIColor+Convenience.h"
#import "UITableView+Convenience.h"
#import "UIViewController+Convenience.h"
//#import "VKHelper.h"

#import <Crashlytics/Answers.h>

@interface RatingController ()
@property (strong, nonatomic, readonly) FBAdViewDelegate *adView;
@property (assign, nonatomic, readonly) NSTimeInterval sec;
@property (assign, nonatomic, readonly) BOOL purchased;
@end

@implementation RatingController

- (void)viewDidLoad {
	[super viewDidLoad];

	[NSRateController instance].appIdentifier = APP_ID_RINGO;
	[NSRateController instance].affiliateInfo = GLOBAL.affiliateInfo;
	[NSRateController instance].recipient = STR_EMAIL;

	[UIRateController instance].view.backgroundColor = [@[ [UIColor color:HEX_NCS_RED], [UIColor color:HEX_NCS_BLUE], [UIColor color:HEX_NCS_GREEN], [UIColor color:HEX_NCS_YELLOW] ] randomObject];
	[UIRateController instance].view.tintColor = [UIColor whiteColor];

	[[UIRateController instance] setupLogging:^(NSRateControllerState state) {
		if (state == NSRateControllerStateInit || state == NSRateControllerStateLikeNo || state == NSRateControllerStateLikeYes)
			return;

		if (self.tableView.numberOfSections > [self numberOfSectionsInTableView:self.tableView])
			[self.tableView deleteSection:0];
		else
			[self.tableView reloadSection:0];
	}];
}

__synthesize(FBAdViewDelegate *, adView, [FBAdViewDelegate new])
__synthesize(NSTimeInterval, sec, [[NSDate date] timeIntervalSinceDate:[[NSFileManager URLForDirectory:NSDocumentDirectory] fileCreationDate]])

- (BOOL)purchased {
	return [IAP_IDS any:^BOOL(id obj) {
		return [SKInAppPurchase purchaseWithProductIdentifier:obj].purchased;
	}];
}

- (IBAction)fbAction:(UIButton *)sender {
	[self presentSafariWithURL:[NSURL URLWithString:FB_GROUP_URL] entersReaderIfAvailable:NO animated:YES completion:^{
		[Answers logCustomEventWithName:@"Group" customAttributes:@{ @"opened" : @"FB" }];
	}];
}

- (BOOL)topSection:(NSUInteger)section {
	return self.items.count && !section && ([UIRateController instance].view || (self.sec > TIME_WEEK && !self.purchased)) && !__screenshot;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if ([self topSection:0])
		return [super numberOfSectionsInTableView:tableView] + 1;

	return [super numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([self topSection:section])
		return 1;
	
	return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self topSection:indexPath.section]) {
//		BOOL logIn = GLOBAL.vkEnabled && [[VKHelper instance] wakeUpSession] == Nil;

		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:/*logIn ? @"vk" : */@"fb" forIndexPath:indexPath];

//		if (logIn)
//			cell.textLabel.text = [Localized logInToVK];

		if ([UIRateController instance].view) {
			[cell.contentView addSubview:[UIRateController instance].view];
			[cell.contentView equalSize:[UIRateController instance].view];
		} else if ((self.sec > TIME_WEEK && !self.purchased)) {
			[self.adView loadWithPlacementID:FB_PLACEMENT_ID rootViewController:self completion:^(FBAdView *adView) {
				if (adView)
					[GCD main:^{
						[cell.contentView addSubview:adView];
						[cell.contentView equalSize:adView];

						cell.selectionStyle = UITableViewCellSelectionStyleNone;
					}];
			}];
		}

		return cell;
	}
	
	return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self topSection:indexPath.section]) {
/*		BOOL logIn = GLOBAL.vkEnabled && [[VKHelper instance] wakeUpSession] == Nil;

		if (logIn)
			[[VKHelper instance] authorize];
		else
*/			[self fbAction:Nil];

		return;
	}
	
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self topSection:indexPath.section])
		return;
	
	[super tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self topSection:indexPath.section])
		return NO;
 
	return YES;//[super tableView:tableView canEditRowAtIndexPath:indexPath];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self topSection:indexPath.section])
		return Nil;
	
	return [super tableView:tableView editActionsForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.items.count && !indexPath.section && !__screenshot) {
		if ([UIRateController instance].view)
			return 128.0;
		else if ((self.sec > TIME_WEEK && !self.purchased))
			return self.adView.adSize.size.height;
	}

	return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}
/*
- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
	if ([self topSection:0])
		[self.tableView reloadRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

	[self.lastViewController vkLogReceivedNewToken:newToken];
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
	[self.lastViewController vkLogUserDeniedAccess:authorizationError];
}
*/
@end
