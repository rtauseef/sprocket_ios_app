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

#import "HPPRGoogleAlbum.h"
#import "HPPR.h"
#import "HPPRCacheService.h"
#import "HPPRFlickrPhotoProvider.h"

@implementation HPPRGoogleAlbum

#pragma mark - Initialization

- (id)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    
    if (self) {
        self.provider = [HPPRFlickrPhotoProvider sharedInstance];
        self.objectID = [attributes objectForKey:@"id"];
        self.name = [[attributes objectForKey:@"title"] objectForKey:@"_content"];
        self.photoCount = [[attributes objectForKey:@"photos"] integerValue];
        self.coverPhotoThumbnailURL = [[attributes objectForKey:@"primary_photo_extras"] objectForKey:@"url_m"];
        self.coverPhotoFullSizeURL = [[attributes objectForKey:@"primary_photo_extras"] objectForKey:@"url_o"];
    }
    
    return self;
}

- (void)setAttributes:(NSDictionary *)attributes
{
    NSString *name = [[attributes objectForKey:@"title"] objectForKey:@"_content"];
    NSInteger photoCount = [[attributes objectForKey:@"photos"] integerValue];
    
    if (![self.name isEqualToString:name] ||
        (self.photoCount != photoCount)) {
        
        self.name = name;
        self.photoCount = photoCount;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:HPPR_ALBUM_CHANGE_NOTIFICATION object:nil];
    }
}

@end
