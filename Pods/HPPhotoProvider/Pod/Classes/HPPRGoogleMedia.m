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
            self.socialMediaImageUrl = self.standardUrl;
            
            NSString *type = [photo objectForKey:@"type"];
            
            if ([type isEqualToString:@"image/gif"]) {
                self.mediaType = kHPRMediaTypeVideo;
            } else {
                self.mediaType = kHPRMediaTypeImage;
            }
        }
        
        NSString *timestamp = [attributes objectForKey:@"gphoto:timestamp"];
        
        if (timestamp) {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestamp longLongValue] / 1000];
            self.createdTime = date;
        }
        
        NSArray *thumbnails = [attributes objectForKey:@"thumbnails"];
        if (thumbnails) {
            NSDictionary *thumb = [thumbnails lastObject];
            self.thumbnailUrl = [thumb objectForKey:@"url"];
        }
        
        NSArray *contents = [attributes objectForKey:@"contents"];
        if (contents) {
            NSDictionary *content = [contents lastObject];
            NSString *medium = [content objectForKey:@"medium"];
            
            if (medium && [medium isEqualToString:@"video"]) {
                self.videoPlaybackUri = [content objectForKey:@"url"];
                self.mediaType = kHPRMediaTypeVideo;
                
                NSError *error = nil;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"/[^/]+/?$" options:NSRegularExpressionCaseInsensitive error:&error];
                NSString *modifiedString = [regex stringByReplacingMatchesInString:self.standardUrl options:0 range:NSMakeRange(0, [self.standardUrl length]) withTemplate:@"/s960-no-k/"];
                self.standardUrl = modifiedString;
                
                regex = [NSRegularExpression regularExpressionWithPattern:@"s([0-9]+)(\\-c-no)?/" options:NSRegularExpressionCaseInsensitive error:&error];
                self.thumbnailUrl = [regex stringByReplacingMatchesInString:self.thumbnailUrl options:0 range:NSMakeRange(0, [self.thumbnailUrl length]) withTemplate:@"s512-no-k/"];
            }
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
        
        self.socialProvider = tHPRMediaSocialProviderGoogle;
    }
    
    return self;
}

- (HPPRSelectPhotoProvider *)photoProvider {
    return [HPPRGooglePhotoProvider sharedInstance];
}

@end
