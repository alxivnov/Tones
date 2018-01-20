//
//  UIViewController+VKLog.h
//  Ringtonic
//
//  Created by Alexander Ivanov on 04.12.16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VKHelper.h"

@interface UIViewController (VKLog)

- (void)vkLogReceivedNewToken:(VKAccessToken *)newToken;
- (void)vkLogUserDeniedAccess:(VKError *)authorizationError;

@end
