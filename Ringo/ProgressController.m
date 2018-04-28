//
//  ExportHelpController.m
//  Ringo
//
//  Created by Alexander Ivanov on 23.09.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "ProgressController.h"
#import "AudioItem+Export.h"
#import "AudioItem+Import.h"
#import "Global.h"
#import "Localized.h"

#import "VKHelper.h"

#import "UIBarButtonItem+Convenience.h"
#import "UIRateController+Answers.h"
#import "UIViewController+Answers.h"
#import "UIViewController+VK.h"

#import "MessageUI+Convenience.h"
#import "SafariServices+Convenience.h"
#import "NSArray+Convenience.h"
#import "NSBundle+Convenience.h"
#import "NSFileManager+iCloud.h"
#import "NSObject+Convenience.h"
#import "UIActivityIndicatorView+Convenience.h"
#import "UIColor+Convenience.h"
#import "UINavigationController+Convenience.h"

#import <Crashlytics/Answers.h>

#define IMG_ENVELOPE_LINE_30 @"envelope-line-30"

#define ARC_360 (2 * M_PI)

@interface ProgressController () <UIPageViewControllerDelegate>

@end

@implementation ProgressController

- (NSString *)loggingName {
	return self.selectedItem ? @"Import" : @"Help";
}

- (NSDictionary<NSString *,id> *)loggingCustomAttributes {
	return self.selectedItem ? @{ @"iCloud" : @([NSFileManager isUbiquityAvailable]) } : @{ @"images" : [self.navigationItem.rightBarButtonItem.title isEqualToString:STR_WIN] ? STR_MAC : STR_WIN };
};

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self startLogging];

	if (!self.selectedItem.assetURL || [self.navigationItem.title isEqualToString:[self.selectedItem description]]) {
		if (!self.selectedItem.assetURL)
			[self setToolbar:@[ [[UIBarButtonItem alloc] initWithImage:[UIImage templateImage:IMG_HELP_LINE] style:UIBarButtonItemStylePlain target:self action:@selector(helpBarButtonItemAction:)], [[UIBarButtonItem alloc] initWithTitle:[Localized fullGuide] style:UIBarButtonItemStylePlain target:self action:@selector(helpBarButtonItemAction:)] ]];

		return;
	}

	self.delegate = self;

	self.currentPage = 1;

//	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIActivityIndicatorView create:UIActivityIndicatorViewStyleWhite]];
	self.navigationItem.rightBarButtonItem = [NSRateController instance].action ? [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightBarButtonAction:)] : [[UIBarButtonItem alloc] initWithTitle:[Localized next] style:UIBarButtonItemStylePlain target:self action:@selector(nextBarButtonAction:)];
	self.navigationItem.title = [self.selectedItem description];//[[Localized processing] uppercaseString];

	self.navigationItem.rightBarButtonItem.enabled = NO;
	AVAssetWriter *writer = [self.selectedItem exportAudio:^(double progress, NSURL *url) {
		[GCD main:^{
			self.navigationController.navigationBar.progress = progress;

			if (!url)
				return;

//			self.navigationItem.leftBarButtonItem = Nil;
			self.navigationItem.rightBarButtonItem.enabled = YES;
//			self.navigationItem.title = [self.navigationItem.title substringToIndex:self.navigationItem.title.length - 3];

			[url copyToUbiquityContainer];

			if (__screenshot)
				return;

			NSUInteger action = [[NSRateController instance] incrementAction] % 10;
			if (action == 3)
//				if (GLOBAL.vkEnabled)
				[self presentAlertForGroupWithID:VK_GROUP_ID title:[Localized followTitle] message:[Localized followMessage] cancelButtonTitle:[Localized cancel] joinButtonTitle:[Localized follow] configuration:^(UIAlertController *instance) {
					[instance.actions.firstObject setActionImage:[UIImage templateImage:IMG_USERS_LINE]];
					[instance.actions.firstObject setActionColor:[UIColor color:HEX_VK_BLUE]];

					[instance.actions.lastObject setActionColor:[UIColor color:HEX_IOS_DARK_GRAY]];
				} completion:^(BOOL success) {
					[Answers logCustomEventWithName:@"Group" customAttributes:@{ @"joined" : success ? @"YES" : @"NO" }];
				}];
			else if (action == 5)
				[self presentAlertWithTitle:[Localized feedbackTitle] message:[Localized feedbackMessage] cancelActionTitle:[Localized cancel] destructiveActionTitle:Nil otherActionTitles:@[ [Localized feedback] ] configuration:^(UIAlertController *instance) {
					[instance.actions.firstObject setActionImage:[UIImage templateImage:IMG_ENVELOPE_LINE_30]];
					[instance.actions.firstObject setActionColor:[UIColor color:HEX_NCS_GREEN]];

					[instance.actions.lastObject setActionColor:[UIColor color:HEX_IOS_DARK_GRAY]];
				} completion:^(UIAlertController *instance, NSInteger index) {
					if (index != NSNotFound)
						[self presentMailComposeWithRecipient:STR_EMAIL subject:[NSBundle bundleDisplayNameAndShortVersion]];
				}];

			[self.selectedItem updateTone:^(BOOL tone) {
				if (!tone)
					return;
				
				[self.selectedItem lookupInVK:^(VKAudioItem *audio) {
					if (!audio)
						return;

					[VKHelper uploadWallPhoto:self.selectedItem.image handler:^(VKPhoto *photo) {
						if (!photo)
							return;

						[VKHelper postMessage:Nil attachments:[NSArray arrayWithObject:photo.attachmentString withObject:audio.attachmentString withObject:self.selectedItem.vkShareURL] ownerID:0 - VK_GROUP_ID handler:^(NSUInteger postID) {

						}];
					}];
				}];
			}];
		}];
	}];

	[self.selectedItem becomeCurrentActivity:[[NSDate date] dateByAddingTimeInterval:TIME_MONTH]];

	self.navigationController.navigationBar.progressView.tintColor = [UIColor whiteColor];
//	[self updateProgress:session];



	if (!writer)
		[self dismissViewControllerAnimated:YES completion:Nil];



	if (self.navigationController.toolbar.gestureRecognizers.count)
		return;

	[self.navigationController.toolbar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reviewBarButtonItemAction:)]];

	if (GLOBAL.openReviewCount)
		return;

	[self setToolbar:@[ [[UIBarButtonItem alloc] initWithImage:[UIImage templateImage:IMG_STAR_LINE] style:UIBarButtonItemStylePlain target:self action:@selector(reviewBarButtonItemAction:)], [[UIBarButtonItem alloc] initWithTitle:[Localized rateApp] style:UIBarButtonItemStylePlain target:self action:@selector(reviewBarButtonItemAction:)] ]];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (!self.selectedItem.assetURL)
		return;

	[self.toolbarItems.firstObject.buttonView animate:CGAffineTransformMakeRotation(DEG_360 / 5 * 4) duration:1.0 options:ANIMATION_OPTIONS completion:Nil];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[self endLogging];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
	if (completed && self.currentPage == self.numberOfPages - 1 && [self.navigationItem.rightBarButtonItem.title isEqualToString:[Localized next]])
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightBarButtonAction:)];
}

- (IBAction)nextBarButtonAction:(id)sender {
	NSArray<UIViewController *> *previousViewControllers = self.viewControllers;

	__weak ProgressController *__self = self;
	[self setCurrentPage:self.currentPage + 1 animated:YES completion:^(BOOL finished) {
		[__self pageViewController:__self didFinishAnimating:finished previousViewControllers:previousViewControllers transitionCompleted:YES];
	}];
}

- (IBAction)rightBarButtonAction:(id)sender {
	[self performSegueWithIdentifier:GUI_IMPORT sender:sender];
}

- (void)updateProgress:(AVAssetExportSession *)session {
	[self.navigationController.navigationBar setProgress:session.progress animated:YES];

	if (session.progress < 1.0)
		[self performSelector:@selector(updateProgress:) withObject:session afterDelay:0.1];
}

- (IBAction)reviewBarButtonItemAction:(UIBarButtonItem *)sender {
	[UIApplication openURL:[NSURL URLForMobileAppWithIdentifier:APP_ID_RINGO affiliateInfo:GLOBAL.affiliateInfo] options:Nil completionHandler:^(BOOL success) {
		if (success) {
			GLOBAL.openReviewCount++;

			[UIRateController logRateWithMethod:@"ProgressController" success:YES];
		} else {
			[UIRateController logRateWithMethod:@"ProgressController" success:NO];
		}
	}];
}

- (IBAction)helpBarButtonItemAction:(UIBarButtonItem *)sender {
	[self presentSafariWithURL:[NSURL URLWithString:URL_WEB]];
}

- (NSString *)unwindSegueIdentifier {
	return GUI_IMPORT;
}

@end
