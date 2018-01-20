//
//  VKSearchController.m
//  Ringo
//
//  Created by Alexander Ivanov on 14.09.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "VKSearchController.h"
#import "AudioItem+Import.h"
#import "Global.h"
#import "UIViewController+VKLog.h"

#import "NSArray+Convenience.h"
#import "NSObject+Convenience.h"
#import "UIApplication+Convenience.h"
#import "UITableView+Convenience.h"
#import "UISearchController+Convenience.h"
#import "VKAPI.h"
#import "SafariServices+Convenience.h"

#import "VKHelper.h"

#import <Crashlytics/Answers.h>
#import <VKSdk/VKSdk.h>

@interface VKSearchController ()
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) id searchRequest;

@property (strong, nonatomic) IBOutlet UIView *logInView;
@property (strong, nonatomic) IBOutlet UIView *emptyView;

@property (strong, nonatomic) NSArray<VKItem *> *vkItems;
@end

@implementation VKSearchController

- (void)setVkItems:(NSArray<VKItem *> *)vkItems {
	_vkItems = vkItems;

	[GCD main:^{
		[self setItems:vkItems animated:YES];

		[self setup:[[VKHelper instance] wakeUpSession]];
	}];
}

- (UISearchController *)searchController {
	if (!_searchController) {
		__weak VKSearchController *__self = self;
		_searchController = [self searchControllerWithHandler:^(NSString *text) {
			__self.searchRequest = [text hasPrefix:STR_NUMBER] ? [VKHelper searchNews:text handler:^(NSArray<VKWallItem *> *items) {
				__self.vkItems = [[items query:^BOOL(VKWallItem *obj) {
					return obj.audioItems.count;
				}] sortedArrayUsingComparator:^NSComparisonResult(VKWallItem *obj1, VKWallItem *obj2) {
					return [obj2.likesCount compare:obj1.likesCount];
				}];
			}] : [[VKAPI api] searchAudio:text handler:^(NSArray *items) {
				__self.vkItems = items;
			}];
		}];
//		_searchController.searchBar.barStyle = UIBarStyleBlack;

		_searchController.searchBar.delegate = self;
		_searchController.searchBar.showsCancelButton = YES;
	}

	return _searchController;
}

- (void)setSearchRequest:(id)searchRequest {
//	if ([_searchRequest.methodParameters[VK_PARAM_Q] isEqualToString:searchRequest.methodParameters[VK_PARAM_Q]])
//		return;

	if (_searchRequest)
		_sel(_searchRequest, cancel);

	_searchRequest = searchRequest;

	if (!_searchRequest)
		[self setItems:Nil animated:YES];

	[self.player stopItem:Nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.

	[self searchController];
//	self.definesPresentationContext = YES;
//	self.navigationItem.titleView = self.searchController.searchBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

	self.searchController = Nil;
	self.searchRequest = Nil;
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
	self.tableView.emptyState = newToken ? self.searchController.searchBar.text.length ? Nil : self.emptyView : self.logInView;
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
	[self setup:newToken];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[self performSegueWithIdentifier:GUI_UNWIND sender:Nil];
}

- (IBAction)logInAction:(UIButton *)sender {
	[[VKHelper instance] authorize];
}

- (IBAction)emptyAction:(UIButton *)sender {
	self.searchController.searchBar.text = sender.titleLabel.text;
}

- (NSString *)title:(AudioItem *)item {
	return item.segment
		? [item description]
		: [super title:item];
}

- (NSString *)subtitle:(AudioItem *)item {
	return item.segment
		? [item.segment description]
		: [super subtitle:item];
}

- (NSString *)detail:(AudioItem *)item time:(NSTimeInterval)time {
	return item.segment
		? [super detail:item time:(time == NSTimeIntervalSince1970 ? item.segment.endTime : time) - item.segment.startTime]
		: [super detail:item time:time];
}

- (float)progress:(AudioItem *)item time:(NSTimeInterval)time {
	return item.segment
		? time == NSTimeIntervalSince1970 ? 1.0 : (time - item.segment.startTime) / (item.segment.endTime - item.segment.startTime)
		: [super progress:item time:time];
}

- (NSArray *)accessoryImages:(AudioItem *)item {
	NSArray *accessoryImages = [super accessoryImages:item];
	return GLOBAL.vkEnabled ? [@[ [UIImage templateImage:IMG_USER_LINE] ] arrayByAddingObjectsFromArray:accessoryImages] : accessoryImages;
}

- (void)accessoryImageWithIndex:(NSUInteger)index tappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	if (index == 1) {
		NSInteger ownerID = [idx(self.vkItems, indexPath.row).dictionary[VK_PARAM_OWNER_ID] integerValue];
		if (ownerID < 0)
			[VKHelper getGroupsByIDs:@[ @(labs(ownerID)) ] fields:Nil handler:^(NSArray<VKGroup *> *groups) {
				[GCD main:^{
					[self presentSafariWithURL:groups.firstObject.url];
				}];
			}];
		else if (ownerID > 0)
			[VKHelper getUsers:@[ @(ownerID) ] fields:Nil handler:^(NSArray<VKUser *> *users) {
				[GCD main:^{
					[self presentSafariWithURL:users.firstObject.url];
				}];
			}];
	} else {
		[super accessoryImageWithIndex:index tappedForRowWithIndexPath:indexPath];
	}
}

@end
