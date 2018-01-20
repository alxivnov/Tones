//
//  CKController.h
//  Ringtonic
//
//  Created by Alexander Ivanov on 18/05/16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import "AudioController.h"
#import "Tone.h"
#import "User.h"

#import <VKSdk/VKSdk.h>

@interface CKController : AudioController <UITableViewDelegate>

@property (strong, nonatomic) AudioItem *selectedItem;

@property (strong, nonatomic, readonly) NSArray<Tone *> *tones;

- (void)loadTones:(void (^)(void))handler;

- (void)loadItems:(void (^)(NSArray<Tone *> *tones, NSArray<User *> *users, NSArray<VKUser *> *vkUsers, NSTimeInterval activitiesExpirationInterval))handler;

@end
