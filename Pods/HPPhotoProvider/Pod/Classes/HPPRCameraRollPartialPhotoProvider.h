//
//  HPPRCameraRollPartialPhotoProvider.h
//  Pods
//
//  Created by Fernando Caprio on 5/17/17.
//
//

#import "HPPRSelectPhotoProvider.h"

@interface HPPRCameraRollPartialPhotoProvider : HPPRSelectPhotoProvider

+ (HPPRCameraRollPartialPhotoProvider *)sharedInstance;
- (void) populateImagesForSameDayAsDate: (NSDate *) date;
- (void) populateIMagesForSameLocation: (CLLocation *) location andDistance: (float) distance;

@end
