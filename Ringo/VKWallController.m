//
//  VKWallController.m
//  Ringo
//
//  Created by Alexander Ivanov on 14.09.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "VKWallController.h"
#import "AudioController+Export.h"
#import "Global.h"
#import "Localized.h"
#import "UIViewController+VKLog.h"

#import "VKHelper.h"

#import "UIActivityIndicatorView+Convenience.h"
#import "UITableView+Convenience.h"
#import "VKAPI.h"

#import <Crashlytics/Answers.h>

@interface VKWallController ()
@property (strong, nonatomic) IBOutlet UIView *logInView;
@end

@implementation VKWallController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 */

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self setup:[[VKHelper instance] wakeUpSession]];
}

- (void)setup:(VKAccessToken *)newToken {
	self.navigationItem.leftBarButtonItem.title = newToken ? [Localized logOut] : [Localized logIn];
	self.tableView.emptyState = newToken ? Nil : self.logInView;



	if (!newToken)
		return;

	if (self.items)
		return;

	[self setItems:[NSArray new] animated:NO];



	[self startActivityIndication:UIActivityIndicatorViewStyleWhiteLarge message:[Localized waiting]];

	void(^handler)(NSArray *) = ^void(NSArray *items) {
		[self setItems:items animated:YES];

//		[self addCurrentActivities:TIME_MONTH];

		[self stopActivityIndication];
	};

	if (self.selectedItem)
		[[VKAPI api] searchAudio:[self.selectedItem description] handler:handler];
	else
		[[VKAPI api] getAudio:handler];
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
	[self setup:newToken];
}

- (IBAction)leftBarButtonItemAction:(UIBarButtonItem *)sender {
	if ([[VKHelper instance] wakeUpSession]) {
		[VKSdk forceLogout];

		self.navigationItem.leftBarButtonItem.title = [Localized logIn];
		self.tableView.emptyState = self.logInView;

		[self setItems:Nil animated:YES];

		[self.player stopItem:Nil];
	} else {
		[[VKHelper instance] authorize];
	}
}

- (AudioSegment *)segment:(AudioItem *)item {
	return self.selectedItem.segment;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:GUI_SELECT]) {
		if (self.selectedItem)
			[sender copyTo:self.selectedItem];
		else
			self.selectedItem = sender;
	}
}

- (IBAction)logInAction:(UIButton *)sender {
	[[VKHelper instance] authorize];
}

@end
