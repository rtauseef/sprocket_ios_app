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
                self.mediaType = HPPRMediaTypeVideo;
            } else {
                self.mediaType = HPPRMediaTypeImage;
            }
        }
        
        NSString *timestamp = [attributes objectForKey:@"gphoto:timestamp"];
        
        if (timestamp) {
            double when = [timestamp longLongValue] / 1000;
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:when];
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
                self.mediaType = HPPRMediaTypeVideo;
                
                NSError *error = nil;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"/[^/]+/?$" options:NSRegularExpressionCaseInsensitive error:&error];
                NSString *modifiedString = [regex stringByReplacingMatchesInString:self.standardUrl options:0 range:NSMakeRange(0, [self.standardUrl length]) withTemplate:@"/s960-no-k/"];
                self.standardUrl = modifiedString;
                
                regex = [NSRegularExpression regularExpressionWithPattern:@"s([0-9]+)(\\-c-no)?/" options:NSRegularExpressionCaseInsensitive error:&error];
                self.thumbnailUrl = [regex stringByReplacingMatchesInString:self.thumbnailUrl options:0 range:NSMakeRange(0, [self.thumbnailUrl length]) withTemplate:@"s512-no-k/"];
            }
        }
        
        HPPRGoogleLoginProvider *provider = [HPPRGoogleLoginProvider sharedInstance];

        self.userName = [attributes objectForKey:@"userName"];
        if (self.userName.length == 0) {
            self.userName = [provider.user objectForKey:@"userName"];
        }
        
        self.userProfilePicture = [attributes objectForKey:@"userThumbnail"];
        if (self.userProfilePicture.length == 0) {
            self.userProfilePicture = [provider.user objectForKey:@"imageURL"];
        }
        
        // NOTE: Don't localize this date, it comes from the API always in the same format regardless the language.
        /*NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateString = [attributes objectForKey:@"updated"];
        self.createdTime = [dateFormatter dateFromString:dateString];*/
        
        self.text = [attributes objectForKey:@"media:description"];
        
        self.objectID = self.standardUrl;
        
        self.socialProvider = HPPRSocialMediaProviderGoogle;
   
        self.isoSpeed = [attributes objectForKey:@"exif:iso"];
        
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        
        if ([attributes objectForKey:@"exif:exposure"])
            self.exposureTime = [f numberFromString:[attributes objectForKey:@"exif:exposure"]];
        
        if ([attributes objectForKey:@"exif:fstop"])
            self.aperture = [f numberFromString:[attributes objectForKey:@"exif:fstop"]];
        
        if ([attributes objectForKey:@"exif:flash"])
            self.flash = [attributes objectForKey:@"exif:flash"] && [[attributes objectForKey:@"exif:flash"] isEqualToString:@"true"] ? [NSNumber numberWithBool:true] : [NSNumber numberWithBool:false];
        
        if ([attributes objectForKey:@"exif:focallength"])
            self.focalLength = [f numberFromString:[attributes objectForKey:@"exif:focallength"]];
        
        self.cameraMake = [attributes objectForKey:@"exif:make"];
        self.cameraModel = [attributes objectForKey:@"exif:model"];
        
        if ([attributes objectForKey:@"gml:pos"]) {
            NSArray *latlon = [[attributes objectForKey:@"gml:pos"] componentsSeparatedByString: @" "];
            if ([latlon count] == 2) {
                NSNumber *lat = [f numberFromString:latlon[0]];
                NSNumber *lon = [f numberFromString:latlon[1]];
                
                if (lat && lon) {
                    self.location = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lon doubleValue]];
                }
            }
        }
        
    }
    
    return self;
}

- (HPPRSelectPhotoProvider *)photoProvider {
    return [HPPRGooglePhotoProvider sharedInstance];
}

@end
