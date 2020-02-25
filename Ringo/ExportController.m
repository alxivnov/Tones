//
//  ExportController.m
//  Ringo
//
//  Created by Alexander Ivanov on 09.09.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import "ExportController.h"
#import "AudioItem+Export.h"
#import "AudioItem+Import.h"
#import "Global.h"
#import "Localized.h"

#import "UIViewController+Answers.h"
//#import "UIViewController+VK.h"

#import "Dispatch+Convenience.h"
#import "TwitterKit+Convenience.h"
#import "FBSDKShareKit+Convenience.h"
#import "NSObject+Convenience.h"
#import "UIActivityViewController+Convenience.h"
#import "UIAlertController+Convenience.h"
#import "UIDocumentPickerViewController+Convenience.h"
#import "UIViewController+Convenience.h"

#import <Crashlytics/Answers.h>
#import <TwitterKit/TwitterKit.h>

#define IMG_CLOUD_UPLOAD @"cloud-upload"
#define IMG_FB_30 @"FB-30"
#define IMG_TW_30 @"TW-30"
//#define IMG_VK_30 @"VK-30"

#define KEY_FACEBOOK @"Facebook"
#define KEY_TWITTER @"Twitter"
//#define KEY_VK @"VK"
#define KEY_TONE @"Tone"
#define KEY_SUCCESS @"success"
#define KEY_METHOD @"method"

@implementation ExportController

- (NSArray *)accessoryImages:(AudioItem *)item {
	return Nil;//[UIImage originalImages:[NSArray arrayWithObject:IMG_FB_30 withObject:/*GLOBAL.vkEnabled ? IMG_VK_30 :*/ IMG_TW_30]];
}

#warning Reload accessory image!!!
#warning Test Twitter link on iPad!

- (void)accessoryImageWithIndex:(NSUInteger)index tappedForRowWithIndexPath:(NSIndexPath *)indexPath {
//	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	
	AudioItem *item = [self itemAtIndex:indexPath.row];
	
//	if (index == 1)
//		[self presentDocumentExport:Nil URL:item.assetURL fromView:cell];
//	else if (index == 2)
	if (index == 1)
		[item lookup:^(AFMediaItem *mediaItem) {
			[GCD main:^{
				[self presentSharingContent:[FBSDKShareLinkContent contentWithURL:item.shareURL hashtag:URL_HASHTAG] modes:GLOBAL.fbModes completion:^(BOOL success, NSError *error) {
					[Answers logShareWithMethod:KEY_FACEBOOK contentName:[item description] contentType:KEY_TONE contentId:[item identifier] customAttributes:@{ KEY_SUCCESS : success ? @"YES" : @"NO" }];
				}];
			}];
		}];
//	else if (index == 3) {
	else if (index == 2) {
/*		if (GLOBAL.vkEnabled) {
			if ([VKSdk wakeUpSession:VK_PERMISSIONS])
				[self performSegueWithIdentifier:GUI_VK_SHARE sender:item];
			else
				[self presentShareDialogWithURL:item.vkShareURL title:[item shareDescription] uploadImages:arr_(item.image) completion:^(VKShareDialogControllerResult result) {
					[Answers logShareWithMethod:KEY_VK contentName:[item description] contentType:KEY_TONE contentId:[item identifier] customAttributes:@{ KEY_SUCCESS : result == VKShareDialogControllerResultDone ? @"YES" : @"NO", KEY_METHOD : @"presentShareDialogWithURL:" }];
				}];
		} else {
*/			TWComposer *composer = [[TWComposer alloc] init];
			[composer setText:[item shareDescription]];
			[composer setImage:item.image];
			[composer setURL:item.shareURL];
			[composer showFromViewController:self completion:^(TWTRComposerResult result) {
				[Answers logShareWithMethod:KEY_TWITTER contentName:[item description] contentType:KEY_TONE contentId:[item identifier] customAttributes:@{ KEY_SUCCESS : result == TWTRComposerResultDone ? @"YES" : @"NO", KEY_METHOD : @"showFromViewController:" }];
			}];
//		}
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
/*	if ([segue.identifier isEqualToString:GUI_VK_SHARE])
		[segue.destinationViewController forwardSelector:@selector(setSelectedItem:) withObject:sender nextTarget:UIViewControllerNextTarget(YES)];
	else
*/		[super prepareForSegue:segue sender:sender];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
	__block ExportController *__self = self;
	return @[ /*[UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:[Localized delete] handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
		[__self tableView:__self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
	}],*/ [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:[Localized actions] handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
		[__self tableView:__self.tableView swipeAccessoryButtonPushedForRowAtIndexPath:indexPath];
	}] ];
}

- (void)tableView:(UITableView *)tableView swipeAccessoryButtonPushedForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if (!cell)
	   return;

	AudioItem *item = [self itemAtIndex:indexPath.row];
	
	[self presentSheetWithTitle:[item description] message:nil cancelActionTitle:[Localized cancel] destructiveActionTitle:[Localized delete] otherActionTitles:@[ @"Facebook", @"Twitter", /*@"VK",*/ [Localized share], /*[Localized rename]*/ ] from:cell completion:^(UIAlertController *instance, NSInteger index) {
		if (index == 0) {
			[self accessoryImageWithIndex:1 tappedForRowWithIndexPath:indexPath];
		} else if (index == 1) {
			[self accessoryImageWithIndex:2 tappedForRowWithIndexPath:indexPath];
		} else if (index == 2) {
			NSArray *items = arr_(item.assetURL);//[NSArray arrayWithObject:[item shareDescription] withObject:[item webShareURL:YES] withObject:item.image];
			NSArray *activities = [UIWebActivity webActivities:FB_APP_ID];
//			activities = [activities arrayByAddingObject:(id)[UIDocumentExportActivity activityWithURL:item.assetURL]];
			[self presentActivityWithActivityItems:items applicationActivities:activities completionHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
				if (completed)
					[tableView setEditing:NO animated:YES];
			} sourceView:cell];
/*		} else if (index == 3) {
			[self presentAlertWithTitle:@"Rename" message:Nil cancelActionTitle:[Localized cancel] destructiveActionTitle:Nil otherActionTitles:@[ [Localized rename] ] configuration:^(UIAlertController *instance) {
				
			} completion:^(UIAlertController *instance, NSInteger index) {
				
			}];
*/		} else if (index == NSIntegerMin) {
			[self tableView:tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
		}
	}];
	return;
	

}

- (NSString *)loggingName {
	return @"Main";
}
/*
- (NSDictionary<NSString *,id> *)loggingCustomAttributes {
	return @{ @"VK enabled" : GLOBAL.vkEnabled ? @"YES" : @"NO", @"VK logged in" : [VKSdk isLoggedIn] ? @"YES" : @"NO"  };
};
*/
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self startLogging];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[self endLogging];
}

@end
