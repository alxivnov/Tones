//
//  OnlineController.m
//  Ringo
//
//  Created by Alexander Ivanov on 30.06.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import "OnlineController.h"
#import "Global.h"
#import "Localized.h"
#import "Tone.h"

#import "UIViewController+Answers.h"
#import "VKHelper.h"

#import "Dispatch+Convenience.h"
#import "NSArray+Convenience.h"
#import "NSObject+Convenience.h"
#import "UIActivityIndicatorView+Convenience.h"
#import "UITableView+Convenience.h"

@interface OnlineController ()
@property (strong, nonatomic) NSArray *tones;
@end

@implementation OnlineController

- (NSArray *)items {
	if (!_tones)
		_tones = [self.selectedItem.tones map:^id(Tone *tone) {
			AudioItem *item = [[AudioItem alloc] initWithArtist:tone.artist title:tone.title album:tone.album];
			[self.selectedItem copyTo:item];
			item.segment = [[AudioSegment alloc] initWithStartTime:tone.startTime endTime:tone.endTime duration:item.duration];
			return item;
		}];

	return _tones;
}

- (NSString *)loggingName {
	return @"Segments";
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self startLogging];
	
	self.navigationItem.title = [self.selectedItem description];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[self endLogging];
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

- (NSArray *)accessoryImages:(AudioItem *)item {
	return arr_([UIImage originalImage:IMG_ADD]);
}

- (void)accessoryImageWithIndex:(NSUInteger)index tappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[self performSegueWithIdentifier:GUI_SELECT sender:[self itemAtIndex:indexPath.row]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
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
		if (deleted) {
			self.tones = [self.tones arrayByRemovingObjectAtIndex:indexPath.row];

			[GCD main:^{
				[tableView deleteRowAtIndexPath:indexPath];
			}];
		}

		[self stopActivityIndication];
	}];
}

@end
