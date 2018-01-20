//
//  WaveformController.m
//  Ringo
//
//  Created by Alexander Ivanov on 03.10.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "WaveformController.h"
#import "Localized.h"

#import "UIImage+Effects.h"
#import "UIWaveformView.h"

#import "UIActivityIndicatorView+Convenience.h"

@interface WaveformController ()
@property (weak, nonatomic) IBOutlet UIImageView *artworkImage;
@property (weak, nonatomic) IBOutlet UIWaveformView *waveformView;
@end

@implementation WaveformController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 */

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (self.waveformView.interval > 0.0)
		return;
	
	self.navigationItem.title = [self.selectedItem description];
	
//	UIImage *artwork = [self.selectedItem.image imageWithSize:self.artworkImage.bounds.size];
	self.artworkImage.image = [self.selectedItem.image imageByApplyingLightEffect];
	
//	self.waveformView.alpha = 0.667;
	self.waveformView.contentInset = UIEdgeInsetsMake(0.0, GUI_MARGIN_REGULAR, 0.0, GUI_MARGIN_REGULAR);
//	self.waveformView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (self.waveformView.interval > 0.0)
		return;

	[self.waveformView setInterval:AUDIO_SEGMENT_LENGTH animated:animated];
	[self.waveformView setDuration:self.selectedItem.duration];

	void (^loadImage)(CGWaveform *) = ^void(CGWaveform *waveform) {
//		UIImage *image = [waveform imageWithColor:self.navigationController.navigationBar.barTintColor];
		CALayer *layer = [waveform layerWithColor:self.navigationController.navigationBar.barTintColor];

		[GCD main:^{
			[self stopActivityIndication];

//			[self.waveformView loadImage:image withDuration:self.selectedItem.duration];
			[self.waveformView loadLayer:layer withDuration:self.selectedItem.duration];
#warning Layer (h: slow, w: fast)?

			[self waveformDidLoad];

			self.waveformView.delegate = self;
		}];
	};

	[self startActivityIndication:UIActivityIndicatorViewStyleWhiteLarge message:[Localized waiting]];

	if (self.selectedItem.waveform)
		loadImage(self.selectedItem.waveform);
	else
		[self.selectedItem generateWaveform:^(CGWaveform *waveform) {
			loadImage(waveform);
		}];
}

- (UIScrollView *)scrollView {
	return self.waveformView;
}

- (CGFloat)locationForTime:(NSTimeInterval)seconds {
	return [self.waveformView locationForTime:seconds relative:YES];
}

- (NSTimeInterval)timeForLocation:(CGFloat)location {
	return [self.waveformView timeForLocation:location relative:YES];
}

- (NSTimeInterval)position {
	return self.waveformView.position;
}

- (void)setPosition:(NSTimeInterval)position {
	id <UIScrollViewDelegate> delegate = self.waveformView.delegate;
	self.waveformView.delegate = Nil;
	
	self.waveformView.position = position;
	
	self.waveformView.delegate = delegate;
}

- (void)waveformDidLoad {
	
}

- (void)viewDidTransitionToSize:(CGSize)size {
	
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	self.waveformView.scrollEnabled = NO;

	self.waveformView.delegate = Nil;

	[coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
		[self.waveformView setInterval:self.waveformView.interval animated:YES];
		self.waveformView.scrollEnabled = YES;

		[self viewDidTransitionToSize:size];
	} completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		[self viewDidTransitionToSize:size];

		self.waveformView.delegate = self;
	}];
}

@end
