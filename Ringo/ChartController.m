//
//  ChartController.m
//  Ringo
//
//  Created by Alexander Ivanov on 01.11.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "ChartController.h"
#import "Global.h"
#import "Localized.h"

//#import "VKHelper.h"

#import "NSArray+Convenience.h"
#import "NSCalendar+Convenience.h"
#import "UIActivityIndicatorView+Convenience.h"

#define KEY_SELECTED_SEGMENT_INDEX @"ChartController.segment.selectedSegmentIndex"

@interface ChartController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@end

@implementation ChartController

- (void)viewDidLoad {
	[super viewDidLoad];

//	self.segment.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:KEY_SELECTED_SEGMENT_INDEX];

	self.navigationItem.title = [self.segment titleForSegmentAtIndex:self.segment.selectedSegmentIndex];

	if ([UIApplication sharedApplication].applicationIconBadgeNumber || self.navigationController.tabBarItem.badgeValue.length)
		[[CKContainer defaultContainer] modifyBadge:0 completionHandler:^(BOOL success) {
			if (success)
				[GCD main:^{
					[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
					self.navigationController.tabBarItem.badgeValue = Nil;
				}];
		}];
}

- (IBAction)segmentValueChange:(UISegmentedControl *)sender {
	[self.player stopItem:Nil];

	self.navigationItem.title = [sender titleForSegmentAtIndex:sender.selectedSegmentIndex];

	[self setItems:[NSArray new] animated:NO];

	[self.tableView reloadData];

	[self startActivityIndication:UIActivityIndicatorViewStyleWhiteLarge message:[Localized waiting]];

	[self loadTones:^{
		[self.tableView reloadData];

		[self stopActivityIndication];
	}];

	[[NSUserDefaults standardUserDefaults] setInteger:sender.selectedSegmentIndex forKey:KEY_SELECTED_SEGMENT_INDEX];
}

- (void)loadUsers:(NSArray<Tone *> *)results handler:(void (^)(NSArray<User *> */*, NSArray<VKUser *> **/))handler {
	NSArray<CKRecordID *> *recordIDs = [[results map:^id(__kindof CKObjectBase *obj) {
		return obj.record.creatorUserRecordID;
	}] dictionaryWithKey:^id<NSCopying>(CKRecordID *obj) {
		return obj.recordName;
	}].allValues;

	[User query:[NSPredicate predicateWithCreatorUserRecordIDs:recordIDs] completion:^(NSArray<__kindof CKObjectBase *> *users) {
/*		NSArray<NSNumber *> *vkIDs = [users map:^id(User *obj) {
			return obj.vkUserID > 0 ? @(obj.vkUserID) : Nil;
		}];
*/
//		[VKHelper getUsers:vkIDs fields:Nil handler:^(NSArray<VKUser *> *vkUsers) {
//			if (handler)
				handler(users/*, vkUsers*/);
//		}];
	}];
}

#warning Waveform
#warning Scrolling
#warning Profile scrolling

- (void)loadItems:(void (^)(NSArray<Tone *> *, NSArray<User *> */*, NSArray<VKUser *> **/, NSTimeInterval))handler {
	if (self.segment.selectedSegmentIndex == 0)
		[self loadFeatured:GLOBAL.tonesCount handler:^(NSArray<__kindof Tone *> *results) {
			[self loadUsers:results handler:^(NSArray<User *> *users/*, NSArray<VKUser *> *vkUsers*/) {
				if (handler)
					handler(results, users/*, vkUsers*/, TIME_WEEK);
			}];
		}];
	else if (self.segment.selectedSegmentIndex == 1)
		[self loadRecent:GLOBAL.tonesCount handler:^(NSArray<__kindof Tone *> *results) {
			[self loadUsers:results handler:^(NSArray<User *> *users/*, NSArray<VKUser *> *vkUsers*/) {
				if (handler)
					handler(results, users/*, vkUsers*/, TIME_DAY);
			}];
		}];
	else
		[Tone loadProfile:^(NSArray<__kindof Tone *> *results) {
			if (handler)
				handler(results, Nil/*, Nil*/, 0.0);
		}];
}

- (void)loadFeatured:(NSUInteger)count handler:(void (^)(NSArray<__kindof Tone *> *results))handler {
	[Tone loadFeatured:[NSBundle mainBundle].preferredLocalizations resultsLimit:count completion:^(NSArray<__kindof Tone *> *results) {
		if (results.count < count)
			[Tone loadFeatured:Nil resultsLimit:count - results.count completion:^(NSArray<__kindof Tone *> *globalResults) {
				globalResults = [globalResults query:^BOOL(__kindof Tone *globalResult) {
					return ![results any:^BOOL(__kindof Tone *obj) {
						return [globalResult.record.recordID.recordName isEqualToString:obj.record.recordID.recordName];
					}];
				}];

				if (handler)
					handler([results arrayByAddingObjectsFromArray:globalResults]);
			}];
		else if (handler)
			handler(results);
	}];
}

- (void)loadRecent:(NSUInteger)count handler:(void (^)(NSArray<__kindof Tone *> *results))handler {
	[Tone loadRecent:[NSBundle mainBundle].preferredLocalizations resultsLimit:count completion:^(NSArray<__kindof Tone *> *results) {
		if (results.count < count)
			[Tone loadRecent:Nil resultsLimit:count - results.count completion:^(NSArray<__kindof Tone *> *globalResults) {
				globalResults = [globalResults query:^BOOL(__kindof Tone *globalResult) {
					return ![results any:^BOOL(__kindof Tone *obj) {
						return [globalResult.record.recordID.recordName isEqualToString:obj.record.recordID.recordName];
					}];
				}];
				
				if (handler)
					handler([results arrayByAddingObjectsFromArray:globalResults]);
			}];
		else if (handler)
			handler(results);
	}];
}

@end
