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

@interface HPPRInstagramMedia()

@property (strong, nonatomic) NSString *placeName;

@end

@implementation HPPRInstagramMedia

+ (BOOL)isImage:(NSDictionary *)mediaDict
{
    NSString *type = [mediaDict objectForKey:@"type"];
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

        self.userName = [attributes valueForKeyPath:@"user.username"];
        self.userProfilePicture = [attributes valueForKeyPath:@"user.profile_picture"];
        
        self.thumbnailUrl = [attributes valueForKeyPath:@"images.thumbnail.url"];
        self.standardUrl = [attributes valueForKeyPath:@"images.standard_resolution.url"];
        
        self.likes = [[attributes valueForKeyPath:@"likes.count"] integerValue];
        
        self.comments = [[attributes valueForKeyPath:@"comments.count"] integerValue];
        
        NSInteger createdTimeSince1970 = [[attributes valueForKey:@"created_time"] integerValue];
        self.createdTime = [NSDate dateWithTimeIntervalSince1970:createdTimeSince1970];
        
        
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
            self.placeName = [location objectForKey:@"name"];
        }
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

@end
