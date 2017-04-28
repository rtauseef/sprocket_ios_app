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

#import "HPPRFacebookMedia.h"
#import "HPPRFacebookPhotoProvider.h"

@interface HPPRFacebookMedia()

@property (strong, nonatomic) NSString *placeName;

@end

@implementation HPPRFacebookMedia

- (id)initWithVideoAttributes:(NSDictionary *)attributes {
    self = [super init];
    
    if (self) {
        self.mediaType = kHPRMediaTypeVideo;
        self.thumbnailUrl = [[HPPRFacebookPhotoProvider sharedInstance] urlForVideoThumbnail:attributes];
        self.standardUrl = [[HPPRFacebookPhotoProvider sharedInstance] urlForVideoPhoto:attributes];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSString *dateString = [attributes objectForKey:@"created_time"];
        self.createdTime = [dateFormatter dateFromString:dateString];
        
        id latitude = [[[attributes objectForKey:@"place"] objectForKey:@"location"] objectForKey:@"latitude"];
        id longitude = [[[attributes objectForKey:@"place"] objectForKey:@"location"] objectForKey:@"longitude"];
        if (latitude && longitude) {
            self.location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
        }
    }
    
    return self;
}

- (id)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    
    if (self) {
        self.objectID = [attributes objectForKey:@"id"];
        self.thumbnailUrl = [[HPPRFacebookPhotoProvider sharedInstance] urlForSmallestPhoto:attributes];
        self.standardUrl = [[HPPRFacebookPhotoProvider sharedInstance] urlForLargestPhoto:attributes];
        self.socialMediaImageUrl = [attributes objectForKey:@"link"];

        self.userName = [[attributes objectForKey:@"from"] objectForKey:@"name"];
        
        HPPRFacebookPhotoProvider * provider = [HPPRFacebookPhotoProvider sharedInstance];
        self.userProfilePicture = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", [provider.user objectForKey:@"id"]];
        
        // NOTE: Don't localize this date, it comes from the API always in the same format regardless the language.
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSString *dateString = [attributes objectForKey:@"created_time"];
        self.createdTime = [dateFormatter dateFromString:dateString];
        
        self.text = [attributes objectForKey:@"name"];
        
        id latitude = [[[attributes objectForKey:@"place"] objectForKey:@"location"] objectForKey:@"latitude"];
        id longitude = [[[attributes objectForKey:@"place"] objectForKey:@"location"] objectForKey:@"longitude"];
        if (latitude && longitude) {
            self.location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
        }
        
        self.placeName = [[attributes objectForKey:@"place"] objectForKey:@"name"];
        self.mediaType = kHPRMediaTypeImage;
    }
    
    return self;
}

- (NSArray *)additionalLocations
{
    NSMutableArray *locations = [NSMutableArray array];
    if (self.placeName) {
        [locations addObject:self.placeName];
    }
    return [NSArray arrayWithArray:locations];
}

- (HPPRSelectPhotoProvider *)photoProvider {
    return [HPPRFacebookPhotoProvider sharedInstance];
}

@end
