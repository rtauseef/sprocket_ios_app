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

#import "HPPRQzoneMedia.h"
#import "HPPRQzonePhotoProvider.h"

@implementation HPPRQzoneMedia

- (id)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    
    if (self) {
        self.objectID = [attributes objectForKey:@"id"];
        self.thumbnailUrl = [attributes objectForKey:@"small_url"];
        self.standardUrl = [[attributes objectForKey:@"large_image"] objectForKey:@"url"];

        NSInteger createdTimeSince1970 = [[attributes valueForKey:@"uploaded_time"] integerValue];
        self.createdTime = [NSDate dateWithTimeIntervalSince1970:createdTimeSince1970];

        self.mediaType = kHPRMediaTypeImage;
        
        self.text = [attributes objectForKey:@"desc"];
    }
    
    return self;
}

- (HPPRSelectPhotoProvider *)photoProvider {
    return [HPPRQzonePhotoProvider sharedInstance];
}

@end
