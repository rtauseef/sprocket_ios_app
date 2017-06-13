//
// Hewlett-Packard Company
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import <Foundation/Foundation.h>


@interface NSLocale (Additions)

+ (NSString *)languageID;
+ (NSString *)countryID;
+ (BOOL)isChinese;
+ (BOOL)isEnglish;
+ (BOOL)isNorthAmerica;
+ (BOOL)isAustralia;
+ (BOOL)isUnitedStates;
+ (BOOL)isSurveyAvailable;
+ (BOOL)isTwitterSupportAvailable;
+ (BOOL)isFBMessengerSupportAvailable;
+ (NSURL *)privacyURL;
+ (NSURL *)userGuideURL;
+ (NSURL *)buyPaperURL;
+ (NSURL *)supportWebsiteURL;
+ (NSURL *)supportForumURL;
+ (NSString *)messengerSupportURL;
+ (NSString *)twitterHPCareSupportURL;
+ (NSString *)twitterSupportTag;
+ (NSString *)twitterSupportTagURL;

@end
