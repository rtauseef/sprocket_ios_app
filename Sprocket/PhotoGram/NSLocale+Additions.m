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


@implementation NSLocale (Additions)

+ (NSString *)languageID
{
    NSString *languageCode = @"en";
    NSArray *supportedLanguages = @[@"en", @"de", @"es", @"fr", @"it", @"nl", @"zh", @"da", @"et", @"fi", @"lv", @"lt", @"nb", @"pt", @"sv"];
    NSString *preferredLanguage = [[[NSLocale preferredLanguages] objectAtIndex:0] substringToIndex:2];
    
    if([supportedLanguages indexOfObject:preferredLanguage] == NSNotFound) {
        languageCode = @"en";
    } else {
        languageCode = preferredLanguage;
    }
    return languageCode;
}

+ (NSString *)countryID
{
    NSDictionary *supportedLocales = @{@"en":@"us", @"de":@"de", @"es":@"es", @"fr":@"fr", @"it":@"it", @"nl":@"nl", @"zh":@"zh", @"da":@"da", @"et":@"et", @"fi":@"fi",
        @"lv":@"lv", @"lt":@"lt", @"nb":@"nb", @"pt":@"pt", @"sv":@"sv"};
    
    NSString *countryCode = @"us";
    NSString *languageID = [self languageID];
    
    if ([supportedLocales objectForKey:languageID]) {
        countryCode = supportedLocales[languageID];
    }
    
    return countryCode;
}

+ (BOOL)isSurveyAvailable
{
    return [[self languageID] isEqualToString:@"en"];
}

@end
