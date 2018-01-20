//
//  VKController.h
//  Ringo
//
//  Created by Alexander Ivanov on 07.07.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AudioController.h"
#import "AudioItem.h"

@interface VKController : AudioController

@property (strong, nonatomic) AudioItem *selectedItem;

@end
