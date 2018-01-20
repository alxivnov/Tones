//
//  HelpView.m
//  Ringo
//
//  Created by Alexander Ivanov on 23.09.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "HelpView.h"

@implementation HelpView

@synthesize image = _image;

- (UIImageView *)image {
	if (!_image) {
		_image = [[UIImageView alloc] initWithFrame:CGRectZero];
		_image.contentMode = UIViewContentModeScaleAspectFit;

		[self addSubview:_image];
	}

	return _image;
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

	CGFloat imageHeight = self.label.frame.origin.y + self.label.frame.size.height + (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? 4.0 : 8.0);
	self.image.frame = CGRectMake(self.bounds.origin.x, imageHeight, self.bounds.size.width, self.bounds.size.height - imageHeight);
}

@end
