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

#import "NSLocale+Additions.h"

// Privacy Statements
static NSString * const kPrivacyStatementURL = @"http://www8.hp.com/us/en/privacy/privacy.html";
static NSString * const kPrivacyStatementURLUk = @"http://www8.hp.com/uk/en/privacy/privacy.html";
static NSString * const kPrivacyStatementURLDe = @"http://www8.hp.com/ch/de/privacy/privacy.html";
static NSString * const kPrivacyStatementURLFr = @"http://www8.hp.com/ch/fr/privacy/privacy.html";
static NSString * const kPrivacyStatementURLSp = @"http://www8.hp.com/es/es/privacy/privacy.html";

// User Guides
static NSString * const kPGHelpAndHowToViewUserURL = @"http://h10032.www1.hp.com/ctg/Manual/c05280005";
static NSString * const kPGHelpAndHowToViewUserURLDe = @"http://h10032.www1.hp.com/ctg/Manual/c05320645";
static NSString * const kPGHelpAndHowToViewUserURLFr = @"http://h10032.www1.hp.com/ctg/Manual/c05320547";
static NSString * const kPGHelpAndHowToViewUserURLSp = @"http://h10032.www1.hp.com/ctg/Manual/c05320654";
static NSString * const kPGHelpAndHowToViewUserURLDa = @"http://h10032.www1.hp.com/ctg/Manual/c05320519";

@implementation NSLocale (Additions)

+ (NSString *)languageID
{
    NSArray *supportedLanguages = [[self supportedLocales] allKeys];
    NSString *preferredLanguage = [[[NSLocale preferredLanguages] objectAtIndex:0] substringToIndex:2];
    
    if ([supportedLanguages indexOfObject:preferredLanguage] != NSNotFound) {
        return preferredLanguage;
    }

    return @"en";
}

+ (NSString *)countryID
{
    NSDictionary *supportedLocales = [self supportedLocales];
    NSString *languageID = [self languageID];
    
    if ([supportedLocales objectForKey:languageID]) {
        return supportedLocales[languageID];
    }
    
    return @"us";
}

+ (BOOL)isSurveyAvailable
{
    return [[self languageID] isEqualToString:@"en"];
}

+ (NSDictionary *)supportedLocales
{
    return @{@"en":@"us", @"de":@"de", @"es":@"es", @"fr":@"fr", @"it":@"it", @"nl":@"nl",  @"et":@"ee", @"fi":@"fi", @"lv":@"lv", @"lt":@"lt", @"nb":@"no", @"pt":@"pt", @"sv":@"se", @"zh":@"cn", @"da":@"dk"};
}

+ (NSURL *)privacyURL
{
    NSString *url = kPrivacyStatementURL;
    
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *languageCode = [currentLocale objectForKey:NSLocaleLanguageCode];
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    
    if ([languageCode caseInsensitiveCompare:@"de"] == NSOrderedSame) {
        url = kPrivacyStatementURLDe;
    } else if ([languageCode caseInsensitiveCompare:@"fr"] == NSOrderedSame) {
        url = kPrivacyStatementURLFr;
    } else if ([languageCode caseInsensitiveCompare:@"es"] == NSOrderedSame) {
        url = kPrivacyStatementURLSp;
    } else if ([countryCode caseInsensitiveCompare:@"gb"] == NSOrderedSame  &&
               [languageCode caseInsensitiveCompare:@"en"] == NSOrderedSame) {
        url = kPrivacyStatementURLUk;
    }
    
    return [NSURL URLWithString:url];
}

+ (NSURL *)userGuideURL
{
    NSString *url = kPGHelpAndHowToViewUserURL;
    
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *languageCode = [currentLocale objectForKey:NSLocaleLanguageCode];
    
    if ([languageCode caseInsensitiveCompare:@"de"] == NSOrderedSame) {
        url = kPGHelpAndHowToViewUserURLDe;
    } else if ([languageCode caseInsensitiveCompare:@"fr"] == NSOrderedSame) {
        url = kPGHelpAndHowToViewUserURLFr;
    } else if ([languageCode caseInsensitiveCompare:@"es"] == NSOrderedSame) {
        url = kPGHelpAndHowToViewUserURLSp;
    } else if ([languageCode caseInsensitiveCompare:@"da"] == NSOrderedSame) {
        url = kPGHelpAndHowToViewUserURLDa;
    }
    
    return [NSURL URLWithString:url];
}

+ (NSString *)twitterSupportTag
{
    NSString *tag = @"@hpsupport";
    
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *languageCode = [currentLocale objectForKey:NSLocaleLanguageCode];
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];

    if ([languageCode caseInsensitiveCompare:@"de"] == NSOrderedSame) {
        tag = [NSString stringWithFormat:@"%@%@", tag, @"DE"];
    } else if ([languageCode caseInsensitiveCompare:@"fr"] == NSOrderedSame) {
        tag = [NSString stringWithFormat:@"%@%@", tag, @"FR"];
    } else if ([languageCode caseInsensitiveCompare:@"es"] == NSOrderedSame) {
        tag = [NSString stringWithFormat:@"%@%@", tag, @"ESP"];
    } else if ([countryCode caseInsensitiveCompare:@"gb"] == NSOrderedSame  &&
               [languageCode caseInsensitiveCompare:@"en"] == NSOrderedSame) {
        tag = [NSString stringWithFormat:@"%@ %@", tag, @"#UK"];
    }

    return tag;
}

+ (NSString *)twitterSupportTagURL
{
    NSString *tag = [NSLocale twitterSupportTag];
    
    tag = [tag stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    tag = [tag stringByReplacingOccurrencesOfString:@"#" withString:@"%23"];
    
    return tag;
}

@end
