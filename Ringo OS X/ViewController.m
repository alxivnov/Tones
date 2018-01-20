//
//  ViewController.m
//  Ringo OS X
//
//  Created by Alexander Ivanov on 06.01.16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import "ViewController.h"

#import "AVAsset+Export.h"
#import "CGWaveform.h"
#import "NSImage+Ex.h"
#import "NSView+Ex.h"

#import "NSFileManager+iCloud.h"
#import "NSObject+Convenience.h"
#import "UISlider+Convenience.h"

@interface ViewController ()
@property (strong, nonatomic) NSString *draggingTitle;

@property (weak) IBOutlet NSSlider *startSlider;
@property (weak) IBOutlet NSPassthroughSlider *endSlider;
@property (weak) IBOutlet NSScrollView *waveformView;
@end

@implementation ViewController

- (void)setAsset:(AVAsset *)asset {
	_asset = asset;

	self.view.window.toolbar.items.lastObject.enabled = NO;
	[asset readWithSettings:[AVAsset settingsLinearPCMMono] handler:^(NSData *data) {
		NSImage *image = [[CGWaveform waveformFromData:data frame:self.view.frame flag:YES] imageWithColor:[NSColor redColor]];
		[GCD main:^{
			self.waveformView.documentView = [image imageView];
			[self.waveformView.documentView scrollPoint:NSMakePoint(0.0 - self.waveformView.contentInsets.left, 0.0)];

			self.view.window.toolbar.items.lastObject.enabled = YES;
		}];
	}];
}

- (NSTimeInterval)startTime {
	return self.asset.seconds / cls(NSImageView, self.waveformView.documentView).frame.size.width * (self.waveformView.documentVisibleRect.origin.x + self.waveformView.contentInsets.left) + self.startSlider.value;
}

- (NSTimeInterval)endTime {
	return self.asset.seconds / cls(NSImageView, self.waveformView.documentView).frame.size.width * (self.waveformView.documentVisibleRect.origin.x + self.waveformView.contentInsets.left) + self.endSlider.value;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	// Do any additional setup after loading the view.
	
	[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:Nil handler:^(NSURL *url) {
		url = [url URLByAppendingPathComponent:@"Documents"];
		
		NSArray<NSURL *> *files = [url allFiles];
		for (NSURL *file in files)
			[file.lastPathComponent log:Nil];
	}];

#warning Set extensions according to the supported file types.
	cls(NSURLDraggingDestination, self.view).borderColor = [NSColor redColor];
	cls(NSURLDraggingDestination, self.view).pathExtensions = @[ @"mp3", @"m4a" ];
#warning Hide slider tracks.
}

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];

	// Update the view, if already loaded.
}

- (void)viewDidAppear {
	[super viewDidAppear];

	[self.waveformView.contentView beginPostingBoundsChangedNotificationsForObserver:self selector:@selector(scrollAction:)];
}

- (void)viewWillDisappear {
	[super viewWillDisappear];

	[self.waveformView.contentView endPostingBoundsChangedNotificationsForObserver:self];
}

- (IBAction)scrollAction:(NSNotification *)sender {
	if (self.timeChange)
		self.timeChange();
}

- (IBAction)sliderAction:(__kindof NSSlider *)sender {
	if (self.timeChange)
		self.timeChange();
}

#warning Set background image!
- (void)urlDraggingEntered:(NSArray<NSURL *> *)urls {
	if (!urls.count)
		return;

	self.draggingTitle = self.view.window.title;

	self.view.window.title = [[AVURLAsset assetWithURL:urls.firstObject] metadataDescription];
}

- (void)urlDraggingExited:(NSArray<NSURL *> *)urls {
	self.view.window.title = self.draggingTitle;
}

- (void)urlDraggingEnded:(NSArray<NSURL *> *)urls {
//	self.view.window.title = self.draggingTitle;
}

- (void)performURLDragOperation:(NSArray<NSURL *> *)urls {
	self.asset = [AVURLAsset assetWithURL:urls.firstObject];

	self.view.window.title = [self.asset metadataDescription];
}

@end
