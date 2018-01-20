//
//  Localized.h
//  Ringo
//
//  Created by Alexander Ivanov on 09.09.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Localized : NSObject

//+ (NSString *)ok;
+ (NSString *)next;
+ (NSString *)cancel;
+ (NSString *)delete;
+ (NSString *)export;
+ (NSString *)feature;

+ (NSString *)logIn;
+ (NSString *)logOut;

+ (NSString *)logInToVK;
+ (NSString *)logOutFromVK;
+ (NSString *)logInToGetAccess;
+ (NSString *)openCommunity;

+ (NSString *)follow;
+ (NSString *)followTitle;
+ (NSString *)followMessage;

+ (NSString *)userUsedYourTone:(NSString *)user sex:(NSUInteger)sex;
+ (NSString *)openProfile;

+ (NSString *)feedback;
+ (NSString *)feedbackTitle;
+ (NSString *)feedbackMessage;

+ (NSString *)allow;
+ (NSString *)allowNotifications;
+ (NSString *)allowSendNotifications;
+ (NSString *)allowMediaLibrary;
+ (NSString *)allowPlayMediaLibrary;

+ (NSString *)rateApp;
+ (NSString *)fullGuide;

+ (NSString *)openInITunesStore;
+ (NSString *)purchaseAndDownload;

+ (NSString *)posted;
+ (NSString *)myProfile;
+ (NSString *)myCommunities;
+ (NSString *)friends:(NSUInteger)count;
+ (NSString *)followers:(NSUInteger)count;

+ (NSString *)emptyState;

+ (NSString *)processing;

+ (NSString *)waiting;

+ (NSString *)hi:(NSString *)username;

+ (NSString *)mono;
+ (NSString *)stereo;
+ (NSString *)purchased;

+ (NSString *)newTone;

+ (NSString *)newToneIsAvailable;
+ (NSString *)newToneIsAvailableWithArgs;
+ (NSString *)somebodyUsedYourToneWithArgs;
+ (NSString *)somebodyUsedYourTone:(NSString *)user;

+ (NSString *)howToInstallToneToPhone;

+ (NSString *)findUsOnFacebook;

+ (NSString *)tones:(NSUInteger)count;

+ (NSString *)tonesCreated:(NSUInteger)count;
+ (NSString *)timesUsed:(NSUInteger)count;
+ (NSString *)times:(NSUInteger)count;

+ (NSArray<NSString *> *)keywords;

@end
