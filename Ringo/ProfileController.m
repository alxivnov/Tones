//
//  ProfileController.m
//  Ringtonic
//
//  Created by Alexander Ivanov on 24.04.16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import "ProfileController.h"
#import "ProfileCell.h"
#import "TabBarController.h"
#import "Global.h"
#import "Localized.h"

#import "VKHelper.h"

#import "Dispatch+Convenience.h"
#import "SafariServices+Convenience.h"
#import "Accelerate+Convenience.h"
#import "NSObject+Convenience.h"
#import "UIColor+Convenience.h"
#import "UITableView+Convenience.h"

@implementation ProfileController

- (void)loadItems:(void (^)(NSArray<Tone *> *, NSArray<User *> *, NSArray<VKUser *> *, NSTimeInterval))handler {
	[Tone loadProfile:^(NSArray<__kindof Tone *> *results) {
		if (handler)
			handler(results, Nil, Nil, 0.0);



		NSString *recordName = cls(TabBarController, self.navigationController.tabBarController).recordName;

		if (!recordName)
			return;

		NSUInteger index = [results first:^BOOL(__kindof Tone *obj) {
			return [obj.record.recordID.recordName isEqualToString:recordName];
		}];

		cls(TabBarController, self.navigationController.tabBarController).recordName = Nil;

		if (index == NSNotFound)
			return;

		[GCD main:^{
			[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1] atScrollPosition:UITableViewScrollPositionNone animated:YES];
		}];

		[User query:[NSPredicate predicateWithCreatorUserRecordID:results[index].record.lastModifiedUserRecordID] completion:^(NSArray<User *> *users) {
			if (users.firstObject.vkUserID > 0)
				[VKHelper getUsers:@[ @(users.firstObject.vkUserID) ] fields:@[ VK_PARAM_SEX ] handler:^(NSArray<VKUser *> *vkUsers) {
					if (vkUsers.count)
						[GCD main:^{
							[self presentAlertWithTitle:results[index].description message:[Localized userUsedYourTone:[vkUsers.firstObject fullName] sex:vkUsers.firstObject.sex.unsignedIntegerValue] cancelActionTitle:[Localized cancel] destructiveActionTitle:Nil otherActionTitles:@[ [Localized openProfile] ] configuration:^(UIAlertController *instance) {
								[instance.actions.firstObject setActionImage:[UIImage templateImage:IMG_USER_LINE]];
								[instance.actions.firstObject setActionColor:[UIColor color:HEX_VK_BLUE]];

								[instance.actions.lastObject setActionColor:[UIColor color:HEX_IOS_DARK_GRAY]];
							} completion:^(UIAlertController *instance, NSInteger index) {
								if (index != NSNotFound)
									[self presentSafariWithURL:vkUsers.firstObject.url];
							}];
						}];
				}];
		}];
	}];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if ([UIApplication sharedApplication].applicationIconBadgeNumber || self.navigationController.tabBarItem.badgeValue.length)
		[[CKContainer defaultContainer] modifyBadge:0 completionHandler:^(BOOL success) {
			if (success)
				[GCD main:^{
					[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
					self.navigationController.tabBarItem.badgeValue = Nil;
				}];
		}];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return !self.tones.count ? [super numberOfSectionsInTableView:tableView] : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return section || !self.tones.count ? [super tableView:tableView numberOfRowsInSection:section] : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section || !self.tones.count)
		return [super tableView:tableView cellForRowAtIndexPath:indexPath];

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GUI_CUSTOM_CELL_ID forIndexPath:indexPath];
	ProfileCell *profileCell = cls(ProfileCell, cell);
	profileCell.countOfTones = self.tones.count;
	profileCell.countOfTimes = lround([self.tones sum:^NSNumber *(Tone *obj) {
		return @(obj.exportCount);
	}]);
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.section || !self.tones.count ? [super tableView:tableView didSelectRowAtIndexPath:indexPath] : Nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.section || !self.tones.count ? [super tableView:tableView canEditRowAtIndexPath:indexPath] : NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.section || !self.tones.count ? [super tableView:tableView heightForRowAtIndexPath:indexPath] : 128.0;
}

@end
