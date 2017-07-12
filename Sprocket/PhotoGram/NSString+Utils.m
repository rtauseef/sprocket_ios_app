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

#import "NSString+Utils.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (Utils)

- (NSArray *)templatesForSource
{
    NSString *pathToPlist = [[NSBundle mainBundle] pathForResource:@"Templates" ofType:@"plist"];
    NSAssert(pathToPlist, @"Templates plist was not found!");
    
    NSDictionary *root = [NSDictionary dictionaryWithContentsOfFile:pathToPlist];
    
    NSArray *result = [root objectForKey:self];
    
    return result;
}

- (NSString *)md5
{
    const char *cstr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), result);

    NSMutableString *md5String = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH];

    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5String appendFormat:@"%02X", result[i]];
    }

    return md5String;
}

@end
