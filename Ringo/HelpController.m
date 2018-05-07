//
//  HelpController.m
//  Ringo
//
//  Created by Alexander Ivanov on 03.06.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import "HelpController.h"
#import "HelpView.h"
#import "Localized.h"
#import "Global.h"

#import "UIImage+View.h"
#import "UIViewController+Answers.h"

#import "NSArray+Convenience.h"
#import "NSFileManager+iCloud.h"
#import "NSObject+Convenience.h"
#import "UIColor+Convenience.h"
#import "UIView+Convenience.h"

@interface HelpController ()
@property (strong, nonatomic, readonly) NSArray<NSString *> *imageNames;
@end

@implementation HelpController

- (NSArray<NSString *> *)imageNames {
	return [self.navigationItem.rightBarButtonItem.title isEqualToString:STR_WIN] ? @[ @"help-1", @"help-2", @"help-3", @"help-4" ] : @[ @"help-1", @"win-1", @"win-2", @"win-3", @"help-4" ];
}

- (UIViewController *)viewControllerForIndex:(NSUInteger)index {
	NSString *obj = idx(self.imageNames, index);
	if (!obj)
		return Nil;

	HelpView *view = [[HelpView alloc] initWithFrame:self.view.bounds];
	view.image.image = [UIImage originalImage:obj];
	view.label.text = loc(obj);
	view.tag = index;
	return [view embedInViewController];
}

- (NSUInteger)indexForViewController:(UIViewController *)viewController {
	return viewController.view.tag;
}

- (NSUInteger)numberOfPages {
	return self.imageNames.count;
}

- (void)setup:(NSString *)title {
	if (!title.length)
		title = [self.navigationItem.rightBarButtonItem.title isEqualToString:STR_WIN] ? STR_MAC : STR_WIN;

	self.navigationItem.rightBarButtonItem.title = title;

	self.view.backgroundColor = [title isEqualToString:STR_WIN] ? /*[UIColor color:HEX_IOS_WHITE]*/[UIColor color:0x1E1E1E] : [UIColor color:0x0F0F0F]/*[UIColor whiteColor]*/;

	self.currentPage = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	self.automaticallyAdjustsScrollViewInsets = NO;
	
	[UIPageControl appearance].currentPageIndicatorTintColor = /*self.navigationController.navigationBar.barTintColor*/GLOBAL.globalTintColor;
	[UIPageControl appearance].pageIndicatorTintColor = [UIColor color:HEX_IOS_GRAY];

	[self setup:[NSFileManager isUbiquityAvailable] ? STR_WIN : STR_MAC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rightBarButtonItemAction:(UIBarButtonItem *)sender {
	[self setup:Nil];
}

@end
