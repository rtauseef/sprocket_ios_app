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

@implementation NSString (Utils)

- (NSArray *)templatesForSource
{
    NSString *pathToPlist = [[NSBundle mainBundle] pathForResource:@"Templates" ofType:@"plist"];
    NSAssert(pathToPlist, @"Templates plist was not found!");
    
    NSDictionary *root = [NSDictionary dictionaryWithContentsOfFile:pathToPlist];
    
    NSArray *result = [root objectForKey:self];
    
    return result;
}

@end
