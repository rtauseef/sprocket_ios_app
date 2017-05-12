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

#import "HPPRGoogleMedia.h"
#import "HPPRGoogleLoginProvider.h"
#import "HPPRGooglePhotoProvider.h"

@implementation HPPRGoogleMedia

- (id)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    
    if (self) {
        self.objectID = [attributes objectForKey:@"gphoto:id"];
        
        NSDictionary *photo = [attributes objectForKey:@"original"];
        if (photo) {
            self.standardUrl = [photo objectForKey:@"src"];
        }
        
        NSArray *thumbnails = [attributes objectForKey:@"thumbnails"];
        if (thumbnails) {
            NSDictionary *thumb = [thumbnails lastObject];
            self.thumbnailUrl = [thumb objectForKey:@"url"];
        }
        
        self.userName = [attributes objectForKey:@"userName"];
        
        self.userProfilePicture = [attributes objectForKey:@"userThumbnail"];
        
        // NOTE: Don't localize this date, it comes from the API always in the same format regardless the language.
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateString = [attributes objectForKey:@"updated"];
        self.createdTime = [dateFormatter dateFromString:dateString];
        
        self.text = [attributes objectForKey:@"title"];
        
        self.objectID = self.standardUrl;
    }
    
    return self;
}

- (HPPRSelectPhotoProvider *)photoProvider {
    return [HPPRGooglePhotoProvider sharedInstance];
}

@end
