//
//  Localized.m
//  Ringo
//
//  Created by Alexander Ivanov on 09.09.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import "Localized.h"

#import "NSObject+Convenience.h"

@implementation Localized

NSLocalizedMethod(ok, @"OK")
NSLocalizedMethod(next, @"Next")
NSLocalizedMethod(cancel, @"Cancel")
NSLocalizedMethod(delete, @"Delete")
NSLocalizedMethod(export, @"Export")
NSLocalizedMethod(feature, @"Feature")

NSLocalizedMethod(logIn, @"Log In")
NSLocalizedMethod(logOut, @"Log Out")

NSLocalizedMethod(logInToVK, @"Log In to VK")
NSLocalizedMethod(logOutFromVK, @"Log Out from VK")
NSLocalizedMethod(logInToGetAccess, @"Log In to get access to music from VK.")
NSLocalizedMethod(openCommunity, @"Open VK community")

NSLocalizedMethod(follow, @"Follow")
NSLocalizedMethod(followTitle, @"Follow our page in VK")
NSLocalizedMethod(followMessage, @"We are posting ringtones and news about Ringtonic there.")

+ (NSString *)userUsedYourTone:(NSString *)user sex:(NSUInteger)sex {
	NSString *format = loc(sex == 1 ? @"FEMALE used your tone." : sex == 2 ? @"MALE used your tone." : @"%@ used your tone.");
	return [NSString stringWithFormat:format, user];
}
NSLocalizedMethod(openProfile, @"Open VK profile")

NSLocalizedMethod(feedback, @"Write an Email")
NSLocalizedMethod(feedbackTitle, @"What \"Ringtonic\" lacks?")
NSLocalizedMethod(feedbackMessage, @"Please, describe what addition would make your experience better.\nHow would you use it?")

NSLocalizedMethod(allow, @"Allow")
NSLocalizedMethod(allowNotifications, @"Allow Notifications")
NSLocalizedMethod(allowSendNotifications, @"To receive alerts about new tones allow \"Ringtonic\" to send you notifications in the Settings.")
NSLocalizedMethod(allowMediaLibrary, @"Allow Media Library Access")
NSLocalizedMethod(allowPlayMediaLibrary, @"To create tones from your music allow \"Ringtonic\" to access Media Library in the Settings.")

NSLocalizedMethod(rateApp, @"Rate app in the App Store")
NSLocalizedMethod(fullGuide, @"Read full guide")

NSLocalizedMethod(openInITunesStore, @"Open in iTunes Store")
NSLocalizedMethod(purchaseAndDownload, @"You need to purchase and download the song via iTunes to use it as a ringtone.")

NSLocalizedMethod(posted, @"Posted")
NSLocalizedMethod(myProfile, @"My Profile")
NSLocalizedMethod(myCommunities, @"My Communities")

+ (NSString *)friends:(NSUInteger)count {
	return count ? [NSString stringWithFormat:loc(@"%@ friends"), @(count)] : Nil;
}

+ (NSString *)followers:(NSUInteger)count {
	return count ? [NSString stringWithFormat:loc(@"%@ followers"), @(count)] : Nil;
}

NSLocalizedMethod(emptyState, @"Press to convert your favourite song to ringtone.")

NSLocalizedMethod(processing, @"Processing...")

NSLocalizedMethod(waiting, @"Waiting...")

+ (NSString *)hi:(NSString *)username {
	return [NSString stringWithFormat:loc(@"Hi,\n%@!"), username];
}

NSLocalizedMethod(mono, @"Mono")
NSLocalizedMethod(stereo, @"Stereo")
NSLocalizedMethod(purchased, @"Purchased")

NSLocalizedMethod(newTone, @"New")

NSLocalizedMethod(newToneIsAvailable, @"New tone is available")
NSLocalizedMethod(newToneIsAvailableWithArgs, @"New tone %2$@ by %1$@ is available.")
NSLocalizedMethod(somebodyUsedYourToneWithArgs, @"Somebody used your tone %1$@ - %2$@.")

+ (NSString *)somebodyUsedYourTone:(NSString *)user {
	return user.length ? [NSString stringWithFormat:loc(@"%@ used your tone.") , user] : loc(@"Somebody used your tone.");
}

NSLocalizedMethod(howToInstallToneToPhone, @"How to install tone to iPhone?")

NSLocalizedMethod(findUsOnFacebook, @"Find us on Facebook")

+ (NSString *)tones:(NSUInteger)count {
	return [NSString localizedStringWithFormat:loc(@"Tones: %lu"), count];
}

+ (NSString *)tonesCreated:(NSUInteger)count {
	return [NSString localizedStringWithFormat:loc(@"YOU CREATED %lu TONES"), count];
}

+ (NSString *)timesUsed:(NSUInteger)count {
	return [NSString localizedStringWithFormat:loc(@"THEY WERE USED %lu TIMES"), count];
}

+ (NSString *)times:(NSUInteger)count {
	return [NSString localizedStringWithFormat:loc(@"%lu times"), count];
}

+ (NSArray<NSString *> *)keywords {
	return [loc(@"keywords") componentsSeparatedByString:STR_COMMA];
}

@end
