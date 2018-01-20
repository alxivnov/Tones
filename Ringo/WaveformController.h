//
//  WaveformController.h
//  Ringo
//
//  Created by Alexander Ivanov on 03.10.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AudioItem.h"

@interface WaveformController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) AudioItem *selectedItem;

@property (strong, nonatomic, readonly) UIScrollView *scrollView;
- (CGFloat)locationForTime:(NSTimeInterval)seconds;
- (NSTimeInterval)timeForLocation:(CGFloat)location;
@property (assign, nonatomic) NSTimeInterval position;

- (void)waveformDidLoad;
- (void)viewDidTransitionToSize:(CGSize)size;

@end
