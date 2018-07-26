//
//  Global.h
//  Ringo
//
//  Created by Alexander Ivanov on 26.05.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Affiliates+Convenience.h"

#define STR_TONE @"com.alexivanov.ringo.tone"

#define EXT_M4R @"m4r"

#define GUI_UNWIND @"unwind"
#define GUI_SELECT @"select"

#define GUI_HELP @"help"
#define GUI_ONLINE @"online"
#define GUI_TRIM @"trim"
#define GUI_IMPORT @"import"
#define GUI_CHARTS @"charts"
//#define GUI_VK_CHARTS @"vk-charts"
//#define GUI_VK_IMPORT @"vk-import"
//#define GUI_VK_SHARE @"vk-share"
#define TAB_HELP 2

#define IMG_PLAY @"play"
#define IMG_STOP @"stop"
#define IMG_STOP_VK @"stop-vk"
#define IMG_RINGO_128 @"ringo-128"

#define IMG_HELP_LINE @"help-line"

#define IMG_BELL_FULL @"bell-full-30"
#define IMG_BELL_LINE @"bell-line-30"
#define IMG_MUSIC_FULL @"music-fill"
#define IMG_MUSIC_LINE @"music-line"

#define IMG_STAR_FULL @"star-full-30"
#define IMG_STAR_LINE @"star-line-30"

#define IMG_USER_LINE @"user-line-30"
#define IMG_USER_FULL @"user-full-30"

#define IMG_USERS_LINE @"users-line-30"
#define IMG_USERS_FULL @"users-full-30"

#define IMG_ADD @"add"
//#define IMG_ADD_VK @"add-vk"

//#define IMG_VK_30 @"VK-30"
//#define IMG_VK_44 @"VK-44"

#define TMP_FILE @"sound"
#define TMP_EXT @"m4a"

#define STR_EMAIL @"alex@apptag.me"

#define STR_LOGARITHMIC_WAVEFORM @"LogarithmicWaveform"

//#define URL_SCHEME @"ringo"
//#define URL_SHARE @"ringo://tone"
#define URL_WEB @"https://apptag.me/tones/"
#define URL_OLD @"https://ringtonic.net/share.php"
#define URL_PHP @"https://apptag.me/tones/share.php"
#define URL_PHP_FB @"https://apptag.me/tones/fb.php"
#define URL_APP @"https://apptag.me/tones/app"
#define URL_HASHTAG @"#ringtonic"

#define IAP_IDS @[ @"com.alexivanov.ringo.stereo.9", @"com.alexivanov.ringo.stereo.7", @"com.alexivanov.ringo.stereo.5", @"com.alexivanov.ringo.stereo.3", @"com.alexivanov.ringo.stereo.1", @"com.alexivanov.ringo.stereo" ]

#define APP_ID_DONE 734258590
#define APP_ID_LUNA 964733439
#define APP_ID_RINGO 979630381

#define FB_APP_ID @"1450627788594669"
#define FB_PLACEMENT_ID @"1450627788594669_2048852888772153"
#define FB_GROUP_URL @"https://www.facebook.com/ringtonicapp/"

#define VK_APP_ID @"4984252"
#define VK_VERSION @"5.65"
#define VK_GROUP_ID 101076766
#define VK_GROUP_URL @"https://vk.com/ringoapp"
#define VK_PERMISSIONS @[ VK_PER_AUDIO, VK_PER_GROUPS, VK_PER_PHOTOS, VK_PER_WALL ]
#define VK_USER_ID @"197131126"

#define GLOBAL [Global instance]

#define __screenshot NO

@import UIKit;

@interface Global : NSObject

//@property (strong, nonatomic, readonly) NSString *vkAppId;
//@property (strong, nonatomic, readonly) NSString *vkVersion;
//@property (strong, nonatomic, readonly) NSString *vkUserAgent;
@property (strong, nonatomic, readonly) NSArray<NSNumber *> *fbModes;
@property (assign, nonatomic, readonly) NSInteger tonesCount;
@property (assign, nonatomic, readonly) NSInteger tonesLimit;

//@property (assign, nonatomic, readonly) BOOL vkEnabled;
- (void)fetchVKEnabled:(void (^)(BOOL reload))handler;

- (void)update;

@property (strong, nonatomic, readonly) UIColor *globalTintColor;

+ (instancetype)instance;

@property (assign, nonatomic) NSInteger firstFeaturedPostID;
@property (assign, nonatomic) NSInteger openReviewCount;

@property (strong, nonatomic, readonly) NSString *purchaseID;
- (void)setPurchaseSuccess:(BOOL)success;

@property (strong, nonatomic, readonly) NSDictionary *affiliateInfo;

@end
