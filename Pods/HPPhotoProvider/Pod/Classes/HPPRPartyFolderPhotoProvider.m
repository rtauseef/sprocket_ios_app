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

#import "HPPRPartyFolderPhotoProvider.h"
#import "NSBundle+HPPRLocalizable.h"

@implementation HPPRPartyFolderPhotoProvider

#pragma mark - Initialization

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static HPPRPartyFolderPhotoProvider *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[HPPRPartyFolderPhotoProvider alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Properties

- (NSString *)name
{
    return @"sprocket-party";
}

- (NSString *)localizedName
{
    return HPPRLocalizedString(@"sprocket-party", @"Name of the Sprocket Party camera roll folder");
}

@end
