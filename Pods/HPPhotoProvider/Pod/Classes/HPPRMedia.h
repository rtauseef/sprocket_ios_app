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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface HPPRMedia : NSObject

@property (nonatomic, strong) NSString *objectID;

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userProfilePicture;
@property (nonatomic, strong) NSString *thumbnailUrl;
@property (nonatomic, strong) NSString *standardUrl;

@property (nonatomic, assign) NSUInteger likes;
@property (nonatomic, assign) NSUInteger comments;

@property (nonatomic, strong) NSDate *createdTime;

@property (nonatomic, strong) NSString *text;

@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) CLPlacemark *place;
@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) NSArray *additionalLocations;

@property (nonatomic, strong) NSString *isoSpeed;
@property (nonatomic, strong) NSString *shutterSpeed;

- (id)initWithAttributes:(NSDictionary *)attributes;

@end
