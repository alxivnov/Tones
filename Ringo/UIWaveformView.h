//
//  UIWaveformView.h
//  Ringo
//
//  Created by Alexander Ivanov on 16.03.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CGWaveform.h"

#import "CoreGraphics+Convenience.h"
#import "AVAsset+Convenience.h"
#import "NSObject+Convenience.h"
#import "UIScrollView+Convenience.h"

@import AVFoundation;

@interface UIWaveformView : UIScrollView

- (void)loadLayer:(CALayer *)layer withDuration:(NSTimeInterval)duration;
/*
- (void)loadImage:(UIImage *)image withDuration:(NSTimeInterval)duration;
- (void)loadAsset:(AVAsset *)asset;
- (void)loadURL:(NSURL *)url;
*/

@property (assign, nonatomic) NSTimeInterval duration;
@property (assign, nonatomic) NSTimeInterval interval;
@property (assign, nonatomic) NSTimeInterval position;

- (void)setPosition:(NSTimeInterval)position animated:(BOOL)animated;
- (void)setInterval:(NSTimeInterval)interval animated:(BOOL)animated;

- (CGFloat)locationForTime:(NSTimeInterval)seconds relative:(BOOL)relative;
- (CGFloat)locationForTime:(NSTimeInterval)seconds;

- (NSTimeInterval)timeForLocation:(CGFloat)location relative:(BOOL)relative;
- (NSTimeInterval)timeForLocation:(CGFloat)location;

@end
