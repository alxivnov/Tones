//
//  Global.m
//  Ringo
//
//  Created by Alexander Ivanov on 26.05.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import "Global.h"

//#import "VKHelper.h"

#import "NSArray+Convenience.h"
#import "NSBundle+Convenience.h"
#import "NSDictionary+Convenience.h"
#import "NSObject+Convenience.h"
#import "NSURL+Convenience.h"
#import "SKInAppPurchase.h"
#import "UIApplication+Convenience.h"
#import "UIColor+Convenience.h"
//#import "VKAPI.h"

//	4986954		Snapster for iPhone

//	3116505
//	4580399

//	3502561
//	3697615
//	3087106
//	3140623

//#define KEY_VK_APP_ID @"vkAppId"
//#define KEY_VK_VERSION @"vkVersion"
//#define KEY_VK_USER_AGENT @"vkUserAgent"
//#define KEY_VK_ENABLED @"vkEnabled"
#define KEY_FB_MODES @"fbModes"
#define KEY_TONES_COUNT @"tonesCount"
#define KEY_TONES_LIMIT @"tonesLimit"

#define KEY_FIRST_FEATURED_POST_ID @"firstFeaturedPostID"
#define KEY_OPEN_REVIEW_COUNT @"openReviewCount"

@interface Global ()
@property (strong, nonatomic, readonly) NSUserDefaults *defaults;
@end

@implementation Global

__synthesize(NSUserDefaults *, defaults, [NSUserDefaults standardUserDefaults])
/*
- (NSString *)vkAppId {
	return [self.defaults objectForKey:KEY_VK_APP_ID] ?: VK_APP_ID;
}

- (void)setVkAppId:(NSString *)vkAppId {
	if (NSStringIsEqualToString([self.defaults objectForKey:KEY_VK_APP_ID], vkAppId))
		return;

	[VKSdk forceLogout];
	[VKHelper initializeWithAppId:vkAppId apiVersion:self.vkVersion permissions:VK_PERMISSIONS];

	[self.defaults setObject:vkAppId forKey:KEY_VK_APP_ID];
}

- (NSString *)vkVersion {
	return [self.defaults objectForKey:KEY_VK_VERSION] ?: VK_VERSION;
}

- (void)setVkVersion:(NSString *)vkVersion {
	[self.defaults setObject:vkVersion forKey:KEY_VK_VERSION];
}

- (NSString *)vkUserAgent {
	return [self.defaults objectForKey:KEY_VK_USER_AGENT];
}

- (void)setVkUserAgent:(NSString *)vkUserAgent {
	[self.defaults setObject:vkUserAgent forKey:KEY_VK_USER_AGENT];
}

- (BOOL)vkEnabled {
	return __screenshot ? NO : IS_DEBUGGING || [self.defaults boolForKey:KEY_VK_ENABLED];
}

- (void)setVkEnabled:(BOOL)vkEnabled {
	[self.defaults setBool:vkEnabled forKey:KEY_VK_ENABLED];
}
*/
- (NSArray<NSNumber *> *)fbModes {
	return [self.defaults objectForKey:KEY_FB_MODES];
}

- (void)setFbModes:(NSArray<NSNumber *> *)fbModes {
	[self.defaults setObject:fbModes forKey:KEY_FB_MODES];
}

- (NSInteger)tonesCount {
//	NSInteger tonesCount = [self.defaults integerForKey:KEY_TONES_COUNT];
	return /*tonesCount > 0 ? tonesCount : */__screenshot ? [UIApplication sharedApplication].iPhone ? 11 : 22 : [UIApplication sharedApplication].iPhone ? 10 : 16;
}
/*
- (void)setTonesCount:(NSInteger)tonesCount {
	[self.defaults setInteger:tonesCount forKey:KEY_TONES_COUNT];
}
*/
- (NSInteger)tonesLimit {
	NSInteger tonesLimit = [self.defaults integerForKey:KEY_TONES_LIMIT];
	return tonesLimit > 0 ? tonesLimit : 3;
}

- (void)setTonesLimit:(NSInteger)tonesLimit {
	[self.defaults setInteger:tonesLimit forKey:KEY_TONES_LIMIT];
}

- (void)fetchVKEnabled:(void (^)(BOOL reload))handler {
	[[NSURL URLWithString:URL_APP] download:Nil priority:NSURLSessionTaskPriorityHigh handler:^(NSURL *url) {
		if (!url)
			return;

		NSData *data = [NSData dataWithContentsOfURL:url];
		NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data];

//		self.vkAppId = json[@"a"];
//		self.vkVersion = json[@"n"];
//		self.vkUserAgent = json[@"u"];
//		self.tonesCount = [json[@"c"] integerValue];
		self.tonesLimit = [json[@"e"] integerValue];
		self.fbModes = json[@"m"];

//		BOOL vkEnabled = self.vkEnabled;
//		self.vkEnabled = IS_DEBUGGING || [VKSdk wakeUpSession:VK_PERMISSIONS] || ([NSBundle isPreferredLocalization:LNG_RU] && json[@"v"] && [json[@"v"] compare:[NSBundle bundleVersion] options:NSNumericSearch] != NSOrderedAscending);
//		if (handler)
//			handler(vkEnabled != self.vkEnabled);
/*
		if (self.vkEnabled) {
			[VKAPI api].version = GLOBAL.vkVersion;
			[VKAPI api].userAgent = GLOBAL.vkUserAgent;
		}
*/	}];
}

- (void)update {
	NSString *oldVersion = [self.defaults objectForKey:CFBundleVersion];
	NSString *newVersion = [NSBundle bundleVersion];

	if ([oldVersion isEqualToString:newVersion])
		return;

	[self.defaults setObject:newVersion forKey:CFBundleVersion];
	
	[self updateFrom:oldVersion to:newVersion];
}

- (void)updateFrom:(NSString *)oldVersion to:(NSString *)newVersion {
//	if (!oldVersion)
//		[VKSdk forceLogout];
	
	[[NSFileManager URLForDirectory:NSCachesDirectory] clearDirectory];
}

- (UIColor *)globalTintColor {
	return [UIColor color:0xE20F02];
}

static id _instance;

+ (instancetype)instance {
	if (!_instance)
		_instance = [self new];
	
	return _instance;
}

- (NSInteger)firstFeaturedPostID {
	return [self.defaults integerForKey:KEY_FIRST_FEATURED_POST_ID];
}

- (void)setFirstFeaturedPostID:(NSInteger)firstFeaturedPostID {
	[self.defaults setInteger:firstFeaturedPostID forKey:KEY_FIRST_FEATURED_POST_ID];
}

- (NSInteger)openReviewCount {
	return [self.defaults integerForKey:KEY_OPEN_REVIEW_COUNT];
}

- (void)setOpenReviewCount:(NSInteger)openReviewCount {
	[self.defaults setInteger:openReviewCount forKey:KEY_OPEN_REVIEW_COUNT];
}

- (NSString *)purchaseID {
	NSString *purchaseID = [IAP_IDS firstObject:^BOOL(id obj) {
		return [SKInAppPurchase purchaseWithProductIdentifier:obj].purchased;
	}];
	if (!purchaseID)
		purchaseID = [IAP_IDS firstObject:^BOOL(id obj) {
			id object = [[NSUserDefaults standardUserDefaults] objectForKey:obj];
			return object == Nil || [object boolValue] == YES;
		}];
	if (!purchaseID)
		purchaseID = IAP_IDS.lastObject;
	return purchaseID;
}

- (void)setPurchaseSuccess:(BOOL)success {
	[[NSUserDefaults standardUserDefaults] setBool:success forKey:self.purchaseID];
}

__synthesize(NSDictionary *, affiliateInfo, [[NSDictionary dictionaryWithProvider:@"10603809" affiliate:@"1l3voBu"] dictionaryWithObject:@"write-review" forKey:@"action"])

@end
