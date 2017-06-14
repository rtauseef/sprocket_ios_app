//
//  HPPRGoogleFilteredPhotoProvider.m
//  Pods
//
//  Created by Fernando Caprio on 6/13/17.
//
//

#import "HPPRGoogleFilteredPhotoProvider.h"
#import "HPPRGoogleMedia.h"
#import "HPPR.H"

static const NSInteger GOOGLE_FIRST_PHOTO_INDEX = 1;

@interface HPPRGoogleFilteredPhotoProvider()

@property (assign, nonatomic) HPPRGoogleFilteredPhotoProviderMode filterMode;
@property (assign, nonatomic) int totalRecordsCount;
@property (nonatomic, assign) NSInteger nextPhoto;

@end

@implementation HPPRGoogleFilteredPhotoProvider

- (instancetype) initWithMode: (HPPRGoogleFilteredPhotoProviderMode) filteringMode
{
    self = [super init];
    if (self) {
        self.totalRecordsCount = 0;
        self.filterMode = filteringMode;
        
        self.currentItems = [[NSMutableArray alloc] init];
        self.nextPhoto = GOOGLE_FIRST_PHOTO_INDEX;
        self.album = nil;
    }
    return self;
}

- (NSArray *) filterRecordsForDate:(NSDate *) filterDate andRecords:(NSArray *) records {
    NSMutableArray *updatedRecords = [NSMutableArray array];
    
    for(HPPRMedia *googleMedia in records) {
        if ([[NSCalendar currentCalendar] isDate:filterDate inSameDayAsDate:googleMedia.createdTime]) {
            [updatedRecords addObject:googleMedia];
        }
    }
    
    return updatedRecords;
}

- (NSArray *) filterRecordsForLocation:(CLLocation *) filterLocation distance: (int) distance andRecords:(NSArray *) records {
    NSMutableArray *updatedRecords = [NSMutableArray array];
    
    for(HPPRMedia *googleMedia in records) {
        if (googleMedia.location != nil) {
            if ([googleMedia.location distanceFromLocation:filterLocation] <= distance) {
                [updatedRecords addObject:googleMedia];
            }
        }
    }
    
    return updatedRecords;
}

- (NSArray *)photosFromItems:(NSArray *)items
{
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    for (NSDictionary *photo in items) {
        HPPRGoogleMedia *media = [[HPPRGoogleMedia alloc] initWithAttributes:photo];
        [photos addObject:media];
    }
    
    return photos;
}

- (void)requestImagesWithCompletion:(void (^)(NSArray *records))completion andReloadAll:(BOOL)reload
{
    if (reload) {
        self.currentItems = [[NSMutableArray alloc] init];
        self.nextPhoto = GOOGLE_FIRST_PHOTO_INDEX;
        self.totalRecordsCount = 0;
    }
    
    [self photosForAlbum:self.album.objectID withPaging:[NSString stringWithFormat:@"%ld", (long)self.nextPhoto] andCompletion:^(NSArray *records, NSError *error) {
        NSArray *photos = nil;
        if (nil == error) {
            photos = [self photosFromItems:records];
            
            if (self.filterMode == HPPRGoogleFilteredPhotoProviderModeDate) {
                photos = [self filterRecordsForDate:[self.googleDelegate googleFilterContentByDate] andRecords:photos];
            } else if (self.filterMode == HPPRGoogleFilteredPhotoProviderModeLocation) {
                photos = [self filterRecordsForLocation:[self.googleDelegate googleFilterContentByLocation] distance:[self.googleDelegate googleDistanceForLocationFilter] andRecords:photos];
            }
            
            if (nil == self.album.objectID) {
                self.album.photoCount = [photos count];
            }
            
            if (GOOGLE_FIRST_PHOTO_INDEX == self.nextPhoto) {
                [self replaceImagesWithRecords:photos];
            } else {
                [self updateImagesWithRecords:photos];
            }
            self.nextPhoto = self.nextPhoto + self.currentItems.count;
        }
        
        if (completion) {
            completion(photos);
        }
        
        if ([self.googleDelegate respondsToSelector:@selector(googleRequestPhotoComplete:)]) {
            [self.googleDelegate googleRequestPhotoComplete:(int) [photos count]];
        }
    }];

}

@end
