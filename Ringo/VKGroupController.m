//
//  VKGroupController.m
//  Ringtonic
//
//  Created by Alexander Ivanov on 04/05/16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import "VKGroupController.h"
#import "Localized.h"

#import "NSArray+Convenience.h"
#import "NSObject+Convenience.h"
#import "NSURLSession+Convenience.h"
#import "UIImage+Convenience.h"
#import "UITableView+Convenience.h"

#import "VKHelper.h"

@interface VKGroupController ()
@property (strong, nonatomic) VKUser *user;
@property (strong, nonatomic) NSArray<VKGroup *> *groups;
@end

@implementation VKGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

	self.user = Nil;
	self.groups = Nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (self.user || self.groups)
		return;

	[VKHelper getUsers:0 fields:@[ VK_PARAM_COUNTERS, VK_PARAM_PHOTO_50 ] handler:^(NSArray<VKUser *> *users) {
		self.user = users.firstObject;

		if (self.groups)
			[GCD main:^{
				[self.tableView reloadData];
			}];
	}];

	[VKHelper getGroups:0 fields:@[ VK_PARAM_MEMBERS_COUNT, VK_PARAM_PHOTO_50, VK_PARAM_CAN_POST ] filter:Nil/*@[ VK_PARAM_FILTER_MODER ]*/ handler:^(NSArray<VKGroup *> *groups) {
		self.groups = [[groups query:^BOOL(VKGroup *obj) {
			return obj.can_post.boolValue;
		}] sortedArrayUsingComparator:^NSComparisonResult(VKGroup *obj1, VKGroup *obj2) {
			return [obj2.is_admin compare:obj1.is_admin];
		}];

		if (self.user)
			[GCD main:^{
				[self.tableView reloadData];
			}];
	}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return section == 0 ? self.user ? 1 : 0 : section == 1 ? self.groups.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GUI_CELL_ID forIndexPath:indexPath];

	cell.textLabel.text = indexPath.section ? self.groups[indexPath.row].name : [self.user fullName];
	cell.detailTextLabel.text = indexPath.section ? [Localized followers:[self.groups[indexPath.row].members_count integerValue]] : [Localized friends:self.user.friendsCount];

	[[NSURL URLWithString:indexPath.section ? self.groups[indexPath.row].photo_50 : self.user.photo_50] cache:^(NSURL *url) {
		UIImage *image = [[UIImage imageWithContentsOfURL:url] imageWithSize:CGSizeMake(30.0, 30.0) mode:UIImageScaleAspectFit];

		[GCD main:^{
			cell.imageView.image = image;

			[cell layoutSubviews];
		}];
	}];

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return section ? self.groups.count ? [Localized myCommunities] : Nil : [Localized myProfile];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];

	self.selectedItem = indexPath.section ? self.groups[indexPath.row] : Nil;
}

@end
