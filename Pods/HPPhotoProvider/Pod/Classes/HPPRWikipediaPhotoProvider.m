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

#import "HPPRWikipediaPhotoProvider.h"
#import "HPPRCameraRollLoginProvider.h"
#import "NSBundle+HPPRLocalizable.h"

@implementation HPPRWikipediaPhotoProvider

+ (HPPRWikipediaPhotoProvider *)sharedInstance
{
    static dispatch_once_t once;
    static HPPRWikipediaPhotoProvider *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[HPPRWikipediaPhotoProvider alloc] init];
        sharedInstance.loginProvider = [HPPRCameraRollLoginProvider sharedInstance];
        sharedInstance.loginProvider.delegate = sharedInstance;
    });
    return sharedInstance;
}

#pragma mark - User Interface

- (NSString *)name
{
    return @"Wikipedia";
}

- (NSString *)localizedName
{
    return HPPRLocalizedString(@"Wikipedia", nil);
}

- (BOOL)showSearchButton
{
    return NO;
}

@end
