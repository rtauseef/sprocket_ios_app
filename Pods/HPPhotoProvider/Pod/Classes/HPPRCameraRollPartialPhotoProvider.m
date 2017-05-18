//
//  HPPRCameraRollPartialPhotoProvider.m
//  Pods
//
//  Created by Fernando Caprio on 5/17/17.
//
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

//int const kPhotosPerRequest = 50;

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
    /*NSMutableString *text = [NSMutableString stringWithFormat:@"%@", self.album.name];
    NSUInteger photoCount = self.album.photoCount;
    
    if (1 == photoCount) {
        [text appendString:HPPRLocalizedString(@" (1 photo)", nil)];
    } else {
        [text appendFormat:HPPRLocalizedString(@" (%lu photos)", @"Number of photos"), (unsigned long)photoCount];
    }
    
    if (self.displayVideos) {
        NSUInteger videoCount = self.album.videoCount;
        
        if (1 == videoCount) {
            [text appendString:HPPRLocalizedString(@" (1 video)", nil)];
        } else {
            [text appendFormat:HPPRLocalizedString(@" (%lu videos)", @"Number of videos"), (unsigned long)photoCount];
        }
    }
    
    return [NSString stringWithString:text];*/
    
    return @"No name";
}

#pragma mark - Photo list operations

- (void)requestImagesWithCompletion:(void (^)(NSArray *records))completion andReloadAll:(BOOL)reload
{
    completion(@{ @"data": self.internalImagesCollection });
}

- (void) populateIMagesForSameLocation: (CLLocation *) location andDistance: (float) distance {
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
- (void) populateImagesForSameDayAsDate: (NSDate *) date
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
