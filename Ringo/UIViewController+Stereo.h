//
//  UIViewController+Stereo.h
//  Ringtonic
//
//  Created by Alexander Ivanov on 02/08/16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AudioItem.h"

@interface UIViewController (Stereo)

- (void)presentPurchase:(void(^)(BOOL success))completion;

- (void)presentSheet:(AudioItem *)item from:(id)sender completion:(void(^)(BOOL success))completion;

@end
