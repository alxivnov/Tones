//
//  PlayerController.m
//  Ringo
//
//  Created by Alexander Ivanov on 04.10.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "PlayerController.h"
#import "Global.h"

#import "AVPlayer+Convenience.h"

@interface PlayerController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButton;

@property (strong, nonatomic) AVAudioSegmentPlayer *player;
@end

@implementation PlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

//	self.navigationController.navigationBar.progressView.tintColor = [UIColor color:HEX_IOS_LIGHT_GRAY];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

	self.player = Nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 */

- (AVAudioPlayer *)player {
	if (!_player) {
		_player = [AVAudioSegmentPlayer playerWithContentsOfURL:self.selectedItem.assetURL];
		_player.numberOfLoops = -1;

		__weak PlayerController *__self = self;
		_player.statusChange = ^(AVAudioSegmentPlayer *sender) {
			__self.playButton.image = [UIImage templateImage:sender.playing ? IMG_STOP : IMG_PLAY];
			
			[__self playerDidChangeStatus:sender.isPlaying];
			
			if (!sender.prepared)
				sender.currentTime = sender.segmentStart;
		};
		_player.timeChange = ^(AVAudioSegmentPlayer *sender) {
			[__self playerDidChangeTime:sender.currentTime];
		};
	}
	
	return _player;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	AudioSegment *segment = self.selectedItem.segment && self.selectedItem.segment.endTime <= self.selectedItem.duration ? self.selectedItem.segment : [AudioSegment createWithDuration:self.selectedItem.duration];

	[self.player setSegmentStart:segment.startTime andSegmentEnd:segment.endTime];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[self.player stop];
}

- (IBAction)playButtonAction:(UIBarButtonItem *)sender {
	if (self.player.playing)
		[self.player pause];
	else
		[self.player play];
}

- (IBAction)rwButtonAction:(NSTimeInterval)interval {
	if ([self.player segmentContainsTime:self.player.currentTime] == NSOrderedSame) {
		NSTimeInterval time = self.player.currentTime - interval;
		
		self.player.currentTime = [self.player segmentContainsTime:time] == NSOrderedSame ? time : self.player.segmentStart;
	} else
		self.player.currentTime = self.player.segmentEnd - interval;
	
	[self playerDidChangeTime:self.player.currentTime];
}

- (IBAction)ffButtonAction:(NSTimeInterval)interval {
	if ([self.player segmentContainsTime:self.player.currentTime] == NSOrderedSame) {
		NSTimeInterval time = self.player.currentTime + interval;
		
		self.player.currentTime = [self.player segmentContainsTime:time] == NSOrderedSame ? time : self.player.segmentEnd;
	} else
		self.player.currentTime = self.player.segmentStart + interval;

	[self playerDidChangeTime:self.player.currentTime];
}

- (IBAction)rw15ButtonAction:(UIBarButtonItem *)sender {
	[self rwButtonAction:15.0];
}

- (IBAction)rw5ButtonAction:(UIBarButtonItem *)sender {
	[self rwButtonAction:5.0];
}

- (IBAction)ff15ButtonAction:(UIBarButtonItem *)sender {
	[self ffButtonAction:15.0];
}

- (IBAction)ff5ButtonAction:(UIBarButtonItem *)sender {
	[self ffButtonAction:5.0];
}

- (NSTimeInterval)startTime {
	return self.player.segmentStart;
}

- (NSTimeInterval)endTime {
	return self.player.segmentEnd;
}

- (NSTimeInterval)duration {
	return self.player.segmentEnd - self.player.segmentStart;
}

- (NSTimeInterval)currentTime {
	return self.player.currentTime;
}

- (void)setSegmentStart:(NSTimeInterval)start andSegmentEnd:(NSTimeInterval)end {
	[self.player setSegmentStart:start andSegmentEnd:end];
}

- (void)playerDidChangeStatus:(BOOL)isPlaying {
//	[GCD main:^{
//		[self.navigationController.navigationBar setProgress:isPlaying ? ([self currentTime] - [self startTime]) / [self duration] : 0.0];
//	}];
}

- (void)playerDidChangeTime:(NSTimeInterval)time {
//	[GCD main:^{
//		[self.navigationController.navigationBar setProgress:(time - [self startTime]) / [self duration]];
//	}];
}

@end
