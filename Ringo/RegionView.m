//
//  RegionView.m
//  Ringo
//
//  Created by Alexander Ivanov on 07.10.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "RegionView.h"

#define GUI_WIDTH 1.0

@interface RegionView ()
@property (strong, nonatomic) UIView *startView;
@property (strong, nonatomic) UIView *endView;
@property (strong, nonatomic) UIView *currentView;
@end

@implementation RegionView

- (CGRect)startViewFrame {
	return CGRectMake(self.bounds.origin.x, self.bounds.origin.y, GUI_WIDTH, self.bounds.size.height);
}

- (CGRect)endViewFrame {
	return CGRectMake(self.bounds.origin.x + self.bounds.size.width - GUI_WIDTH, self.bounds.origin.y, GUI_WIDTH, self.bounds.size.height);
}

- (CGRect)currentViewFrame {
	CGFloat offset = self.bounds.size.width * self.value;
	CGFloat height = offset < 8.0 ? 8.0 - offset : self.bounds.size.width - (offset + 1) < 8.0 ? 8.0 - (self.bounds.size.width - (offset + 1)) : 0.0;

	return self.value > 0.0 && self.value < 1.0 ? CGRectMake(self.bounds.origin.x + offset, self.bounds.origin.y + height, GUI_WIDTH, self.bounds.size.height - (2.0 * height)) : CGRectZero;
}
/*
- (UIView *)startView {
	if (!_startView) {
		_startView = [[UIView alloc] initWithFrame:[self startViewFrame]];
		_startView.backgroundColor = self.tintColor;

		[self addSubview:_startView];
	}

	return _startView;
}

- (UIView *)endView {
	if (!_endView) {
		_endView = [[UIView alloc] initWithFrame:[self endViewFrame]];
		_endView.backgroundColor = self.tintColor;

		[self addSubview:_endView];
	}

	return _endView;
}
*/
- (UIView *)currentView {
	if (!_currentView) {
		_currentView = [[UIView alloc] initWithFrame:[self currentViewFrame]];
		_currentView.backgroundColor = self.tintColor;

		[self addSubview:_currentView];

		self.layer.borderColor = [UIColor whiteColor].CGColor;
		self.layer.borderWidth = 2.0;
		self.layer.cornerRadius = 8.0;
	}

	return _currentView;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	self.startView.frame = [self startViewFrame];
	self.endView.frame = [self endViewFrame];
	self.currentView.frame = [self currentViewFrame];
}

- (void)setTintColor:(UIColor *)tintColor {
	[super setTintColor:tintColor];

	self.startView.backgroundColor = tintColor;
	self.endView.backgroundColor = tintColor;
	self.currentView.backgroundColor = tintColor;
}

- (void)setValue:(float)value {
	_value = value;

	self.currentView.frame = [self currentViewFrame];
}

@end
