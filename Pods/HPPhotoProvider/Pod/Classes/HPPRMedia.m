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

#import "HPPRMedia.h"

@implementation HPPRMedia

- (NSString *)description
{
    return [NSString stringWithFormat:@"ID: %@ \nUserName: %@ \nUserProfilePic: %@ \nThumbnailUrl: %@\nStandardUrl: %@\nLikes: %lu\nComments: %lu\nCreatedDate: %@\nCaption: %@\nLocation: %@\nShutterSpeed: %@\nisoSpeed: %@", self.objectID, self.userName, self.userProfilePicture, self.thumbnailUrl, self.standardUrl, (unsigned long)self.likes, (unsigned long)self.comments, self.createdTime, self.text, self.locationName, self.shutterSpeed, self.isoSpeed];
}

- (id)initWithAttributes:(NSDictionary *)attributes
{
    // Must override in the baseclass
    return nil;
}

- (void)requestThumbnailImageWithCompletion:(void(^)(UIImage *image))completion
{
    // Must override in the baseclass
}

- (void)requestImageWithCompletion:(void(^)(UIImage *image))completion
{
    // Must override in the baseclass
}

- (void)cancelImageRequestWithCompletion:(void(^)())completion
{
    // Must override in the baseclass
}

- (NSArray *)additionalLocations
{
    return @[];
}

- (BOOL)isEqualToMedia:(HPPRMedia *)media {
    BOOL isEqual = NO;

    if ([media objectID]) {
        isEqual = [self.objectID isEqualToString:media.objectID];
    }

    return isEqual;
}

@end
