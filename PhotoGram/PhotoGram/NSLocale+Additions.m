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
    NSArray *supportedLanguages = @[@"en", @"fr", @"ru", @"de", @"es", @"nl", @"pl", @"pt", @"it", @"cs"];
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
    NSDictionary *supportedLocales = @{@"en":@"us", @"fr":@"fr", @"ru":@"ru", @"de":@"de", @"es":@"es", @"nl":@"nl", @"pl":@"pl", @"pt":@"pt", @"it":@"it", @"cs":@"cz"};
    
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
