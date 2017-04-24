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
        
        HPPRGoogleLoginProvider * provider = [HPPRGoogleLoginProvider sharedInstance];
        
        self.objectID = [attributes objectForKey:@"id"];
        self.thumbnailUrl = [attributes objectForKey:@"url_m"];
        self.standardUrl = [attributes objectForKey:@"url_o"];
        
        self.userName = [provider.user objectForKey:@"userName"];
        
        self.userProfilePicture = [provider.user objectForKey:@"imageURL"];
        
        // NOTE: Don't localize this date, it comes from the API always in the same format regardless the language.
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateString = [attributes objectForKey:@"datetaken"];
        self.createdTime = [dateFormatter dateFromString:dateString];
        
        self.text = [attributes objectForKey:@"title"];
    }
    
    return self;
}

- (HPPRSelectPhotoProvider *)photoProvider {
    return [HPPRGooglePhotoProvider sharedInstance];
}

@end
