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

#import "HPPRInstagramMedia.h"
#import "HPPRInstagramPhotoProvider.h"

@interface HPPRInstagramMedia()

@end

@implementation HPPRInstagramMedia

+ (BOOL)shouldPresent:(NSDictionary *)mediaDict
{
    NSString *type = [mediaDict objectForKey:@"type"];
    
    if ([[HPPRInstagramPhotoProvider sharedInstance] displayVideos]) {
        return YES;
    }
    
    if ([type isEqualToString:@"image"]) {
        return YES;
    } else {
        return NO;
    }
}

- (id)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    
    if (self) {
        self.objectID = [attributes valueForKey:@"id"];
        self.socialProvider = tHPRMediaSocialProviderInstagram;

        self.userName = [attributes valueForKeyPath:@"user.username"];
        self.userProfilePicture = [attributes valueForKeyPath:@"user.profile_picture"];
        
        self.thumbnailUrl = [attributes valueForKeyPath:@"images.thumbnail.url"];
        self.standardUrl = [attributes valueForKeyPath:@"images.standard_resolution.url"];
        self.socialMediaImageUrl = [attributes valueForKey:@"link"];

        self.likes = [[attributes valueForKeyPath:@"likes.count"] integerValue];
        
        self.comments = [[attributes valueForKeyPath:@"comments.count"] integerValue];
        
        NSInteger createdTimeSince1970 = [[attributes valueForKey:@"created_time"] integerValue];
        self.createdTime = [NSDate dateWithTimeIntervalSince1970:createdTimeSince1970];
        
        if ([[attributes valueForKey:@"type"] isEqualToString:@"video"]) {
            self.mediaType = kHPRMediaTypeVideo;
            
            NSString *videoURL = [attributes valueForKeyPath:@"videos.standard_resolution.url"];
            
            if (videoURL != nil) {
                self.assetURL = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:videoURL] options:nil];
                self.videoPlaybackUri = videoURL;
            }
        } else { // TODO: handle image sequence
            self.mediaType = kHPRMediaTypeImage;
        }
        
        self.text = [attributes valueForKeyPath:@"caption.text"];
        
        if ([self.text isKindOfClass:[NSNull class]]) {
            self.text = nil;
        }
        
        id location = [attributes objectForKey:@"location"];
        if (![location isKindOfClass:[NSNull class]]) {
            id latitude = [location objectForKey:@"latitude"];
            id longitude = [location objectForKey:@"longitude"];
            if (latitude && longitude) {
                self.location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
            }
            self.locationName = [location objectForKey:@"name"];
        }
    }
    
    return self;
}

- (NSArray *)additionalLocations
{
    NSMutableArray *locations = [NSMutableArray array];
    if (self.locationName) {
        [locations addObject:self.locationName];
    }
    return [NSArray arrayWithArray:locations];
}

- (HPPRSelectPhotoProvider *)photoProvider {
    return [HPPRInstagramPhotoProvider sharedInstance];
}

@end
