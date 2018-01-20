//
//  RegionController.m
//  Ringo
//
//  Created by Alexander Ivanov on 04.10.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "RegionController.h"
#import "RegionView.h"

#import "UIFont+Modification.h"

#import "NSFormatter+Convenience.h"
#import "UIColor+Convenience.h"
#import "UISlider+Convenience.h"

#define GUI_VERTICAL_MARGIN 44.0
#define IMG_THUMB_NORMAL @"thumb-normal"
#define IMG_THUMB_HIGHLIGHTED @"thumb-highlighted"

@interface RegionController ()
@property (strong, nonatomic) RegionView *regionView;

@property (strong, nonatomic) UILabel *startLabel;
@property (strong, nonatomic) UILabel *endLabel;
@property (strong, nonatomic) UILabel *durationLabel;
@property (strong, nonatomic) UILabel *playerLabel;

@property (strong, nonatomic) UIDoubleSlider *slider;
@end

@implementation RegionController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	
	self.selectedItem.segment = [[AudioSegment alloc] initWithStartTime:self.startTime endTime:self.endTime duration:self.selectedItem.duration];
}

- (CGRect)regionViewFrame {
	CGFloat x = [self locationForTime:self.startTime];
	CGFloat width = [self locationForTime:self.endTime] - x;
	CGFloat height = self.scrollView.frame.size.height - GUI_VERTICAL_MARGIN * 2.0;
	CGFloat y = (self.scrollView.frame.size.height - height) / 2.0;
	
	return isnan(x) || isnan(y) ? CGRectZero : CGRectMake(x + self.scrollView.frame.origin.x, y + self.scrollView.frame.origin.y, width, height);
}

- (RegionView *)regionView {
	if (!_regionView) {
		_regionView = [[RegionView alloc] initWithFrame:[self regionViewFrame]];
//		_regionView.backgroundColor = WA(255, 20);
		_regionView.userInteractionEnabled = NO;
		
		[self.view addSubview:_regionView];
	}
	
	return _regionView;
}

- (void)setupRegionView {
	self.regionView.frame = [self regionViewFrame];
}

- (UILabel *)labelWithFrame:(CGRect)frame textColor:(UIColor *)color {
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.textColor = color;

	[self.view addSubview:label];

	return label;
}

- (CGRect)startLabelFrame:(CGSize)size {
	CGFloat x = self.regionView.frame.origin.x - size.width / 2.0;
	CGFloat y = self.regionView.frame.origin.y - GUI_VERTICAL_MARGIN + (GUI_VERTICAL_MARGIN - size.height) / 2.0;

	return isnan(x) || isnan(y) ? CGRectZero : CGRectMake(x, y, size.width * 1.20, size.height);
}

- (UILabel *)startLabel {
	if (!_startLabel)
		_startLabel = [self labelWithFrame:[self startLabelFrame:CGSizeZero] textColor:self.regionView.tintColor];

	return _startLabel;
}

- (CGRect)endLabelFrame:(CGSize)size {
	CGFloat x = self.regionView.frame.origin.x + self.regionView.frame.size.width - size.width / 2.0;
	CGFloat y = self.regionView.frame.origin.y - GUI_VERTICAL_MARGIN + (GUI_VERTICAL_MARGIN - size.height) / 2.0;

	return isnan(x) || isnan(y) ? CGRectZero : CGRectMake(x, y, size.width * 1.20, size.height);
}

- (UILabel *)endLabel {
	if (!_endLabel)
		_endLabel = [self labelWithFrame:[self endLabelFrame:CGSizeZero] textColor:self.regionView.tintColor];

	return _endLabel;
}

- (CGRect)durationLabelFrame:(CGSize)size {
	CGFloat x = self.regionView.frame.origin.x + self.regionView.frame.size.width / 2.0 - size.width / 2.0;
	CGFloat y = self.regionView.frame.origin.y + self.regionView.frame.size.height + (GUI_VERTICAL_MARGIN - size.height) / 2.0;

	return isnan(x) || isnan(y) ? CGRectZero : CGRectMake(x, y, size.width * 1.20, size.height);
}

- (UILabel *)durationLabel {
	if (!_durationLabel)
		_durationLabel = [self labelWithFrame:[self durationLabelFrame:CGSizeZero] textColor:self.regionView.tintColor];

	return _durationLabel;
}

- (void)setupRegionLabels:(BOOL)frame {
	self.startLabel.text = [[NSDateComponentsFormatter mmssFormatter] stringFromTimeInterval:self.startTime];
	if (frame)
		self.startLabel.frame = [self startLabelFrame:[self.startLabel.attributedText size]];

	self.endLabel.text = [[NSDateComponentsFormatter mmssFormatter] stringFromTimeInterval:self.endTime];
	if (frame)
		self.endLabel.frame = [self endLabelFrame:[self.startLabel.attributedText size]];

	if (frame)
		self.endLabel.hidden = CGRectIntersectsRect(self.endLabel.frame, self.startLabel.frame);

	if (frame) {
		self.durationLabel.text = [[NSDateComponentsFormatter mmssFormatter] stringFromTimeInterval:self.duration];
		self.durationLabel.frame = [self durationLabelFrame:[self.durationLabel.attributedText size]];
		self.durationLabel.hidden = self.durationLabel.frame.size.width > self.regionView.frame.size.width / 2.0;
	}
}

- (CGRect)playerLabelFrame:(CGSize)size {
	CGFloat x = self.regionView.frame.origin.x + self.regionView.frame.size.width * self.regionView.value - size.width / 2.0;
	CGFloat y = self.regionView.frame.origin.y - GUI_VERTICAL_MARGIN + (GUI_VERTICAL_MARGIN - size.height) / 2.0;

	return isnan(x) || isnan(y) ? CGRectZero : CGRectMake(x, y, size.width * 1.20, size.height);
}

- (UILabel *)playerLabel {
	if (!_playerLabel)
		_playerLabel = [self labelWithFrame:[self playerLabelFrame:CGSizeZero] textColor:[UIColor whiteColor]/*WA(255, 60)*/];

	return _playerLabel;
}

- (void)setupPlayerLabel:(BOOL)frame {
	self.playerLabel.text = [[NSDateComponentsFormatter mmssFormatter] stringFromTimeInterval:self.currentTime];
	if (frame)
		self.playerLabel.frame = [self playerLabelFrame:[self.playerLabel.attributedText size]];

	if (frame)
		self.playerLabel.hidden = CGRectIntersectsRect(self.playerLabel.frame, self.startLabel.frame) || CGRectIntersectsRect(self.playerLabel.frame, self.endLabel.frame) || self.playerLabel.frame.origin.x < self.startLabel.frame.origin.x || self.playerLabel.frame.origin.x > self.endLabel.frame.origin.x;
}

- (CGRect)sliderFrame {
	CGFloat leftInset = (UISliderHeight - self.scrollView.contentInset.left - 1.0) / 2.0;
	CGFloat rightInset = (UISliderHeight - self.scrollView.contentInset.right - 1.0) / 2.0;
	return CGRectMake(0.0 + leftInset, self.regionView.frame.origin.y + self.regionView.frame.size.height + (GUI_VERTICAL_MARGIN - UISliderHeight) / 2.0, self.view.bounds.size.width - (leftInset + rightInset), UISliderHeight);
}

- (UIDoubleSlider *)slider {
	if (!_slider) {
		_slider = [[UIDoubleSlider alloc] initWithFrame:[self sliderFrame]];
		_slider.maximumValue = AUDIO_SEGMENT_LENGTH;
		_slider.startValue = 0.0;
		_slider.endValue = AUDIO_SEGMENT_LENGTH;

		[_slider hideTrack];
		[_slider setThumbImage:[UIImage originalImage:IMG_THUMB_NORMAL] andHighlightedImage:[UIImage originalImage:IMG_THUMB_HIGHLIGHTED]];
		
		[_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
		[_slider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
		[_slider addTarget:self action:@selector(sliderTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];

		[self.view addSubview:_slider];
	}

	return _slider;
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
	[self setSegmentStart:self.position + self.slider.startValue andSegmentEnd:self.position + self.slider.endValue];

	[self setupRegionView];
	self.regionView.value = (self.currentTime - self.startTime) / (self.endTime - self.startTime);
	[self setupRegionLabels:YES];
	[self setupPlayerLabel:YES];
}

- (IBAction)sliderTouchDown:(UISlider *)sender {
//	self.regionView.backgroundColor = WA(255, 10);
//	if (sender.tag)
//		self.endLabel.font = [self.startLabel.font bold];
//	else
//		self.startLabel.font = [self.endLabel.font bold];
//	self.durationLabel.font = [self.durationLabel.font bold];
}

- (IBAction)sliderTouchUp:(UISlider *)sender {
//	self.regionView.backgroundColor = WA(255, 20);
//	self.startLabel.font = [self.startLabel.font original];
//	self.endLabel.font = [self.endLabel.font original];
//	self.durationLabel.font = [self.durationLabel.font original];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[self slider];
#warning Incorrectly scrolls cached waveforms!!!
	if (self.selectedItem.segment)
		self.position = self.selectedItem.segment.startTime;

	self.slider.startValue = (self.selectedItem.segment ? self.selectedItem.segment.startTime : self.startTime) - self.position;
	self.slider.endValue = (self.selectedItem.segment ? self.selectedItem.segment.endTime : self.endTime) - self.position;
	
	[self setupRegionView];
	self.regionView.value = (self.currentTime - self.startTime) / (self.endTime - self.startTime);
	[self setupRegionLabels:YES];
	[self setupPlayerLabel:YES];
}

- (void)playerDidChangeStatus:(BOOL)isPlaying {
	[super playerDidChangeStatus:isPlaying];

//	self.playerLabel.font = isPlaying ? [self.playerLabel.font bold] : [self.playerLabel.font original];
}

- (void)playerDidChangeTime:(NSTimeInterval)time {
	[super playerDidChangeTime:time];

	self.regionView.value = (self.currentTime - self.startTime) / (self.endTime - self.startTime);
	[self setupPlayerLabel:YES];
}

- (void)waveformDidLoad {
	[self scrollViewDidEndDecelerating:self.scrollView];
}

- (void)viewDidTransitionToSize:(CGSize)size {
	[self setupRegionView];
	[self setupRegionLabels:YES];
	[self setupPlayerLabel:YES];

	self.slider.frame = [self sliderFrame];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	NSTimeInterval start = [self timeForLocation:self.regionView.frame.origin.x];
	NSTimeInterval end = [self timeForLocation:self.regionView.frame.origin.x + self.regionView.frame.size.width];
	[self setSegmentStart:start andSegmentEnd:end];

	self.regionView.value = (self.currentTime - self.startTime) / (self.endTime - self.startTime);
	[self setupRegionLabels:NO];
	[self setupPlayerLabel:YES];
	
//	self.regionView.backgroundColor = WA(255, 10);
//	self.startLabel.font = [self.startLabel.font bold];
//	self.endLabel.font = [self.endLabel.font bold];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (decelerate)
		return;
	
	[self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//	self.regionView.backgroundColor = WA(255, 20);
//	self.startLabel.font = [self.startLabel.font original];
//	self.endLabel.font = [self.endLabel.font original];
}

@end
