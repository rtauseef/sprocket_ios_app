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

#import "HPPRCameraRollPartialPhotoProvider.h"
#import "HPPRCameraRollMedia.h"
#import "NSBundle+HPPRLocalizable.h"
#import <Photos/Photos.h>
#import "HPPRCameraRollLoginProvider.h"

@interface HPPRCameraRollPartialPhotoProvider()

@property (strong, nonatomic) PHAssetCollection *assetCollection;
@property (strong, nonatomic) NSMutableArray *internalImagesCollection;

@end

@implementation HPPRCameraRollPartialPhotoProvider

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.internalImagesCollection = [NSMutableArray array];
    }
    return self;
}

+ (HPPRCameraRollPartialPhotoProvider *)sharedInstance
{
    static dispatch_once_t once;
    static HPPRCameraRollPartialPhotoProvider *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[HPPRCameraRollPartialPhotoProvider alloc] init];
        sharedInstance.loginProvider = [HPPRCameraRollLoginProvider sharedInstance];
    });
    return sharedInstance;
}

#pragma mark - User Interface

- (NSString *)name
{
    return @"Camera Roll";
}

- (NSString *)localizedName
{
    return HPPRLocalizedString(@"Camera Roll", @"Name of the camera roll app of the device");
}

- (BOOL)showSearchButton
{
    return NO;
}

- (BOOL)showNetworkWarning
{
    return NO;
}

- (NSString *)titleText
{
    return [NSString stringWithFormat:HPPRLocalizedString(@"%@ Photos", @"Photos of the specified social network"), self.name];
}

- (NSString *)headerText
{
    return @"No name";
}

#pragma mark - Photo list operations

- (void)requestImagesWithCompletion:(void (^)(NSArray *records))completion andReloadAll:(BOOL)reload
{
    if (completion) {
        completion(self.internalImagesCollection);
    }
}

- (void)populateImagesForSameLocation:(CLLocation *)location andDistance:(double)distance {
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithOptions:nil];
    
    self.internalImagesCollection = [NSMutableArray array];
    [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PHAsset *asset = (PHAsset *) obj;
        if (asset.location != nil) {
            CLLocation *assetLocation = asset.location;
            CLLocationDistance meters = [assetLocation distanceFromLocation:location];
            
            if (meters <= distance) {
                [self.internalImagesCollection addObject:[[HPPRCameraRollMedia alloc] initWithAsset:asset]];
            }
        }
    }];

    [self replaceImagesWithRecords:self.internalImagesCollection];
}

- (void)populateImagesForSameDayAsDate:(NSDate *)date
{
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay ) fromDate:date];
    
    NSDate *startDate = [calendar dateFromComponents:components];
    [components setDay:components.day+1];
    NSDate *endDate = [calendar dateFromComponents:components];
    
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"creationDate >= %@ AND creationDate < %@", startDate, endDate];
    
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithOptions:fetchOptions];
    
    self.internalImagesCollection = [NSMutableArray arrayWithCapacity:fetchResult.count];
    
    for (PHAsset *asset in fetchResult) {
        [self.internalImagesCollection addObject:[[HPPRCameraRollMedia alloc] initWithAsset:asset]];
    }
    
    [self replaceImagesWithRecords:self.internalImagesCollection];
}

@end
