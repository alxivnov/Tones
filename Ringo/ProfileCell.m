//
//  ProfileCell.m
//  Ringtonic
//
//  Created by Alexander Ivanov on 03/08/16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import "ProfileCell.h"


#import "User.h"

//#import "VKHelper.h"

#import "Dispatch+Convenience.h"
#import "NSObject+Convenience.h"

#define KEY_COUNT_OF_TIMES @"ProfileCell.countOfTimes"

@interface ProfileCell ()
@property (strong, nonatomic) User *user;

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UILabel *countOfTonesLabel;
@property (weak, nonatomic) IBOutlet UILabel *countOfTimesLabel;
@end

@implementation ProfileCell

- (void)setUser:(User *)user {
	_user = user;

	[GCD main:^{
		self.titleField.text = user.title;
	}];
/*
	if (user.vkUserID)
		[VKHelper getUsers:arr_(@(user.vkUserID)) fields:Nil handler:^(NSArray<VKUser *> *users) {
			[GCD main:^{
				self.titleField.placeholder = [users.firstObject fullName];
			}];
		}];
*/}

- (NSUInteger)countOfTones {
	return [self.countOfTonesLabel.text integerValue];
}

- (void)setCountOfTones:(NSUInteger)countOfTones {
	self.countOfTonesLabel.text = [@(countOfTones) description];
}

- (NSUInteger)countOfTimes {
	return [self.countOfTimesLabel.text integerValue];
}

- (void)setCountOfTimes:(NSUInteger)countOfTimes {
	unsigned long count = [[NSUserDefaults standardUserDefaults] integerForKey:KEY_COUNT_OF_TIMES];

	[[NSUserDefaults standardUserDefaults] setInteger:countOfTimes forKey:KEY_COUNT_OF_TIMES];

	self.countOfTimesLabel.text = count > 0 && count < countOfTimes ? [NSString stringWithFormat:@"%lu (+%lu)", count, countOfTimes - count] : [@(countOfTimes) description];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

	self.titleField.delegate = self;

	[[CKContainer defaultContainer] fetchUserRecordID:^(CKRecordID *recordID) {
		[User query:[NSPredicate predicateWithCreatorUserRecordID:recordID] completion:^(NSArray<User *> *results) {
			self.user = results.count ? results.firstObject : [User new];
/*
			if ([[[VKHelper instance] wakeUpSession].userId integerValue]) {
				User *user = self.user;//results.count ? results.firstObject : [User new];
				user.vkUserID = [[[VKHelper instance] wakeUpSession].userId integerValue];
				[user update:Nil];
			}
*/
		}];
	}];
/*
	NSString *vkUserID = [[VKHelper instance] wakeUpSession].userId;
	if (vkUserID)
		[VKHelper getUsers:arr_(vkUserID) fields:Nil handler:^(NSArray<VKUser *> *users) {
			[GCD main:^{
				self.titleField.placeholder = [users.firstObject fullName];
			}];
		}];
*/
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

	// Configure the view for the selected state
	
	self.titleField.delegate = self;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (textField.text.length || self.user.vkUserID) {
		self.user.title = textField.text;

		[self.user update:^(User *savedObject) {
			self.user = savedObject;
		}];
	} else {
		[self.user remove:^(NSString *deletedRecordName) {
			if (deletedRecordName)
				self.user = Nil;
		}];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	return [textField endEditing:YES];
}

@end
