//
//  NavigationController.m
//  Ringo
//
//  Created by Alexander Ivanov on 17.08.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import "NavigationController.h"

#import "UIGestureRecognizer+Convenience.h"
#import "UIGestureTransition.h"
#import "UIView+Convenience.h"
#import "UIViewController+Convenience.h"

@interface NavigationController ()
@property (strong, nonatomic, readonly) UIPanTransition *transition;
@end

@implementation NavigationController

__synthesize(UIPanTransition *, transition, [UIPanTransition gestureTransition:Nil])

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.

//	self.delegate = self;



	if (self.modalPresentationStyle == UIModalPresentationFullScreen) {
		self.transitioningDelegate = self.transition;

		[self.navigationBar addPanWithTarget:self];

		UIView *view = self.lastViewController.view;
		UIScrollView *scrollView = [view isKindOfClass:[UIScrollView class]] ? view : [view subview:UISubviewKindOfClass(UIScrollView)];
		[scrollView.panGestureRecognizer addTarget:self action:@selector(pan:)];
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
/*
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	[navigationController setToolbarHidden:!viewController.toolbarItems.count animated:animated];
}
*/
- (void)pan:(UIPanGestureRecognizer *)sender {
	CGPoint translation = [sender translationInView:sender.view];

	if (sender.state == UIGestureRecognizerStateBegan && 0.0 - cls(UIScrollView, sender.view).contentOffset.y >= cls(UIScrollView, sender.view).contentInset.top && fabs(translation.x) < fabs(translation.y)) {
		__block id <UIViewControllerTransitioningDelegate> transition = self.containingViewController.transitioningDelegate = [UIPanTransition gestureTransition:sender];

		UIViewController *vc = self.lastViewController;
		NSString *identifier = sel(vc, unwindSegueIdentifier);
		if (identifier)
			[vc performSegueWithIdentifier:identifier sender:transition];
		else
			[self.presentingViewController dismissViewControllerAnimated:YES completion:^{
				transition = self.containingViewController.transitioningDelegate = Nil;
			}];
	}
}

- (NSString *)unwindSegueIdentifier {
	return Nil;
}

@end
