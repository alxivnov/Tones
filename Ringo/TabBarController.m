//
//  TabBarController.m
//  Ringo
//
//  Created by Alexander Ivanov on 14.09.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "TabBarController.h"
#import "Global.h"
#import "VKFeaturedController.h"

#import "UIViewController+Answers.h"

#import "UIGestureTransition.h"

#define IMG_SEARCH_FULL @"search-full-30"

@interface TabBarController () <UITabBarControllerDelegate>
@property (strong, nonatomic, readonly) UIPanTransition *transition;
@end

@implementation TabBarController

__synthesize(UIPanTransition *, transition, [UIPanTransition gestureTransition:Nil])

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	if (self.recordName)
		self.selectedIndex = self.viewControllers.count - 1;



	self.tabBar.tintColor = [UIColor whiteColor];
	idx(self.tabBar.items, 0).selectedImage = [UIImage templateImage:IMG_USER_FULL];
	idx(self.tabBar.items, 1).selectedImage = [UIImage templateImage:IMG_SEARCH_FULL];
/*
	if (self.viewControllers.count == 2) {
		cls(UINavigationController, self.viewControllers[0]).navigationBar.barTintColor = self.tabBar.barTintColor;
		if (!GLOBAL.vkEnabled)
			cls(UINavigationController, self.viewControllers[0]).visibleViewController.navigationItem.leftBarButtonItem = Nil;
	}
*/


	self.tabBar.items.lastObject.badgeValue = [UIApplication sharedApplication].applicationIconBadgeNumber ? [@([UIApplication sharedApplication].applicationIconBadgeNumber) description] : Nil;
	idx(self.tabBar.items, 1).badgeValue = [VKFeaturedController newPosts] ? [@([VKFeaturedController newPosts]) description] : Nil;



	if (self.modalPresentationStyle == UIModalPresentationFullScreen) {
		self.transitioningDelegate = self.transition;
	}
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

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (NSString *)loggingName {
	return @"Featured";
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self startLogging];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[self endLogging];
}

@end
