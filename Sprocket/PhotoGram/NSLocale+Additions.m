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
static NSString * const kPrivacyStatementURLFormat = @"http://www8.hp.com/%@/%@/privacy/privacy.html";

// User Guides
static NSString * const kPGHelpAndHowToViewUserURL = @"http://h10032.www1.hp.com/ctg/Manual/c05280005";
static NSString * const kPGHelpAndHowToViewUserURLDe = @"http://h10032.www1.hp.com/ctg/Manual/c05320645";
static NSString * const kPGHelpAndHowToViewUserURLFr = @"http://h10032.www1.hp.com/ctg/Manual/c05320547";
static NSString * const kPGHelpAndHowToViewUserURLSp = @"http://h10032.www1.hp.com/ctg/Manual/c05320654";
static NSString * const kPGHelpAndHowToViewUserURLNl = @"http://h10032.www1.hp.com/ctg/Manual/c05320519";
static NSString * const kPGHelpAndHowToViewUserURLZh = @"http://h10032.www1.hp.com/ctg/Manual/c05359608";

// Buy Paper
static NSString * const kPGBuyPaperURL = @"http://www.hp.com/go/zinkphotopaper";

// Join Support
static NSString * const kPGHelpAndHowToJoinForumSupportURL = @"http://hp.care/sprocket";
static NSString * const kPGHelpAndHowToJoinForumSupportURLZh = @"http://h30471.www3.hp.com/t5/community/communitypage";

// Support Website
static NSString * const kPGHelpAndHowToVisitWebsiteURL = @"http://support.hp.com/us-en/product/HP-Sprocket-Photo-Printer/12635221";
static NSString * const kPGHelpAndHowToVisitWebsiteURLZh = @"http://h30471.www3.hp.com/t5/community/communitypage";

// HP Care URL Formats
static NSString * const kPGHPCareURLFormat = @"http://hp.care/%@";
static NSString * const kPGHPCareFBURLFormat = @"http://hp.care/HPCS%@FB";
static NSString * const kPGHPCareTwitterURLFormat = @"http://hp.care/HPCS%@TW";

@implementation NSLocale (Additions)

+ (BOOL)isChinese
{
    BOOL retVal = NO;
    
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *languageCode = [currentLocale objectForKey:NSLocaleLanguageCode];
    if ([languageCode caseInsensitiveCompare:@"zh"] == NSOrderedSame) {
        retVal = YES;
    }
    
    return retVal;
}

+ (BOOL)isNorthAmerica
{
    BOOL retVal = NO;
    
    NSArray *northAmericaCountryCodes = @[@"CA", @"US", @"MX"];
    NSString *currentCountryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    if ([northAmericaCountryCodes containsObject:currentCountryCode]) {
        retVal = YES;
    }

    return retVal;
}

+ (BOOL)isEnglish
{
    BOOL retVal = NO;
    
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *languageCode = [currentLocale objectForKey:NSLocaleLanguageCode];
    if ([languageCode caseInsensitiveCompare:@"en"] == NSOrderedSame) {
        retVal = YES;
    }
    
    return retVal;
}

+ (BOOL)isAustralia
{
    BOOL retVal = NO;
    
    NSString *currentCountryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    if ([currentCountryCode caseInsensitiveCompare:@"au"] == NSOrderedSame) {
        retVal = YES;
    }
    
    return retVal;
}

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

+ (NSString *)deviceCountryCode
{
    return [[[self currentLocale] objectForKey:NSLocaleCountryCode] lowercaseString];
}

+ (NSString *)deviceLanguageCode
{
    return [[[[self preferredLanguages] objectAtIndex:0] substringToIndex:2] lowercaseString];
}

+ (BOOL)isSurveyAvailable
{
    return [[self languageID] isEqualToString:@"en"];
}

+ (NSDictionary *)supportedLocales
{
    return @{@"en":@"us", @"de":@"de", @"es":@"es", @"fr":@"fr", @"it":@"it", @"nl":@"nl",  @"et":@"ee", @"fi":@"fi", @"lv":@"lv", @"lt":@"lt", @"nb":@"no", @"pt":@"pt", @"sv":@"se", @"zh":@"cn", @"da":@"dk", @"el":@"el", @"id":@"id", @"ru":@"ru", @"tr":@"tr", @"th":@"th"};
}

+ (NSDictionary *)twitterHPSupportLocales
{
    return @{@"en":@[@"ca",@"au",@"nz",@"sg",@"ie",@"gb",@"uk",@"us"],
             @"fr":@[@"ca"]};
}

+ (NSDictionary *)twitterHPCareSupportLocales
{
    return @{@"de":@[@"at",@"lu",@"ch",@"de"],
             @"tr":@[@"tr"],
             @"fr":@[@"fr",@"ch"],
             @"es":@[@"es"]};
}

+ (NSArray *)fbMessengerEnglishSupport
{
    return @[@"ca",@"au",@"nz",@"sg",@"ie",@"gb",@"uk",@"us"];
}

+ (NSDictionary *)fbMessengerHPCareSupportLocales
{
    return @{@"de":@[@"at",@"lu",@"ch",@"de"],
             @"ru":@[@"ru"],
             @"tr":@[@"tr"],
             @"he":@[@"il"],
             @"fr":@[@"fr",@"ch"],
             @"es":@[@"es"]};
}

+ (BOOL)isTwitterSupportAvailable {
    NSArray *twitterHPSupportLocales = [[self twitterHPSupportLocales] objectForKey:[self deviceLanguageCode]];
    
    NSArray *twitterHPCareSupportLocales = [[self twitterHPCareSupportLocales] objectForKey:[self deviceLanguageCode]];
    
    if (twitterHPSupportLocales || twitterHPCareSupportLocales) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isFBMessengerSupportAvailable {
    return ([NSLocale messengerSupportURL].length != 0);
}

+ (NSString *)twitterHPCareSupportURL
{
    NSArray *supportedNonEnglishCountries = [[self twitterHPCareSupportLocales] objectForKey:[self deviceLanguageCode]];

    if (supportedNonEnglishCountries && [supportedNonEnglishCountries containsObject:[self deviceCountryCode]]) {
        if ([[self deviceLanguageCode] caseInsensitiveCompare:@"es"] == NSOrderedSame) {
            return [NSString stringWithFormat:kPGHPCareTwitterURLFormat,@"ESP"];
        } else {
            return  [NSString stringWithFormat:kPGHPCareTwitterURLFormat,[[self deviceLanguageCode] uppercaseString]];
        }
    }
    return nil;
}

+ (NSString *)messengerSupportURL
{
    NSArray *supportedNonEnglishCountries = [[self fbMessengerHPCareSupportLocales] objectForKey:[self deviceLanguageCode]];
    
    if (supportedNonEnglishCountries && [supportedNonEnglishCountries containsObject:[self deviceCountryCode]]) {

        return [self fbMessengerNonEnglishSupportURL];
        
    } else if ([[self fbMessengerEnglishSupport] containsObject:[self deviceCountryCode]]) {
        
        return [NSString stringWithFormat:kPGHPCareURLFormat,@"SprocketAP"];
        
    }
    
    return nil;
}

+ (NSString *)fbMessengerNonEnglishSupportURL
{
    if ([[self deviceLanguageCode] caseInsensitiveCompare:@"es"] == NSOrderedSame) {
        return [NSString stringWithFormat:kPGHPCareFBURLFormat,@"ESP"];
    } else if ([[self deviceCountryCode] caseInsensitiveCompare:@"il"] == NSOrderedSame) {
        return [NSString stringWithFormat:kPGHPCareFBURLFormat,[[self deviceCountryCode] uppercaseString]];
    } else {
        return [NSString stringWithFormat:kPGHPCareFBURLFormat,[[self deviceLanguageCode] uppercaseString]];
    }
}

+ (NSURL *)privacyURL
{
    NSString *languageCode = [self languageID];
    NSString *countryCode = [self countryID];
    NSString *url = [NSString stringWithFormat:kPrivacyStatementURLFormat, countryCode, languageCode];

    // NOTE: This is to hardcode no/no for norwegian because hp.com does not support no/nb
    if ([countryCode caseInsensitiveCompare:@"no"] == NSOrderedSame) {
        url = [NSString stringWithFormat:kPrivacyStatementURLFormat, countryCode, countryCode];
    }
    // NOTE: This is changing el/el to gr/el for greek
    if ([countryCode caseInsensitiveCompare:@"el"] == NSOrderedSame) {
        url = [NSString stringWithFormat:kPrivacyStatementURLFormat, @"gr", languageCode];
    }
    // NOTE: This is changing id/id to id/en for indonesian
    if ([countryCode caseInsensitiveCompare:@"id"] == NSOrderedSame) {
        url = [NSString stringWithFormat:kPrivacyStatementURLFormat, countryCode, @"en"];
    }
    // NOTE: This is changing th/th to th/en for thai
    if ([countryCode caseInsensitiveCompare:@"th"] == NSOrderedSame) {
        url = [NSString stringWithFormat:kPrivacyStatementURLFormat, countryCode, @"en"];
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
    } else if ([languageCode caseInsensitiveCompare:@"nl"] == NSOrderedSame) {
        url = kPGHelpAndHowToViewUserURLNl;
    } else if ([NSLocale isChinese]) {
        url = kPGHelpAndHowToViewUserURLZh;
    }
    
    return [NSURL URLWithString:url];
}

+ (NSURL *)buyPaperURL
{
    NSString *url = kPGBuyPaperURL;
    return [NSURL URLWithString:url];
}

+ (NSURL *)supportWebsiteURL
{
    NSString *url = kPGHelpAndHowToVisitWebsiteURL;

    if ([NSLocale isChinese]) {
        url = kPGHelpAndHowToVisitWebsiteURLZh;
    }

    return [NSURL URLWithString:url];
}

+ (NSURL *)supportForumURL
{
    NSString *url = kPGHelpAndHowToJoinForumSupportURL;
    
    if ([NSLocale isChinese]) {
        url = kPGHelpAndHowToJoinForumSupportURLZh;
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
