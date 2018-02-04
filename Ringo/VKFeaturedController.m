//
//  VKFeaturedController.m
//  Ringo
//
//  Created by Alexander Ivanov on 22.10.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "VKFeaturedController.h"
#import "AudioController+Export.h"
#import "AudioController+Import.h"
#import "AudioItem+Import.h"
#import "Global.h"
#import "Localized.h"
#import "UIViewController+VKLog.h"

#import "UIImage+Convenience.h"
#import "VKHelper.h"

#import "Dispatch+Convenience.h"
#import "NSArray+Convenience.h"
#import "NSAttributedString+Convenience.h"
#import "NSCalendar+Convenience.h"
#import "NSObject+Convenience.h"
#import "UIActivityIndicatorView+Convenience.h"
#import "UITableView+Convenience.h"

#import <Crashlytics/Answers.h>

@interface VKFeaturedController ()
@property (assign, nonatomic) NSUInteger newPosts;

@property (strong, nonatomic) IBOutlet UIView *logInView;
@end

@implementation VKFeaturedController

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

+ (void)getPosts:(NSMutableArray<VKWallItem *> *)posts offset:(NSUInteger)offset count:(NSUInteger)count handler:(void (^)(NSArray<VKWallItem *> *))handler {
	[VKHelper getPosts:VK_GROUP_ID offset:offset count:count query:@"#ringtonic" handler:^(NSArray<VKWallItem *> *items) {
		[posts addObjectsFromArray:[items query:^BOOL(VKWallItem *obj) {
			return [obj.linkURLs any:^BOOL(NSURL *obj) {
				return [obj.absoluteString hasPrefix:URL_PHP] || [obj.absoluteString hasPrefix:URL_OLD];
			}] && obj.audioItems.count;
		}]];
		if (posts.count > count)
			[posts removeObjectsInRange:NSMakeRange(count, posts.count - count)];
		
		if (posts.count < count && items.count == count)
			[self getPosts:posts offset:offset + count count:count handler:handler];
		else if (handler)
			handler(posts);
	}];
}

static NSArray<VKWallItem *> *_posts;

+ (NSArray<VKWallItem *> *)getPosts:(void(^)(NSInteger))handler {
	if (!_posts)
		[self getPosts:[NSMutableArray arrayWithCapacity:GLOBAL.tonesCount] offset:0 count:GLOBAL.tonesCount handler:^(NSArray<VKWallItem *> *posts) {
			_posts = posts;

			if (_posts.count && !GLOBAL.firstFeaturedPostID)
				GLOBAL.firstFeaturedPostID = _posts.firstObject.ID;

			if (handler) {
				NSUInteger index = [_posts first:^BOOL(VKWallItem *obj) {
					return obj.ID == GLOBAL.firstFeaturedPostID;
				}];
				
				handler(index == NSNotFound ? 0 : index);
			}
		}];

	return _posts;
}

+ (NSInteger)newPosts {
	NSInteger first = [_posts first:^BOOL(VKWallItem *obj) {
		return obj.ID == GLOBAL.firstFeaturedPostID;
	}];

	return first == NSNotFound ? 0 : first;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self setup:[[VKHelper instance] wakeUpSession]];

	if (self.items)
		return;

//	[self setItems:[NSArray new] animated:NO];

//	[self startActivityIndication:UIActivityIndicatorViewStyleWhiteLarge message:[Localized waiting]];

	if (!_posts.count)
		return;

	self.newPosts = [self.navigationController.tabBarItem.badgeValue integerValue];

	self.navigationController.tabBarItem.badgeValue = Nil;
	GLOBAL.firstFeaturedPostID = _posts.firstObject.ID;

	[self startActivityIndication:UIActivityIndicatorViewStyleWhiteLarge message:[Localized waiting]];

	[GCD global:^{
//	[[self class] getPosts:[NSMutableArray arrayWithCapacity:TONES_COUNT] offset:0 count:TONES_COUNT handler:^(NSArray<VKWallItem *> *items) {
		NSArray *audioItems = [/*items*/_posts map:^id(VKWallItem *obj) {
			return [AudioItem createWithWallItem:obj];
		}];

		[GCD main:^{
			[self setItems:audioItems animated:YES];

			[self stopActivityIndication];
		}];

		[self addCurrentActivities:TIME_DAY];

//		[self stopActivityIndication];
//	}];
 	}];
}

- (void)setup:(VKAccessToken *)newToken {
	self.tableView.emptyState = newToken ? Nil : self.logInView;
	self.navigationItem.leftBarButtonItem.title = newToken ? [Localized logOut] : [Localized logIn];
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
	[self setup:newToken];
}

- (IBAction)leftBarButtonItemAction:(UIBarButtonItem *)sender {
	if ([[VKHelper instance] wakeUpSession]) {
		[VKSdk forceLogout];

		self.navigationItem.leftBarButtonItem.title = [Localized logIn];

		[self setItems:Nil animated:YES];

		[self.player stopItem:Nil];
	} else {
		[[VKHelper instance] authorize];
	}
}

- (NSString *)title:(AudioItem *)item {
	return [item description];
}

- (NSString *)subtitle:(AudioItem *)item {
	return [item.segment description];
}

- (NSString *)detail:(AudioItem *)item time:(NSTimeInterval)time {
	return [super detail:item time:(time == NSTimeIntervalSince1970 ? item.segment.endTime : time) - item.segment.startTime];
}

- (float)progress:(AudioItem *)item time:(NSTimeInterval)time {
	return time == NSTimeIntervalSince1970 ? 1.0 : (time - item.segment.startTime) / (item.segment.endTime - item.segment.startTime);
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
/*
- (NSArray *)accessoryImages:(AudioItem *)item {
	return arr_([UIImage originalImage:IMG_ADD]);
}
*/
- (void)accessoryImageWithIndex:(NSUInteger)index tappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	AudioItem *item = [self itemAtIndex:indexPath.row];
	if (item.assetURL && (GLOBAL.vkEnabled || item.mediaItem))
		[super accessoryImageWithIndex:index tappedForRowWithIndexPath:indexPath];
	else if (GLOBAL.vkEnabled)
		[item lookupInVK:^(VKAudioItem *vkAudioItem) {
			if (vkAudioItem)
				[self cacheAudioItem:item completion:^(NSURL *url) {
					[super accessoryImageWithIndex:index tappedForRowWithIndexPath:indexPath];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	AudioItem *item = [self itemAtIndex:indexPath.row];
	if ((item.assetURL && GLOBAL.vkEnabled) || item.mediaItem)
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

- (NSAttributedString *)attributedSubtitle:(AudioItem *)item font:(UIFont *)font {
	if ([self.items indexOfObject:item] >= self.newPosts)
		return Nil;

	NSMutableAttributedString *subtitle = [NSMutableAttributedString attributedStringWithString:[self subtitle:item]];

	[subtitle appendAttributedString:[[NSAttributedString alloc] initWithString:STR_SPACE]];
	[subtitle appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ ", [[Localized newTone] lowercaseString]] attributes:@{ NSBackgroundColorAttributeName : [UIColor lightGrayColor], NSForegroundColorAttributeName : [UIColor whiteColor] }]];
	[subtitle appendAttributedString:[[NSAttributedString alloc] initWithString:STR_DOT attributes:@{ NSForegroundColorAttributeName : [UIColor clearColor] }]];

	return subtitle;
}

- (IBAction)logInAction:(UIButton *)sender {
	[[VKHelper instance] authorize];
}

@end
