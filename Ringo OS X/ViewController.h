//
//  ViewController.h
//  Ringo OS X
//
//  Created by Alexander Ivanov on 06.01.16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@import AVFoundation;

#import "NSURLDraggingDestination.h"

@interface ViewController : NSViewController <NSURLDraggingDestination>

@property (strong, nonatomic, readonly) AVAsset *asset;

@property (assign, nonatomic, readonly) NSTimeInterval startTime;
@property (assign, nonatomic, readonly) NSTimeInterval endTime;
@property (copy, nonatomic) void(^timeChange)();

@end

