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

@end
