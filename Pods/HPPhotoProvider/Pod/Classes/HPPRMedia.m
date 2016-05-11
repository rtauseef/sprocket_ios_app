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

- (NSArray *)additionalLocations
{
    return @[];
}

@end
