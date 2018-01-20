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

NSLocalizeMethod(ok, @"OK")
NSLocalizeMethod(next, @"Next")
NSLocalizeMethod(cancel, @"Cancel")
NSLocalizeMethod(delete, @"Delete")
NSLocalizeMethod(export, @"Export")
NSLocalizeMethod(feature, @"Feature")

NSLocalizeMethod(logIn, @"Log In")
NSLocalizeMethod(logOut, @"Log Out")

NSLocalizeMethod(logInToVK, @"Log In to VK")
NSLocalizeMethod(logOutFromVK, @"Log Out from VK")
NSLocalizeMethod(logInToGetAccess, @"Log In to get access to music from VK.")
NSLocalizeMethod(openCommunity, @"Open VK community")

NSLocalizeMethod(follow, @"Follow")
NSLocalizeMethod(followTitle, @"Follow our page in VK")
NSLocalizeMethod(followMessage, @"We are posting ringtones and news about Ringtonic there.")

+ (NSString *)userUsedYourTone:(NSString *)user sex:(NSUInteger)sex {
	NSString *format = NSLocalizedString(sex == 1 ? @"FEMALE used your tone." : sex == 2 ? @"MALE used your tone." : @"%@ used your tone.", Nil);
	return [NSString stringWithFormat:format, user];
}
NSLocalizeMethod(openProfile, @"Open VK profile")

NSLocalizeMethod(feedback, @"Write an Email")
NSLocalizeMethod(feedbackTitle, @"What \"Ringtonic\" lacks?")
NSLocalizeMethod(feedbackMessage, @"Please, describe what addition would make your experience better.\nHow would you use it?")

NSLocalizeMethod(allow, @"Allow")
NSLocalizeMethod(allowNotifications, @"Allow Notifications")
NSLocalizeMethod(allowSendNotifications, @"To receive alerts about new tones allow \"Ringtonic\" to send you notifications in the Settings.")
NSLocalizeMethod(allowMediaLibrary, @"Allow Media Library Access")
NSLocalizeMethod(allowPlayMediaLibrary, @"To create tones from your music allow \"Ringtonic\" to access Media Library in the Settings.")

NSLocalizeMethod(rateApp, @"Rate app in the App Store")
NSLocalizeMethod(fullGuide, @"Read full guide")

NSLocalizeMethod(openInITunesStore, @"Open in iTunes Store")
NSLocalizeMethod(purchaseAndDownload, @"You need to purchase and download the song via iTunes to use it as a ringtone.")

NSLocalizeMethod(posted, @"Posted")
NSLocalizeMethod(myProfile, @"My Profile")
NSLocalizeMethod(myCommunities, @"My Communities")

+ (NSString *)friends:(NSUInteger)count {
	return count ? [NSString stringWithFormat:NSLocalize(@"%@ friends"), @(count)] : Nil;
}

+ (NSString *)followers:(NSUInteger)count {
	return count ? [NSString stringWithFormat:NSLocalize(@"%@ followers"), @(count)] : Nil;
}

NSLocalizeMethod(emptyState, @"Press to convert your favourite song to ringtone.")

NSLocalizeMethod(processing, @"Processing...")

NSLocalizeMethod(waiting, @"Waiting...")

+ (NSString *)hi:(NSString *)username {
	return [NSString stringWithFormat:NSLocalizedString(@"Hi,\n%@!", Nil), username];
}

NSLocalizeMethod(mono, @"Mono")
NSLocalizeMethod(stereo, @"Stereo")
NSLocalizeMethod(purchased, @"Purchased")

NSLocalizeMethod(newTone, @"New")

NSLocalizeMethod(newToneIsAvailable, @"New tone is available")
NSLocalizeMethod(newToneIsAvailableWithArgs, @"New tone %2$@ by %1$@ is available.")
NSLocalizeMethod(somebodyUsedYourToneWithArgs, @"Somebody used your tone %1$@ - %2$@.")

+ (NSString *)somebodyUsedYourTone:(NSString *)user {
	return user.length ? [NSString stringWithFormat:NSLocalize(@"%@ used your tone.") , user] : NSLocalize(@"Somebody used your tone.");
}

NSLocalizeMethod(howToInstallToneToPhone, @"How to install tone to iPhone?")

NSLocalizeMethod(findUsOnFacebook, @"Find us on Facebook")

+ (NSString *)tones:(NSUInteger)count {
	return [NSString localizedStringWithFormat:NSLocalize(@"Tones: %lu"), count];
}

+ (NSString *)tonesCreated:(NSUInteger)count {
	return [NSString localizedStringWithFormat:NSLocalize(@"YOU CREATED %lu TONES"), count];
}

+ (NSString *)timesUsed:(NSUInteger)count {
	return [NSString localizedStringWithFormat:NSLocalize(@"THEY WERE USED %lu TIMES"), count];
}

+ (NSString *)times:(NSUInteger)count {
	return [NSString localizedStringWithFormat:NSLocalize(@"%lu times"), count];
}

+ (NSArray<NSString *> *)keywords {
	return [NSLocalize(@"keywords") componentsSeparatedByString:STR_COMMA];
}

@end
