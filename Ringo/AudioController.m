//
//  AudioController.m
//  Ringo
//
//  Created by Alexander Ivanov on 07.07.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import "AudioController.h"
#import "AudioItem+Import.h"
#import "Global.h"

#import "UIAccessoryView.h"
#import "UIImage+Convenience.h"

#import "Dispatch+Convenience.h"
#import "NSFormatter+Convenience.h"
#import "UIColor+Convenience.h"
#import "UINavigationController+Convenience.h"
#import "UITableView+Convenience.h"

@interface AudioController ()
@property (strong, nonatomic) MPMusicPlayerController *musicPlayer;

@property (strong, nonatomic) AudioPlayer *player;

@property (strong, nonatomic, readonly) UIColor *tintColor;

//@property (strong, nonatomic) UIImage *playImage;
@property (strong, nonatomic) UIImage *stopImage;

@property (strong, nonatomic, readonly) UIImage *tempImage;
@property (strong, nonatomic, readonly) UIImage *songImage;
@property (strong, nonatomic, readonly) UIImage *toneImage;
@end

@implementation AudioController

- (MPMusicPlayerController *)musicPlayer {
	if (!_musicPlayer)
		_musicPlayer = [MPMusicPlayerController applicationMusicPlayer];

	return _musicPlayer;
}

@synthesize player = _player;
@synthesize tintColor = _tintColor;

- (AudioPlayer *)player {
	if (!_player)
		_player = [AudioPlayer new];

	return _player;
}

- (UIColor *)tintColor {
	if (!_tintColor)
		_tintColor = self.navigationController.navigationBar.barTintColor ? self.navigationController.navigationBar.barTintColor : GLOBAL.globalTintColor;

	return _tintColor;
}

- (void)setItems:(NSArray *)items animated:(BOOL)animated {
	_items = items;

	if (animated)
		[self.tableView reloadData];
}

- (AudioItem *)itemAtIndex:(NSUInteger)index {
	if (index == NSNotFound)
		return Nil;

	if (index >= self.items.count)
		return Nil;

	return self.items[index];
}

- (NSAttributedString *)attributedTitle:(AudioItem *)item font:(UIFont *)font {
	return Nil;
}

- (NSString *)title:(AudioItem *)item {
	return item.title;
}

- (NSAttributedString *)attributedSubtitle:(AudioItem *)item font:(UIFont *)font {
	return Nil;
}

- (NSString *)subtitle:(AudioItem *)item {
	return item.artist;
}

- (NSString *)detail:(AudioItem *)item time:(NSTimeInterval)time {
	if (DBL_EQUALS(time, NSTimeIntervalSince1970))
		time = item.duration;

	return isfinite(time) ? [[NSDateComponentsFormatter mmssFormatter] stringFromTimeInterval:time] : Nil;
}

- (float)progress:(AudioItem *)item time:(NSTimeInterval)time {
	return time / item.duration;
}

- (AudioSegment *)segment:(AudioItem *)item {
	return item.segment;
}

- (NSInteger)numberOfLoops {
	return 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
//	self.tableView.estimatedRowHeight = 44.0;
//	self.tableView.rowHeight = UITableViewAutomaticDimension;

	self.tableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	self.player = Nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.tabBarController.tabBar.barTintColor = self.navigationController.navigationBar.barTintColor;

	self.navigationController.navigationBar.progressView.tintColor = [UIColor color:HEX_IOS_LIGHT_GRAY];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[self.player stopItem:Nil];
}

#pragma mark - Table view data source

- (NSArray *)accessoryImages:(AudioItem *)item {
	return Nil;
}

- (void)accessoryImageWithIndex:(NSUInteger)index tappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	return;
}

- (UIImage *)playImage:(AudioItem *)item {
	return item.segment ? self.toneImage : self.songImage;	// [UIImage templateImage:IMG_PLAY];
}

- (UIImage *)stopImage:(AudioItem *)item {
	return [UIImage imageWithImages:arr__(self.tempImage, [[UIImage templateImage:IMG_STOP] imageWithTintColor:self.navigationController.navigationBar.barTintColor])];	// [UIImage templateImage:IMG_STOP];
}

- (IBAction)accessoryButtonTapped:(UIControl *)sender {
	if (sender.tag != NSNotFound)
		[self accessoryImageWithIndex:sender.tag tappedForRowWithIndexPath:[self.tableView indexPathForNullableCell:cls(UITableViewCell, sender.superview.superview)]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	AudioItem *item = [self itemAtIndex:indexPath.row];

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GUI_CELL_ID forIndexPath:indexPath];

	cell.textLabel.attributedText = [self attributedTitle:item font:cell.textLabel.font];
	if (!cell.textLabel.attributedText.length)
		cell.textLabel.text = [self title:item];

	cell.detailTextLabel.attributedText = [self attributedSubtitle:item font:cell.detailTextLabel.font];
	if (!cell.detailTextLabel.attributedText.length)
		cell.detailTextLabel.text = [self subtitle:item];

	NSString *text = Nil;
	UIColor *textColor = Nil;
	if ([self.player isPlayingItem:item]) {
		text = [self detail:item time:self.player.currentTime];
		textColor = self.tintColor;
		cell.imageView.image = self.stopImage;//[self stopImage:item];
		cell.imageView.tintColor = self.tintColor;
	} else {
		text = [self detail:item time:NSTimeIntervalSince1970];
		textColor = [UIColor color:HEX_IOS_DARK_GRAY];
		cell.imageView.image = [self playImage:item];
		if (!cell.imageView.image) {
			cell.imageView.image = item.segment ? self.toneImage : self.songImage;	// [[UIImage templateImage:IMG_PLAY] imageWithSize:AudioItemArtworkSize mode:0];

			[item cacheArtwork:^(UIImage *artwork) {
				if (artwork)
					[GCD main:^{
						[tableView cellForRowAtIndexPath:indexPath].imageView.image = [artwork imageWithSize:AudioItemArtworkSize mode:UIImageScaleAspectFit];
					}];
			}];
		}
		cell.imageView.tintColor = [UIColor color:HEX_IOS_DARK_GRAY];
	}
	
	NSArray *accessoryImages = [self accessoryImages:item];
	UIAccessoryView *view = cls(UIAccessoryView, cell.accessoryView);
	if (!view/* || cls(UIAccessoryView, cell.accessoryView).views.count != accessoryImages.count + 1*/) {
		view = [[UIAccessoryView alloc] initWithFrame:cell.bounds];
		[view addTarget:self action:@selector(accessoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		cell.accessoryView = view;
	}
	[view setItems:[arr_([text labelWithSize:CGSizeMake(36.0, 0.0)]) arrayByAddingObjectsFromNullableArray:accessoryImages] adjustWidth:YES];
	cell.accessoryView.tag = indexPath.row;

	UILabel *label = cls(UILabel, idx(cls(UIAccessoryView, cell.accessoryView).views, 0));
	label.text = text;
	label.textColor = textColor;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	AudioItem *item = [self itemAtIndex:indexPath.row];
	AudioSegment *segment = [self segment:item];

	if (item && ![self.player stopItem:item segment:segment]) {
//		self.playImage = [self playImage:item];
		self.stopImage = [self stopImage:item];

		[self.player playItem:item segment:segment numberOfLoops:[self numberOfLoops] handler:^(NSTimeInterval currentTime) {
			[GCD main:^{
				UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

				NSString *text = Nil;
				UIColor *textColor = Nil;
				if (currentTime != NSTimeIntervalSince1970) {
					text = [self detail:item time:currentTime];
					textColor = self.tintColor;
					cell.imageView.image = self.stopImage;
					cell.imageView.tintColor = self.tintColor;
				} else {
					text = [self detail:item time:NSTimeIntervalSince1970];
					textColor = [UIColor color:HEX_IOS_DARK_GRAY];
					cell.imageView.image = [self playImage:item];//self.playImage;
					if (!cell.imageView.image) {
						cell.imageView.image = item.segment ? self.toneImage : self.songImage;	// [UIImage templateImage:IMG_PLAY];

						[item cacheArtwork:^(UIImage *artwork) {
							if (artwork)
								[GCD main:^{
									cell.imageView.image = [artwork imageWithSize:AudioItemArtworkSize mode:UIImageScaleAspectFit];
								}];
						}];
					}
					cell.imageView.tintColor = [UIColor color:HEX_IOS_DARK_GRAY];
				}
				
				UILabel *label = cls(UILabel, idx(cls(UIAccessoryView, cell.accessoryView).views, 0));
				label.text = text;
				label.textColor = textColor;
				
				[cell layoutSubviews];
				
				[self.navigationController.navigationBar setProgress:[self progress:item time:currentTime] animated:YES];
			}];
		}];
	} else {
//		self.playImage = Nil;
		self.stopImage = Nil;
	}

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

__synthesize(UIImage *, tempImage, [[[[UIImage imageNamed:IMG_RINGO_128] imageWithBackground:[UIColor whiteColor]] imageByApplyingExtraLightEffect] imageWithSize:AudioItemArtworkSize mode:UIImageScaleAspectFit]);
__synthesize(UIImage *, songImage, [UIImage imageWithImages:arr__(self.tempImage, [[UIImage templateImage:IMG_MUSIC_LINE] imageWithTintColor:[UIColor whiteColor]])])
__synthesize(UIImage *, toneImage, [UIImage imageWithImages:arr__(self.tempImage, [[UIImage templateImage:IMG_BELL_LINE] imageWithTintColor:[UIColor whiteColor]])])

@end
