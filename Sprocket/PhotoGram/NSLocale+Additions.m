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
static NSString * const kPrivacyStatementURLPart1 = @"http://www8.hp.com/";
static NSString * const kPrivacyStatementURLPart2 = @"/privacy/privacy.html";

// User Guides
static NSString * const kPGHelpAndHowToViewUserURL = @"http://h10032.www1.hp.com/ctg/Manual/c05280005";
static NSString * const kPGHelpAndHowToViewUserURLDe = @"http://h10032.www1.hp.com/ctg/Manual/c05320645";
static NSString * const kPGHelpAndHowToViewUserURLFr = @"http://h10032.www1.hp.com/ctg/Manual/c05320547";
static NSString * const kPGHelpAndHowToViewUserURLSp = @"http://h10032.www1.hp.com/ctg/Manual/c05320654";
static NSString * const kPGHelpAndHowToViewUserURLNl = @"http://h10032.www1.hp.com/ctg/Manual/c05320519";
static NSString * const kPGHelpAndHowToViewUserURLZh = @"http://h10032.www1.hp.com/ctg/Manual/c05359608";

// Buy Paper
static NSString * const kPGBuyPaperURL = @"http://www.hp.com/go/ZINKphotopaper";
static NSString * const kPGBuyPaperURLZh = @"http://www8.hp.com/cn/zh/printers/sprocket.html?jumpid=cp_r163_cn/zh/ipg/sprocket/app_paper#retail";

// Join Support
static NSString * const kPGHelpAndHowToJoinForumSupportURL = @"http://hp.care/sprocket";
static NSString * const kPGHelpAndHowToJoinForumSupportURLZh = @"http://h30471.www3.hp.com/t5/community/communitypage";

// Support Website
static NSString * const kPGHelpAndHowToVisitWebsiteURL = @"http://support.hp.com/us-en/product/HP-Sprocket-Photo-Printer/12635221";
static NSString * const kPGHelpAndHowToVisitWebsiteURLZh = @"http://h30471.www3.hp.com/t5/community/communitypage";

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
    return @{@"en":@"us", @"de":@"de", @"es":@"es", @"fr":@"fr", @"it":@"it", @"nl":@"nl",  @"et":@"ee", @"fi":@"fi", @"lv":@"lv", @"lt":@"lt", @"nb":@"no", @"pt":@"pt", @"sv":@"se", @"zh":@"cn", @"da":@"dk", @"el":@"el", @"id":@"id", @"ru":@"ru", @"tr":@"tr", @"th":@"th"};
}

+ (NSURL *)privacyURL
{
    NSString *url = kPrivacyStatementURL;

    NSString *languageCode = [self languageID];
    NSString *countryCode = [self countryID];

    url = [NSString stringWithFormat:@"%@%@/%@%@", kPrivacyStatementURLPart1, countryCode, languageCode, kPrivacyStatementURLPart2];

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
    
    if ([NSLocale isChinese]) {
        url = kPGBuyPaperURLZh;
    }
    
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
