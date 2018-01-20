//
//  CKController.m
//  Ringtonic
//
//  Created by Alexander Ivanov on 18/05/16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import "CKController.h"
#import "AudioController+Export.h"
#import "AudioController+Import.h"
#import "AudioItem+Import.h"
#import "Global.h"
#import "Localized.h"
#import "Push.h"

#import "VKHelper.h"
#import "UIAccessoryView.h"
#import "UIImage+Effects.h"
#import "UIViewController+Stereo.h"

#import "Dispatch+Convenience.h"
#import "SafariServices+Convenience.h"
#import "NSArray+Convenience.h"
#import "NSAttributedString+Convenience.h"
#import "NSFormatter+Convenience.h"
#import "NSObject+Convenience.h"
#import "UIActivityIndicatorView+Convenience.h"
#import "UIColor+Convenience.h"

@interface CKController ()
@property (strong, nonatomic) NSArray<Tone *> *tones;
@property (strong, nonatomic) NSArray<User *> *users;
@property (strong, nonatomic) NSArray<VKUser *> *vkUsers;
@end

@implementation CKController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (self.items)
		return;

	[self setItems:[NSArray new] animated:NO];

	[self startActivityIndication:UIActivityIndicatorViewStyleWhiteLarge message:[Localized waiting]];

	[self loadTones:^{
		[self stopActivityIndication];
	}];
}

- (void)loadTones:(void (^)(void))handler {
	[self loadItems:^(NSArray<Tone *> *tones, NSArray<User *> *users, NSArray<VKUser *> *vkUsers, NSTimeInterval activitiesExpirationInterval) {
		self.tones = tones;
		self.users = users;
		self.vkUsers = vkUsers;

		NSArray *items = [tones map:^id(Tone *tone) {
			return [AudioItem createWithTone:tone];
		}];

//		[self setItems:items animated:NO];

		[GCD main:^{
			[self setItems:items animated:YES];

			[self addCurrentActivities:activitiesExpirationInterval];

			if (handler)
				handler();
		}];
	}];
}

- (void)loadItems:(void (^)(NSArray<Tone *> *tones, NSArray<User *> *users, NSArray<VKUser *> *vkUsers, NSTimeInterval activitiesExpirationInterval))handler {
	if (handler)
		handler(Nil, Nil, Nil, 0.0);
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

	self.tones = Nil;
	self.users = Nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 */

- (NSString *)title:(AudioItem *)item {
	return item.description;
}

- (VKUser *)getVKUser:(AudioItem *)item {
	Tone *tone = self.tones[[self.items first:^BOOL(id obj) {
		return obj == item;
	}]];
	User *user = [self.users firstObject:^BOOL(User *obj) {
		return [obj.record.creatorUserRecordID.recordName isEqualToString:tone.record.creatorUserRecordID.recordName];
	}];
	if (user.title.length)
		return Nil;

	VKUser *vkUser = [self.vkUsers firstObject:^BOOL(VKUser *obj) {
		return obj.id.integerValue == user.vkUserID;
	}];

	return vkUser;
}

- (NSAttributedString *)attributedSubtitle:(AudioItem *)item font:(UIFont *)font {
	Tone *tone = self.tones[[self.items first:^BOOL(id obj) {
		return obj == item;
	}]];
	User *user = [self.users firstObject:^BOOL(User *obj) {
		return [obj.record.creatorUserRecordID.recordName isEqualToString:tone.record.creatorUserRecordID.recordName];
	}];
	VKUser *vkUser = GLOBAL.vkEnabled ? [self.vkUsers firstObject:^BOOL(VKUser *obj) {
		return obj.id.integerValue == user.vkUserID;
	}] : Nil;

	NSMutableAttributedString *subtitle = [NSMutableAttributedString attributedStringWithString:[[[VKHelper instance] wakeUpSession].userId isEqualToString:VK_USER_ID] ? [tone.record.creationDate descriptionForDateAndTime:NSDateFormatterShortStyle] : item.segment.description];
	[subtitle appendAttributedString:[[NSAttributedString alloc] initWithString:STR_SPACE]];
	[subtitle appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ ", [Localized times:tone.exportCount]] attributes:@{ NSBackgroundColorAttributeName : [UIColor lightGrayColor], NSForegroundColorAttributeName : [UIColor whiteColor] }]];
	if (user.title.length) {
		[subtitle appendAttributedString:[[NSAttributedString alloc] initWithString:STR_SPACE]];
		[subtitle appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ ", user.title] attributes:@{ NSBackgroundColorAttributeName : [GLOBAL globalTintColor], NSForegroundColorAttributeName : [UIColor whiteColor] }]];
	} else if ([vkUser fullName].length) {
		[subtitle appendAttributedString:[[NSAttributedString alloc] initWithString:STR_SPACE]];
		[subtitle appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ ", [vkUser fullName]] attributes:@{ NSBackgroundColorAttributeName : [UIColor color:HEX_VK_BLUE], NSForegroundColorAttributeName : [UIColor whiteColor] }]];
	}
	[subtitle appendAttributedString:[[NSAttributedString alloc] initWithString:STR_DOT attributes:@{ NSForegroundColorAttributeName : [UIColor clearColor] }]];

	return subtitle;
}

- (NSString *)detail:(AudioItem *)item time:(NSTimeInterval)time {
	return [super detail:item time:(time == NSTimeIntervalSince1970 ? item.segment.endTime : time) - item.segment.startTime];
}

- (float)progress:(AudioItem *)item time:(NSTimeInterval)time {
	return time == NSTimeIntervalSince1970 ? 1.0 : (time - item.segment.startTime) / (item.segment.endTime - item.segment.startTime);
}

- (NSArray *)accessoryImages:(AudioItem *)item {
	VKUser *vkUser = GLOBAL.vkEnabled ? [self getVKUser:item] : Nil;

	return [NSArray arrayWithObject:[vkUser fullName] ? [UIImage originalImage:IMG_USER_LINE] : Nil withObject:[UIImage originalImage:IMG_ADD]];
}

- (void)accessoryImageWithIndex:(NSUInteger)index tappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	AudioItem *item = [self itemAtIndex:indexPath.row];

	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	UIAccessoryView *view = cls(UIAccessoryView, cell.accessoryView);
	if (view.views.count == 3 && index == 1) {
		VKUser *vkUser = [self getVKUser:item];

		[self presentSafariWithURL:vkUser.url];
	} else {
		if (item.assetURL)
			[self cacheAudioItem:item completion:^(NSURL *url) {
				[self presentSheet:item from:cls(UIAccessoryView, [self.tableView cellForRowAtIndexPath:indexPath].accessoryView).views.lastObject completion:^(BOOL success) {
					[self performSegueWithIdentifier:GUI_SELECT sender:item];
				}];
			}];
		else if (GLOBAL.vkEnabled)
			[item lookupInVK:^(VKAudioItem *vkAudioItem) {
				if (vkAudioItem)
					[self cacheAudioItem:item completion:^(NSURL *url) {
						[self presentSheet:item from:cls(UIAccessoryView, [self.tableView cellForRowAtIndexPath:indexPath].accessoryView).views.lastObject completion:^(BOOL success) {
							[self performSegueWithIdentifier:GUI_SELECT sender:item];
						}];
					}];
				else
					[GCD main:^{
						[self presentITunesStoreAlert:item];

						[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
					}];
			}];
		else {
			[self presentITunesStoreAlert:item];

			[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
	}
}

- (UIImage *)playImage:(AudioItem *)item {
	return __screenshot ? [super playImage:item] : [item.artwork imageWithSize:AudioItemArtworkSize mode:UIImageScaleAspectFit];//item.image
//		? [item.image imageWithSize:AudioItemArtworkSize]
//		: [super playImage:item];
}

- (UIImage *)stopImage:(AudioItem *)item {
	return item.image
		? [UIImage imageWithImages:[NSArray arrayWithObject:[[item.image imageWithSize:AudioItemArtworkSize mode:UIImageScaleAspectFit] imageByApplyingExtraLightEffect] withObject:[UIImage originalImage:IMG_STOP]]]
		: [super stopImage:item];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	AudioItem *item = [self itemAtIndex:indexPath.row];
	if (item.assetURL || item.mediaItem || (!GLOBAL.vkEnabled && [[MPMusicPlayerController class] instancesRespondToSelector:@selector(setQueueWithStoreIDs:)]))
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	else if (GLOBAL.vkEnabled)
		[item lookupInVK:^(VKAudioItem *vkAudioItem) {
			if (vkAudioItem)
				[GCD main:^{
					[super tableView:tableView didSelectRowAtIndexPath:indexPath];
				}];
			else
				[GCD main:^{
					[self presentITunesStoreAlert:item];

					[tableView deselectRowAtIndexPath:indexPath animated:YES];
				}];
		}];
	else {
		[self presentITunesStoreAlert:item];

		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:GUI_SELECT])
		self.selectedItem = sender;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[[VKHelper instance] wakeUpSession].userId isEqualToString:VK_USER_ID];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle != UITableViewCellEditingStyleDelete)
		return;

	AudioItem *item = [self itemAtIndex:indexPath.row];

	[self.player stopItem:item];

	[self startActivityIndication:UIActivityIndicatorViewStyleWhiteLarge message:[Localized waiting]];

	[self.tones[indexPath.row] deleteFromPublicCloudDatabase:^(BOOL deleted) {
		if (deleted)
			[self loadTones:^{
				[self stopActivityIndication];
			}];
		else
			[self stopActivityIndication];
	}];
}

- (void)tableView:(UITableView *)tableView swipeAccessoryButtonPushedForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if (!cell)
		return;

	Tone *tone = idx(self.tones, indexPath.row);
	if (!tone)
		return;

	[self startActivityIndication:UIActivityIndicatorViewStyleWhiteLarge message:[Localized waiting]];

	Push *push = [Push createWithTone:tone];
	[push update:^(Push *savedObject0) {
		[GCD main:^{
			[self stopActivityIndication];

			if (!savedObject0)
				return;

			[self presentAlertWithTitle:tone.description message:Nil cancelActionTitle:[Localized cancel] destructiveActionTitle:Nil otherActionTitles:@[ [Localized feature] ] completion:^(UIAlertController *instance, NSInteger index) {
				if (index == NSNotFound)
					return;

				[self startActivityIndication:UIActivityIndicatorViewStyleWhiteLarge message:[Localized waiting]];

				push.state++;
				[push update:^(__kindof CKObjectBase *savedObject1) {
					[GCD main:^{
						[self stopActivityIndication];

						if (!savedObject1)
							return;

						[tableView setEditing:NO animated:YES];
					}];
				}];
			}];
		}];
	}];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (![self tableView:tableView canEditRowAtIndexPath:indexPath])
		return Nil;

	__block CKController *__self = self;
	return @[ [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:[Localized delete] handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
		[__self tableView:__self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
	}], [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:[Localized feature] handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
		[__self tableView:__self.tableView swipeAccessoryButtonPushedForRowAtIndexPath:indexPath];
	}] ];
}

@end
