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

#import "HPPRCameraRollAlbum.h"
#import "HPPR.h"
#import "HPPRCameraRollPhotoProvider.h"
#import "NSBundle+HPPRLocalizable.h"

@implementation HPPRCameraRollAlbum

- (id)initWithAssetGroup:(ALAssetsGroup *)group
{
    self = [super init];
    
    if (self) {
        self.group = group;
        self.provider = [HPPRCameraRollPhotoProvider sharedInstance];
        self.objectID = [[group valueForProperty:ALAssetsGroupPropertyURL] absoluteString];
        self.name = [group valueForProperty:ALAssetsGroupPropertyName];
        self.photoCount = [group numberOfAssets];
        self.coverPhoto = [UIImage imageWithCGImage:[group posterImage]];
    }
    
    return self;
}

- (void)setAAssetGroup:(ALAssetsGroup *)group
{
    NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
    NSInteger photoCount = [group numberOfAssets];
    UIImage *coverPhoto = [UIImage imageWithCGImage:[group posterImage]];
    
    if (![self.name isEqualToString:name] ||
        (self.photoCount != photoCount)) {
        
        self.name = name;
        self.photoCount = photoCount;
        self.coverPhoto = coverPhoto;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:HPPR_ALBUM_CHANGE_NOTIFICATION object:nil];
    }
}

@end
