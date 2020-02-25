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

+ (NSString *)ok {
    return NSLocalizedString(@"OK", Nil);
}

+ (NSString *)next {
    return NSLocalizedString(@"Next", Nil);
}

+ (NSString *)cancel {
    return NSLocalizedString(@"Cancel", Nil);
}

+ (NSString *)delete {
    return NSLocalizedString(@"Delete", Nil);
}

+ (NSString *)export {
    return NSLocalizedString(@"Actions", Nil);
}

+ (NSString *)feature {
    return NSLocalizedString(@"Feature", Nil);
}

+ (NSString *)share {
	return NSLocalizedString(@"Share", Nil);
}

+ (NSString *)rename {
	return NSLocalizedString(@"Rename", Nil);
}

+ (NSString *)logIn {
    return NSLocalizedString(@"Log In", Nil);
}

+ (NSString *)logOut {
    return NSLocalizedString(@"Log Out", Nil);
}

+ (NSString *)logInToVK {
    return NSLocalizedString(@"Log In to VK", Nil);
}

+ (NSString *)logOutFromVK {
    return NSLocalizedString(@"Log Out from VK", Nil);
}

+ (NSString *)logInToGetAccess {
    return NSLocalizedString(@"Log In to get access to music from VK.", Nil);
}

+ (NSString *)openCommunity {
    return NSLocalizedString(@"Open VK community", Nil);
}

+ (NSString *)follow {
    return NSLocalizedString(@"Follow", Nil);
}

+ (NSString *)followTitle {
    return NSLocalizedString(@"Follow our page in VK", Nil);
}

+ (NSString *)followMessage {
    return NSLocalizedString(@"We are posting ringtones and news about Ringtonic there.", Nil);
}

+ (NSString *)userUsedYourTone:(NSString *)user sex:(NSUInteger)sex {
	NSString *format = loc(sex == 1 ? @"FEMALE used your tone." : sex == 2 ? @"MALE used your tone." : @"%@ used your tone.");
	return [NSString stringWithFormat:format, user];
}

+ (NSString *)openProfile {
    return NSLocalizedString(@"Open VK profile", Nil);
}

+ (NSString *)feedback {
    return NSLocalizedString(@"Write an Email", Nil);
}

+ (NSString *)feedbackTitle {
    return NSLocalizedString(@"What \"Ringtonic\" lacks?", Nil);
}

+ (NSString *)feedbackMessage {
    return NSLocalizedString(@"Please, describe what addition would make your experience better.\nHow would you use it?", Nil);
}

+ (NSString *)allow {
    return NSLocalizedString(@"Allow", Nil);
}

+ (NSString *)allowNotifications {
    return NSLocalizedString(@"Allow Notifications", Nil);
}

+ (NSString *)allowSendNotifications {
    return NSLocalizedString(@"To receive alerts about new tones allow \"Ringtonic\" to send you notifications in the Settings.", Nil);
}

+ (NSString *)allowMediaLibrary {
    return NSLocalizedString(@"Allow Media Library Access", Nil);
}

+ (NSString *)allowPlayMediaLibrary {
    return NSLocalizedString(@"To create tones from your music allow \"Ringtonic\" to access Media Library in the Settings.", Nil);
}

+ (NSString *)rateApp {
    return NSLocalizedString(@"Rate app in the App Store", Nil);
}

+ (NSString *)fullGuide {
    return NSLocalizedString(@"Read full guide", Nil);
}

+ (NSString *)openInITunesStore {
    return NSLocalizedString(@"Open in iTunes Store", Nil);
}

+ (NSString *)purchaseAndDownload {
    return NSLocalizedString(@"You need to purchase and download the song via iTunes to use it as a ringtone.", Nil);
}

+ (NSString *)posted {
    return NSLocalizedString(@"Posted", Nil);
}

+ (NSString *)myProfile {
    return NSLocalizedString(@"My Profile", Nil);
}

+ (NSString *)myCommunities {
    return NSLocalizedString(@"My Communities", Nil);
}

+ (NSString *)friends:(NSUInteger)count {
    return count ? [NSString stringWithFormat:loc(@"%@ friends"), @(count)] : Nil;
}

+ (NSString *)followers:(NSUInteger)count {
    return count ? [NSString stringWithFormat:loc(@"%@ followers"), @(count)] : Nil;
}

+ (NSString *)emptyState {
	return NSLocalizedString(@"Press to convert your favourite song to ringtone.", Nil);
}

+ (NSString *)processing {
	return NSLocalizedString(@"Processing...", Nil);
}

+ (NSString *)waiting {
	return NSLocalizedString(@"Waiting...", Nil);
}

+ (NSString *)hi:(NSString *)username {
	return [NSString stringWithFormat:loc(@"Hi,\n%@!"), username];
}

+ (NSString *)mono {
	return NSLocalizedString(@"Mono", Nil);
}

+ (NSString *)stereo {
	return NSLocalizedString(@"Stereo", Nil);
}

+ (NSString *)purchased {
	return NSLocalizedString(@"Purchased", Nil);
}

+ (NSString *)newTone {
	return NSLocalizedString(@"New", Nil);
}

+ (NSString *)newToneIsAvailable {
	return NSLocalizedString(@"New tone is available", Nil);
}

+ (NSString *)newToneIsAvailableWithArgs {
	return NSLocalizedString(@"New tone %2$@ by %1$@ is available.", Nil);
}

+ (NSString *)somebodyUsedYourToneWithArgs {
	return NSLocalizedString(@"Somebody used your tone %1$@ - %2$@.", Nil);
}

+ (NSString *)somebodyUsedYourTone:(NSString *)user {
	return user.length ? [NSString stringWithFormat:loc(@"%@ used your tone.") , user] : loc(@"Somebody used your tone.");
}

+ (NSString *)howToInstallToneToPhone {
	return NSLocalizedString(@"How to install tone to iPhone?", Nil);
}

+ (NSString *)findUsOnFacebook {
	return NSLocalizedString(@"Find us on Facebook", Nil);
}

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
