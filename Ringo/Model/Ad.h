//
//  Ad.h
//  Ringtonic
//
//  Created by Alexander Ivanov on 09/06/16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import "CKObjectBase.h"

#define STR_SUBSCRIPTION_ID_AD @"Ad-ModifiedAfterNow-Update-v1.7.5"

@interface Ad : CKObjectBase <CKObjectBase>

@property (assign, nonatomic) NSInteger state;

@property (strong, nonatomic) NSURL *url;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *message;

+ (NSPredicate *)subscriptionPredicate;
+ (CKSubscription *)subscription;

@end
