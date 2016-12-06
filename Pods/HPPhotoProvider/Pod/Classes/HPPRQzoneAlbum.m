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

#import "HPPRQzoneAlbum.h"
#import "HPPRQzonePhotoProvider.h"
#import "HPPRCacheService.h"

@implementation HPPRQzoneAlbum

- (id)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    
    if (self) {
        self.provider = [HPPRQzonePhotoProvider sharedInstance];
        self.objectID = [attributes objectForKey:@"albumid"];
        self.name = [attributes objectForKey:@"name"];
        self.photoCount = [[attributes objectForKey:@"picnum"] integerValue];
        self.coverPhoto = [[HPPRCacheService sharedInstance] imageForUrl:[attributes objectForKey:@"coverurl"]];
    }
    
    return self;
}

@end
