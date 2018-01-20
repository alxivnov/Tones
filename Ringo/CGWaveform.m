//
//  CGWaveform.m
//  Ringo
//
//  Created by Alexander Ivanov on 17.03.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import "CGWaveform.h"

@import Accelerate;

@interface CGWaveform ()
@property (assign, nonatomic) CGPathRef path;
@property (assign, nonatomic) CGSize size;
@end

@implementation CGWaveform

+ (NSData *)waveFromData:(NSData *)data window:(NSUInteger)window {
	NSMutableData *d = [NSMutableData dataWithCapacity:round(ceil((double)data.length / (double)window) * sizeof(float))];

	float *buffer = malloc(window * sizeof(float));

	[data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange range, BOOL *stop) {
		NSUInteger length = range.length / sizeof(float);

		memcpy(buffer, bytes, range.length);

		vDSP_vabs(buffer, 1, buffer, 1, length);			// Vector absolute values; single precision.

		float mean = 0.0f;
		vDSP_meanv(buffer, 1, &mean, length);

		[d appendBytes:&mean length:sizeof(float)];
	} length:window];

	free(buffer);
	
	return d;
}

+ (CGPathRef)newPathFromData:(NSData *)data height:(CGFloat)height flag:(BOOL)flag {
	CGMutablePathRef path = CGPathCreateMutable();
	
	size_t length = data.length / sizeof(float);
	float *buffer = malloc(data.length);

	memcpy(buffer, data.bytes, data.length);

	float max = 0.0f;
	vDSP_maxv(buffer, 1, &max, length);

	float add = height / 2.0;
	float mul = add / max;
	vDSP_vsmsa(buffer, 1, &mul, &add, buffer, 1, length);	// Single-precision real vector-scalar multiply and scalar add.

	CGPathMoveToPoint(path, Nil, 0.0, add);
	for (NSUInteger index = 0; index < length; index++)
		CGPathAddLineToPoint(path, Nil, index + 1, buffer[index]);
	
	add = height;
	mul = -1.0;
	vDSP_vsmsa(buffer, 1, &mul, &add, buffer, 1, length);	// Single-precision real vector-scalar multiply and scalar add.
	
	for (NSUInteger index = length; index > 0; index--)
		CGPathAddLineToPoint(path, Nil, index, buffer[index - 1]);
	
	free(buffer);
	
	return path;
}

- (instancetype)initWithPath:(CGPathRef)path size:(CGSize)size {
	self = [super init];

	if (self) {
		self.path = path;
		self.size = size;
	}

	return self;
}

- (void)dealloc {
	if (!self.path)
		return;

	CGPathRelease(self.path);

	self.path = Nil;
}

+ (instancetype)waveformFromData:(NSData *)data frame:(CGRect)frame flag:(BOOL)flag {
	if (CGRectIsNull(frame))
#if TARGET_OS_IPHONE
		frame = [UIScreen mainScreen].bounds;
#else
		frame = [NSScreen mainScreen].frame;
#endif
	NSUInteger window = (frame.size.height < 512 && frame.size.width < 512 ? 16 : frame.size.height < 1024 && frame.size.width < 1024 ? 8 : 4) * 1024 / 2;
	CGFloat height = fmin(frame.size.height, frame.size.width);

//	NSDate *date = [NSDate date];

	NSData *wave = [self waveFromData:data window:window];
	CGPathRef path = [self newPathFromData:wave height:height flag:flag];

	CGSize size = CGSizeMake(wave.length / sizeof(short), height);

	return [[self alloc] initWithPath:path size:size];
}

+ (instancetype)waveformFromData:(NSData *)data frame:(CGRect)frame {
	return [self waveformFromData:data frame:frame flag:NO];
}

+ (instancetype)waveformFromData:(NSData *)data {
	return [self waveformFromData:data frame:CGRectNull];
}

- (UIImage *)imageWithColor:(UIColor *)color {
	return [UIImage imageWithSize:self.size draw:^(CGContextRef context) {
		CGContextSetStrokeColorWithColor(context, color.CGColor);
		CGContextSetFillColorWithColor(context, color.CGColor);
		CGContextAddPath(context, self.path);
		CGContextDrawPath(context, kCGPathFillStroke);

//		CGPathRelease(path);
	}];
}

- (CAShapeLayer *)layerWithColor:(UIColor *)color {
	CAShapeLayer *layer = [CAShapeLayer new];

	layer.path = self.path;
	layer.fillColor = color.CGColor;
	layer.strokeColor = color.CGColor;
	
	layer.frame = CGPathGetPathBoundingBox(self.path);

//	layer.masksToBounds = NO;
//	layer.shouldRasterize = YES;

//	layer.opaque = YES;

	return layer;
}

@end
