//
//  Tone.h
//  Ringo
//
//  Created by Alexander Ivanov on 27.06.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CKObjectBase.h"

#import "NSObject+Convenience.h"

#define TYPE_TONE @"tone"

#define FIELD_TITLE @"title"
#define FIELD_ARTIST @"artist"
#define FIELD_ALBUM @"album"
#define FIELD_DURATION @"duration"

#define STR_SUBSCRIPTION_ID_TONE @"Tone-CreatorIsSelf-Update-v1.7.5"

@interface Tone : CKObjectBase <CKObjectBase>

+ (NSString *)identifierWithArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title duration:(NSTimeInterval)duration startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *album;
@property (strong, nonatomic) NSString *artist;
@property (assign, nonatomic) NSTimeInterval duration;

@property (assign, nonatomic) NSTimeInterval startTime;
@property (assign, nonatomic) NSTimeInterval endTime;

@property (assign, nonatomic) NSUInteger importCount;
@property (assign, nonatomic) NSUInteger exportCount;
@property (strong, nonatomic) NSString *localization;

+ (instancetype)createWithArtist:(NSString *)artist title:(NSString *)title startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime;

+ (CKQueryOperation *)loadWithArtist:(NSString *)artist title:(NSString *)title completion:(void (^)(NSArray<__kindof Tone *> *results))completion;
+ (CKQueryOperation *)loadFeatured:(NSArray<NSString *> *)localizations resultsLimit:(NSUInteger)resultsLimit completion:(void (^)(NSArray<__kindof Tone *> *results))completion;
+ (CKQueryOperation *)loadRecent:(NSArray<NSString *> *)localizations resultsLimit:(NSUInteger)resultsLimit completion:(void (^)(NSArray<__kindof Tone *> *results))completion;
+ (void)loadProfile:(void (^)(NSArray<__kindof Tone *> *results))completion;

- (void)deleteFromPublicCloudDatabase:(void(^)(BOOL deleted))completion;

- (NSComparisonResult)compare:(Tone *)otherTone;

+ (NSPredicate *)subscriptionPredicate:(CKRecordID *)recordID;
+ (CKSubscription *)subscription:(CKRecordID *)recordID;

@end
