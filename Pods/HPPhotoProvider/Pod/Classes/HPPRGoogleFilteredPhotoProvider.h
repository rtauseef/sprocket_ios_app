//
//  HPPRGoogleFilteredPhotoProvider.h
//  Pods
//
//  Created by Fernando Caprio on 6/13/17.
//
//

#import <HPPRGooglePhotoProvider.h>

@protocol HPPRGoogleFilteredPhotoProviderDelegate <NSObject>

@required

- (NSDate *) googleFilterContentByDate;
- (int) googleMaxSearchDepth;
- (CLLocation *) googleFilterContentByLocation;
- (int) googleDistanceForLocationFilter; // meters

@optional

- (void) googleRequestPhotoComplete:(int) count;

@end

@interface HPPRGoogleFilteredPhotoProvider : HPPRGooglePhotoProvider

typedef enum HPPRGoogleFilteredPhotoProviderMode {
    HPPRGoogleFilteredPhotoProviderModeLocation,
    HPPRGoogleFilteredPhotoProviderModeDate,
    HPPRGoogleFilteredPhotoProviderModeUnknown
} HPPRGoogleFilteredPhotoProviderMode;

@property (weak, nonatomic) id<HPPRGoogleFilteredPhotoProviderDelegate> googleDelegate;

- (instancetype) initWithMode: (HPPRGoogleFilteredPhotoProviderMode) filteringMode;

@end
