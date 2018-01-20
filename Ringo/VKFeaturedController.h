//
//  VKFeaturedController.h
//  Ringo
//
//  Created by Alexander Ivanov on 22.10.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "VKController.h"

@interface VKFeaturedController : VKController

+ (NSArray *)getPosts:(void(^)(NSInteger newPosts))handler;
+ (NSInteger)newPosts;

@end
