//
//  HPPRInstagramFilteredPhotoProvider.h
//  Pods
//
//  Created by Fernando Caprio on 6/13/17.
//
//

#import <HPPRInstagramPhotoProvider.h>

@protocol HPPRInstagramFilteredPhotoProviderDelegate <NSObject>

@required

- (NSDate *) instagramFilterContentByDate;
- (int) instagramMaxSearchDepth;
- (CLLocation *) instagramFilterContentByLocation;
- (int) instagramDistanceForLocationFilter; // meters

@optional

- (void) instagramRequestPhotoComplete:(int) count;

@end

@interface HPPRInstagramFilteredPhotoProvider : HPPRInstagramPhotoProvider

typedef enum HPPRInstagramFilteredPhotoProviderMode {
    HPPRInstagramFilteredPhotoProviderModeLocation,
    HPPRInstagramFilteredPhotoProviderModeDate,
    HPPRInstagramFilteredPhotoProviderModeUnknown
} HPPRInstagramFilteredPhotoProviderMode;

@property (weak, nonatomic) id<HPPRInstagramFilteredPhotoProviderDelegate> instagramDelegate;

- (instancetype) initWithMode: (HPPRInstagramFilteredPhotoProviderMode) filteringMode;

@end
