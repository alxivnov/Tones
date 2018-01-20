//
//  AudioController+Import.m
//  Ringo
//
//  Created by Alexander Ivanov on 02.11.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "AudioController+Import.h"
#import "AudioItem+Import.h"
#import "Global.h"
#import "Localized.h"

#import "NSObject+Convenience.h"
#import "UIActivityIndicatorView+Convenience.h"
#import "UIAlertController+Convenience.h"
#import "UIApplication+Convenience.h"
#import "UIColor+Convenience.h"

#import <Crashlytics/Answers.h>

@implementation AudioController (Import)

- (void)presentITunesStoreAlert:(AudioItem *)audioItem {
	[audioItem lookup:^(AFMediaItem *mediaItem) {
		[GCD main:^{
			[self presentAlertWithTitle:[mediaItem description] message:[Localized purchaseAndDownload] cancelActionTitle:[Localized cancel] destructiveActionTitle:Nil otherActionTitles:mediaItem ? @[ [Localized openInITunesStore] ] : Nil configuration:^(UIAlertController *instance) {
				[instance.actions.firstObject setActionImage:[UIImage templateImage:IMG_MUSIC_LINE]];
				[instance.actions.firstObject setActionColor:[UIColor color:0xEF4DB7]];

				[instance.actions.lastObject setActionColor:[UIColor color:HEX_IOS_DARK_GRAY]];
			} completion:^(UIAlertController *instance, NSInteger index) {
				if (index != NSNotFound)
					[UIApplication openURL:[mediaItem.viewUrl URLByAppendingQueryDictionary:GLOBAL.affiliateInfo] inApp:kAppITunes];

				if (mediaItem)
					[Answers logCustomEventWithName:@"Affiliate Program" customAttributes:@{ @"Success" : index != NSNotFound ? @"YES" : @"NO", @"Preferred Localizations" : [[NSBundle mainBundle].preferredLocalizations componentsJoinedByString:STR_COMMA], @"Name" : [mediaItem description] }];
			}];
		}];
	}];
}

- (void)cacheAudioItem:(AudioItem *)item completion:(void (^)(NSURL *))handler {
	if (!item.assetURL)
		return;

	[self startActivityIndication:UIActivityIndicatorViewStyleWhiteLarge message:[Localized waiting]];

	[item.assetURL cache:^(NSURL *url) {
		[GCD main:^{
			[self stopActivityIndication];

			if (handler)
				handler(url);
		}];
	}];
	
	[item cacheArtwork:Nil];
}

@end
