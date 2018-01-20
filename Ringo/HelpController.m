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

#import "UIImage+View.h"
#import "UIViewController+Answers.h"

#import "NSArray+Convenience.h"
#import "NSFileManager+iCloud.h"
#import "NSObject+Convenience.h"
#import "UIColor+Convenience.h"
#import "UIView+Convenience.h"

@implementation HelpController

- (void)setup:(NSString *)title {
	if (!title.length)
		title = [self.navigationItem.rightBarButtonItem.title isEqualToString:STR_WIN] ? STR_MAC : STR_WIN;

	self.navigationItem.rightBarButtonItem.title = title;

	self.view.backgroundColor = [title isEqualToString:STR_WIN] ? [UIColor color:HEX_IOS_WHITE] : [UIColor whiteColor];

	self.pageViewControllers = [[title isEqualToString:STR_WIN] ? @[ @"help-1", @"help-2", @"help-3", @"help-4" ] : @[ @"help-1", @"win-1", @"win-2", @"win-3", @"help-4" ] map:^id(id obj) {
		HelpView *view = [[HelpView alloc] initWithFrame:self.view.bounds];
		view.image.image = [UIImage originalImage:obj];
		view.label.text = NSLocalize(obj);
		return [view embedInViewController];
	}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	self.automaticallyAdjustsScrollViewInsets = NO;
	
	[UIPageControl appearance].currentPageIndicatorTintColor = self.navigationController.navigationBar.barTintColor;
	[UIPageControl appearance].pageIndicatorTintColor = [UIColor color:HEX_IOS_GRAY];

	[self setup:[NSFileManager isUbiquityAvailable] ? STR_WIN : STR_MAC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
	
	self.pageViewControllers = Nil;
}

- (IBAction)rightBarButtonItemAction:(UIBarButtonItem *)sender {
	[self setup:Nil];
}

@end
