//
//  UIWaveformView.m
//  Ringo
//
//  Created by Alexander Ivanov on 16.03.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import "UIWaveformView.h"

@interface UIWaveformView ()
@property (strong, nonatomic) UIView *image;

@property (assign, nonatomic) CGFloat pointsPerSecond;
@end

@implementation UIWaveformView

- (UIView *)image {
	if (!_image) {
		_image = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.contentSize.width, self.contentSize.height)];

		[self addSubview:_image];
	}

	return _image;
}
/*
- (UIImageView *)image {
	if (!_image) {
		_image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.contentSize.width, self.contentSize.height)];
		_image.contentMode = UIViewContentModeScaleAspectFit;
		
		[self addSubview:_image];
	}
	
	return _image;
}
*/
- (void)updateUI:(NSTimeInterval)position {
//	CGFloat inset = self.pointsPerSecond * 3.0;
//	self.contentInset = UIEdgeInsetsMake(0.0, inset, 0.0, inset);
	[self setPosition:position animated:YES];

	CGSize size = CGSizeMake(self.pointsPerSecond * self.duration, self.bounds.size.height);
	BOOL transform = CATransform3DIsIdentity(self.image.layer.sublayers.firstObject.transform);
	if ((CGSizeEqualToSize(self.contentSize, size) && !transform) || !(CGSizeIsFinite(size) && size.width > 0.0 && size.height > 0.0))
		return;

	self.contentSize = size;
	
	self.image.frame = CGRectMake(0.0, 0.0, size.width, size.height);

	CALayer *layer = self.image.layer.sublayers.firstObject;
	if (!layer)
		return;

	CGFloat scale = size.width / layer.frame.size.width;
	if (!(isfinite(scale) && scale > 0.0))
		return;
	layer.transform = CATransform3DMakeScale(scale, scale, 1.0);

	CGRect frame = CGRectCenterInSize(layer.frame, size);
	if (!(CGRectIsFinite(frame) && frame.size.width > 0.0 && frame.size.height > 0.0))
		return;
	layer.frame = frame;
}

- (void)setDuration:(NSTimeInterval)duration {
	if (_duration == duration)
		return;
	
	_duration = duration;
	
	[self updateUI:-1.0];
}

- (void)setInterval:(NSTimeInterval)interval animated:(BOOL)animated {
	if (_interval == interval && !animated)
		return;
	
	_interval = interval;
	
	CGFloat position = self.position;

	self.pointsPerSecond = (self.bounds.size.width - (self.contentInset.left + self.contentInset.right)) / interval;
	
	if (animated)
		[self updateUI:position];
}

- (void)setInterval:(NSTimeInterval)interval {
	[self setInterval:interval animated:NO];
}

- (NSTimeInterval)position {
	return (self.contentOffset.x + self.contentInset.left) / self.pointsPerSecond;
}

- (void)setPosition:(NSTimeInterval)position animated:(BOOL)animated {
	if (position < 0.0)
		return;
	
	position = fmin(position, self.duration - self.interval);

	[self setContentOffset:CGPointMake(self.pointsPerSecond * position - self.contentInset.left, self.contentOffset.y) animated:animated];
}

- (void)setPosition:(NSTimeInterval)position {
	[self setPosition:position animated:NO];
}

- (void)load:(NSTimeInterval)duration {
	if (self.position > 0.0)
		self.position = self.position;
//	else
//		[self scroll:UIDirectionLeft insets:YES];
//		self.position = 0.0;
#warning FIX SCROLLING!!!

	if (duration > 0.0)
		self.duration = duration;
}

- (void)loadLayer:(CALayer *)layer withDuration:(NSTimeInterval)duration {
	[self load:duration];

	[self.image.layer addSublayer:layer];
}
/*
- (void)loadImage:(UIImage *)image withDuration:(NSTimeInterval)duration {
	[self load:duration];

	self.image.image = image;
}

- (void)loadAsset:(AVAsset *)asset {
	[self loadImage:Nil withDuration:asset.seconds];
	
	[asset readWithSettings:AVAudioSettingsLinearPCMMono handler:^(NSData *data) {
		UIImage *image = [[CGWaveform waveformFromData:data frame:CGRectNull flag:YES] imageWithColor:self.tintColor];

		[GCD main:^{
			self.image.image = image;
		}];
	}];
}

- (void)loadURL:(NSURL *)url {
	AVAsset *asset = [AVAsset assetWithURL:url];
	
	[self loadAsset:asset];
}
*/

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[self updateUI:-1.0];
}

- (void)setContentOffset:(CGPoint)contentOffset {
	if (!self.scrollEnabled)
		return;
	
	[super setContentOffset:contentOffset];
}

- (CGFloat)locationForTime:(NSTimeInterval)seconds relative:(BOOL)relative {
	CGFloat location = seconds * self.pointsPerSecond;
	if (relative)
		location -= self.contentOffset.x;
	return location;
}

- (CGFloat)locationForTime:(NSTimeInterval)seconds {
	return [self locationForTime:seconds relative:NO];
}

- (NSTimeInterval)timeForLocation:(CGFloat)location relative:(BOOL)relative {
	if (relative)
		location += self.contentOffset.x;
	
	return location / self.pointsPerSecond;
}

- (NSTimeInterval)timeForLocation:(CGFloat)location {
	return [self timeForLocation:location relative:NO];
}

@end
