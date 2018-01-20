//
//  VKController.m
//  Ringo
//
//  Created by Alexander Ivanov on 07.07.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import "VKController.h"
#import "AudioController+Import.h"
#import "AudioItem+Import.h"
#import "Global.h"

#import "NSArray+Convenience.h"
#import "UIAccessoryView.h"
#import "UIViewController+Stereo.h"

@implementation VKController

#pragma mark - Table view data source

- (void)setItems:(NSArray *)items animated:(BOOL)animated {
	if ([items.firstObject isKindOfClass:[VKAudioItem class]])
		items = [items map:^id(VKAudioItem *item) {
			return [AudioItem createWithAudioItem:item];
		}];
	else if ([items.firstObject isKindOfClass:[VKWallItem class]])
		items = [items map:^id(VKWallItem *obj) {
			return [AudioItem createWithWallItem:obj];
		}];

	[super setItems:items animated:animated];
}

- (NSArray *)accessoryImages:(AudioItem *)item {
	return arr_([UIImage originalImage:IMG_ADD_VK]);
}

- (void)accessoryImageWithIndex:(NSUInteger)index tappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	AudioItem *item = [self itemAtIndex:indexPath.row];

	[self cacheAudioItem:item completion:^(NSURL *url) {
		[self presentSheet:item from:cls(UIAccessoryView, [self.tableView cellForRowAtIndexPath:indexPath].accessoryView).views.lastObject completion:^(BOOL success) {
			[self performSegueWithIdentifier:GUI_SELECT sender:item];
		}];
	}];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:GUI_SELECT])
		self.selectedItem = sender;
}

@end
