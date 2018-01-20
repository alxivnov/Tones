//
//  TextView.m
//  Ringo
//
//  Created by Alexander Ivanov on 23.09.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "TextView.h"

@implementation TextView

@synthesize label = _label;

- (UILabel *)label {
	if (!_label) {
		_label = [[UILabel alloc] initWithFrame:CGRectZero];
		_label.font = [UIFont systemFontOfSize:24.0 weight:UIFontWeightUltraLight];
		_label.numberOfLines = 2;
		_label.textAlignment = NSTextAlignmentCenter;
		_label.textColor = [UIColor darkGrayColor];

		[self addSubview:_label];
	}

	return _label;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews {
	[super layoutSubviews];

	CGSize labelSize = [_label.attributedText size];
	self.label.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y + (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? 8.0 : 16.0), self.bounds.size.width, labelSize.width < self.bounds.size.width ? labelSize.height : labelSize.height * 2.0);
}

@end
