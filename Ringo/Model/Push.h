//
//  Push.h
//  Ringtonic
//
//  Created by Alexander Ivanov on 09/06/16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import "Tone.h"

#import "CKObjectBase.h"

#define STR_SUBSCRIPTION_ID_PUSH @"Push-ModifiedAfterNow-Update-v1.7.5"

@interface Push : CKObjectBase <CKObjectBase>

@property (assign, nonatomic) NSInteger state;

@property (strong, nonatomic) Tone *tone;

@property (strong, nonatomic) NSString *artist;
@property (strong, nonatomic) NSString *title;

+ (instancetype)createWithTone:(Tone *)tone;

+ (NSPredicate *)subscriptionPredicate;
+ (CKSubscription *)subscription;

@end
