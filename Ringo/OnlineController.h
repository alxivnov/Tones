//
//  OnlineController.h
//  Ringo
//
//  Created by Alexander Ivanov on 30.06.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AudioController.h"

@interface OnlineController : AudioController

@property (strong, nonatomic) AudioItem *selectedItem;

@end
