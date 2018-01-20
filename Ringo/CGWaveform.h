//
//  CGWaveform.h
//  Ringo
//
//  Created by Alexander Ivanov on 17.03.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
@import UIKit;
#else
@import AppKit;

#define UIImage NSImage
#define UIColor NSColor
#endif

@import QuartzCore;

#import "NSData+Convenience.h"
#import "UIImage+Convenience.h"

@interface CGWaveform : NSObject

- (UIImage *)imageWithColor:(UIColor *)color;
- (CAShapeLayer *)layerWithColor:(UIColor *)color;

+ (instancetype)waveformFromData:(NSData *)data frame:(CGRect)frame flag:(BOOL)flag;
+ (instancetype)waveformFromData:(NSData *)data frame:(CGRect)frame;
+ (instancetype)waveformFromData:(NSData *)data;

@end
