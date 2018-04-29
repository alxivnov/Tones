//
//  TonesController.m
//  Ringo
//
//  Created by Alexander Ivanov on 23.05.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import "TonesController.h"
#import "Global.h"
#import "Localized.h"

#import "UIFont+Modification.h"
#import "UIImage+Convenience.h"
//#import "VKHelper.h"

#import "NSAttributedString+Convenience.h"
#import "NSFileManager+iCloud.h"
#import "UITableView+Convenience.h"
#import "UIView+Convenience.h"

#define IMG_RINGTONIC @"ringtonic-32"

#define IMAGE_SIZE 48.0

@interface TonesController ()
@property (strong, nonatomic, readonly) UIImageView *image;
@property (strong, nonatomic) UILabel *label;

@property (strong, nonatomic) NSArray *tones;
@end

@implementation TonesController

__synthesize(UIImageView *, image, ({ UIImageView *x = [[UIImageView alloc] initWithImage:[UIImage originalImage:IMG_RINGTONIC]]; x.contentMode = UIViewContentModeScaleAspectFit; x; }))

- (NSArray *)items {
	if (!self.tones && !__screenshot)
		self.tones = [[[[NSFileManager URLForDirectory:NSDocumentDirectory] allFiles] query:^BOOL(NSURL *url) {
			return [url.pathExtension isEqualToString:EXT_M4R];
		}] map:^id(NSURL *url) {
			return [AudioItem createWithURLAsset:[AVURLAsset assetWithURL:url]];
		}];
	
	return self.tones;
}

- (void)setItems:(NSArray *)items animated:(BOOL)animated {
	self.tones = items;

	if (animated)
		[self.tableView reloadData];
}

- (AudioSegment *)segment:(AudioItem *)item {
	return Nil;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.navigationItem.titleView = self.image;

	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback mode:AVAudioSessionModeDefault options:0 error:Nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
/*
	if (self.label)
		return;

	NSInteger userID = [[[VKHelper instance] wakeUpSession].userId integerValue];
	if (!userID)
		return;

	[VKHelper getUsers:@[ @(userID) ] fields:Nil handler:^(NSArray<VKUser *> *users) {
		if (!users.firstObject.first_name.length)
			return;

		self.label = [[UILabel alloc] initWithFrame:self.navigationItem.titleView.frame];
		self.label.adjustsFontSizeToFitWidth = YES;
		self.label.minimumScaleFactor = 0.5;
		self.label.numberOfLines = 2;
		self.label.text = [Localized hi:users.firstObject.first_name];
		self.label.textAlignment = NSTextAlignmentCenter;
		self.label.textColor = self.navigationController.navigationBar.tintColor;
		self.label.hidden = YES;

		[GCD main:^{
			__weak __typeof(self) __self = self;

			[self.navigationItem.titleView setHidden:YES duration:1.0 completion:^(BOOL finished) {
				__self.navigationItem.titleView = __self.label;

				[__self.navigationItem.titleView setHidden:NO duration:1.0 completion:^(BOOL finished) {
					[__self.navigationItem.titleView setHidden:YES duration:1.0 delay:1.0 animations:Nil completion:^(BOOL finished) {
						__self.navigationItem.titleView = __self.image;

						[__self.navigationItem.titleView setHidden:NO duration:1.0 completion:Nil];
					}];
				}];
			}];
		}];
	}];
*/
}

#pragma mark - Table view data source

- (NSInteger)numberOfLoops {
	return -1;
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

- (NSAttributedString *)attributedTitle:(AudioItem *)item font:(UIFont *)font {
	if (!item.numberOfChannels || item.numberOfChannels > 1 || !font)
		return Nil;

	NSString *mono = [NSString stringWithFormat:@" %@ ", [[Localized mono] lowercaseString]];
	NSMutableAttributedString *title = [NSMutableAttributedString attributedStringWithString:[[self title:item] stringByAppendingFormat:@" %@", mono] attributes:Nil];
	[title setAttributes:@{ NSFontAttributeName : [font bold], NSBackgroundColorAttributeName : [GLOBAL globalTintColor], NSForegroundColorAttributeName : [UIColor whiteColor] } range:NSMakeRange(title.length - mono.length, mono.length)];
	[title appendAttributedString:[[NSAttributedString alloc] initWithString:STR_DOT attributes:@{ NSForegroundColorAttributeName : [UIColor clearColor] }]];
	return title;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[self.player stopItem:Nil];

		AudioItem *item = [self itemAtIndex:indexPath.row];

		NSURL *url = item.assetURL;
		if (![url removeItem])
			return;

		if (url.lastPathComponent.length)
			[[NSURL URLWithString:url.lastPathComponent ubiquityContainer:Nil] removeItem];

		NSArray *items = [self.items arrayByRemovingObjectAtIndex:indexPath.row];
		if (items.count == self.items.count)
			return;

		NSUInteger count = self.items.count;

		[self setItems:items animated:NO];

		if (self.items.count == count - 1) {
			NSUInteger numberOfSections = [self numberOfSectionsInTableView:tableView];
			[tableView beginUpdates];
			[tableView deleteRowAtIndexPath:indexPath];
			if (tableView.numberOfSections > numberOfSections)
				[tableView deleteSection:0];
			else if (tableView.numberOfSections < numberOfSections)
				[tableView insertSection:0];
			[tableView endUpdates];
		} else
			[tableView reloadData];
	}
}

@end
