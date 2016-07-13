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

#import "HPPRFacebookAlbum.h"
#import "HPPR.h"
#import "HPPRFacebookPhotoProvider.h"
#import "HPPRCacheService.h"

@implementation HPPRFacebookAlbum

- (id)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    
    if (self) {
        self.provider = [HPPRFacebookPhotoProvider sharedInstance];
        self.objectID = [attributes objectForKey:@"id"];
        self.name = [attributes objectForKey:@"name"];
        self.photoCount = [[attributes objectForKey:@"count"] integerValue];
        NSDictionary *coverPhotoInfo = [attributes objectForKey:@"cover_photo"];
        if (coverPhotoInfo) {
            self.coverPhotoID = [coverPhotoInfo objectForKey:@"id"];
        }
    }
    
    return self;
}

- (void)setAttributes:(NSDictionary *)attributes
{
    NSString *name = [attributes objectForKey:@"name"];
    NSInteger photoCount = [[attributes objectForKey:@"count"] integerValue];
    NSDictionary *coverPhotoInfo = [attributes objectForKey:@"cover_photo"];
    NSString *coverPhotoID = nil;
    if (coverPhotoInfo) {
        coverPhotoID = [coverPhotoInfo objectForKey:@"id"];
    }

    if (![self.name isEqualToString:name] ||
        (self.photoCount != photoCount) ||
        ![self.coverPhotoID isEqualToString:coverPhotoID]) {
        
        self.name = name;
        self.photoCount = photoCount;
        self.coverPhotoID = coverPhotoID;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:HPPR_ALBUM_CHANGE_NOTIFICATION object:nil];
    }
}

@end
