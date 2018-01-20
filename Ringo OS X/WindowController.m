//
//  WindowController.m
//  Ringtonic
//
//  Created by Alexander Ivanov on 13/07/16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import "WindowController.h"
#import "ViewController.h"

#import "AVAsset+Export.h"
#import "AVAudioSegmentPlayer.h"
#import "NSWorkspace+Ex.h"

#import "CoreMedia+Convenience.h"
#import "NSFileManager+Convenience.h"
#import "NSFormatter+Convenience.h"
#import "NSObject+Convenience.h"
#import "NSString+Convenience.h"

@interface WindowController ()
@property (strong, nonatomic, readonly) ViewController *vc;

@property (weak) IBOutlet NSButtonCell *playButton;

@property (strong, nonatomic) AVAudioSegmentPlayer *player;
@end

@implementation WindowController

- (ViewController *)vc {
	return cls(ViewController, self.contentViewController);
}

- (void)windowDidLoad {
	[super windowDidLoad];

	__weak WindowController *__self = self;
	[self.vc setTimeChange:^{
		[__self.player setSegmentStart:__self.vc.startTime andSegmentEnd:__self.vc.endTime];
	}];
}

#warning Export with AVAssetWriter!
#warning Export directly to iTunes!

- (BOOL)isPlaying {
	return self.player.isPlaying;
}

- (void)play {
	[self stop];

	self.player = [AVAudioSegmentPlayer playerWithContentsOfURL:cls(AVURLAsset, self.vc.asset).URL];
	[self.player setSegmentStart:self.vc.startTime andSegmentEnd:self.vc.endTime];

	__weak WindowController *__self = self;
	[self.player setStatusChange:^(AVAudioSegmentPlayer *sender) {
		__self.playButton.title = sender.isPlaying ? @"Stop" : @"Play";
	}];
	[self.player setTimeChange:^(AVAudioSegmentPlayer *sender) {

	}];

	[self.player play];
}

- (void)stop {
	[self.player stop];

	self.player = Nil;
}

- (IBAction)playAction:(NSButtonCell *)sender {
	if ([self isPlaying])
		[self stop];
	else
		[self play];
}

- (IBAction)exportAction:(NSButtonCell *)sender {
	AVAsset *asset = self.vc.asset;
	if (!asset)
		return;

	NSString *description = [asset metadataDescription];
	description = [description stringByApplyingTransform:NSStringTransformToLatin];
	description = [description stringByApplyingTransform:NSStringTransformStripCombiningMarks];
	NSURL *url = [[[NSFileManager URLForDirectory:NSMusicDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@ (%@ - %@)", description, [[NSDateComponentsFormatter mmssAbbreviatedFormatter] stringFromTimeInterval:self.vc.startTime], [[NSDateComponentsFormatter mmssAbbreviatedFormatter] stringFromTimeInterval:self.vc.endTime]]] URLByAppendingPathExtension:@"m4r"];
	if ([url isExistingItem])
		[url removeItem];

	self.window.toolbar.items.lastObject.enabled = NO;
#warning Write metadata!
	[asset exportAudioWithSettings:[AVAsset settingsMPEG4AACStereo] timeRange:CMTimeRangeFromTimeIntervalToTimeInterval(self.vc.startTime, self.vc.endTime) metadata:asset.metadata to:url handler:^(double progress) {
		if (progress == 1.0)
			[GCD main:^{
				self.window.toolbar.items.lastObject.enabled = YES;

				[[NSWorkspace sharedWorkspace] activateFileViewerSelectingURL:url];
			}];
	}];
}

@end
