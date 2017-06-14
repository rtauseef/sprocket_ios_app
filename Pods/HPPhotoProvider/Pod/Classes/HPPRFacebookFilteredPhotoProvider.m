//
//  HPPRFacebookFilteredPhotoProvider.m
//  Pods
//
//  Created by Fernando Caprio on 6/13/17.
//
//

#import "HPPRFacebookFilteredPhotoProvider.h"
#import "HPPRFacebookMedia.h"

#define FACEBOOK_DEFAULT_LOCATION_DISTANCE 1000
#define FACEBOOK_MAX_PHOTO_SEARCH 250

@interface HPPRFacebookFilteredPhotoProvider()

@property (strong, nonatomic) NSString *maxPhotoID;
@property (assign, nonatomic) int totalPhotoSearchCount;
@property (assign, nonatomic) HPPRFacebookFilteredPhotoProviderMode filterMode;

@end

@implementation HPPRFacebookFilteredPhotoProvider

- (instancetype) initWithMode: (HPPRFacebookFilteredPhotoProviderMode) filteringMode
{
    self = [super init];
    if (self) {
        self.filterMode = filteringMode;
    }
    return self;
}

- (void)requestImagesWithCompletion:(void (^)(NSArray *records))completion andReloadAll:(BOOL)reload
{
    if (reload) {
        self.maxPhotoID = nil;
        self.totalPhotoSearchCount = 0;
    }
    
    if (self.filterMode == HPPRFacebookFilteredPhotoProviderModeLocation) {
        
        __block BOOL failed = NO;
        __block BOOL finished = NO;
        __block NSMutableArray *totalRecords = [NSMutableArray array];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            while (self.totalPhotoSearchCount < FACEBOOK_MAX_PHOTO_SEARCH && !failed && !finished) {
                
                NSLog(@"FB current photo count: %d", self.totalPhotoSearchCount);
                dispatch_group_t facebookGroup = dispatch_group_create();
                dispatch_group_enter(facebookGroup);
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self photosForAlbum:self.album.objectID withRefresh:reload andPaging:self.maxPhotoID andCompletion:^(NSDictionary *photoInfo, NSError *error) {
                        
                        NSArray *records = nil;
                        NSArray *photos = nil;
                        
                        if (!error) {
                            photos = [photoInfo objectForKey:@"data"];
                            NSString *maxPhotoID = [[[photoInfo objectForKey:@"paging"] objectForKey:@"cursors"] objectForKey:@"after"];
                            NSMutableArray *mutableRecords = [NSMutableArray array];
                            for (NSDictionary * photo in photos) {
                                
                                NSDictionary *photoDictLocation = [[photo objectForKey:@"place"] objectForKey:@"location"];
                                
                                if (photoDictLocation != nil) {
                                    id latitude = [photoDictLocation objectForKey:@"latitude"];
                                    id longitude = [photoDictLocation objectForKey:@"longitude"];
                                    if (latitude && longitude) {
                                        CLLocation *photoLocation = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
                                        CLLocation *centerLocation = self.fbDelegate.fbFilterContentByLocation;
                                        
                                        int distanceMeters = [self.fbDelegate respondsToSelector:@selector(fbDistanceForLocationFilter)] ? [self.fbDelegate fbDistanceForLocationFilter] : FACEBOOK_DEFAULT_LOCATION_DISTANCE;
                                        
                                        int currentDistance = [centerLocation distanceFromLocation:photoLocation];
                                        
                                        if (currentDistance <= distanceMeters) {
                                            __block HPPRFacebookMedia * media = [[HPPRFacebookMedia alloc] initWithAttributes:photo];
                                            [mutableRecords addObject:media];
                                        }
                                    }
                                }
                            }
                            
                            records = mutableRecords.copy;
                            [totalRecords addObjectsFromArray:records];
                            
                            if (self.maxPhotoID) {
                                [self updateImagesWithRecords:records];
                                self.totalPhotoSearchCount += (int) [photos count];
                            } else {
                                [self replaceImagesWithRecords:records];
                                self.totalPhotoSearchCount = 0;
                            }
                            
                            self.maxPhotoID = maxPhotoID;
                            
                            if (self.maxPhotoID == nil) {
                                finished = YES;
                            }
                        }  else {
                            NSLog(@"ALBUM PHOTOS ERROR\n%@", error);
                            failed = YES;
                            [self lostAccess];
                        }
                        
                        dispatch_group_leave(facebookGroup);
                    }];
                });
                
                dispatch_group_wait(facebookGroup, DISPATCH_TIME_FOREVER);
            }
        
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(totalRecords);
                }
                
                if ([self.fbDelegate respondsToSelector:@selector(fbRequestPhotoComplete:)]) {
                    [self.fbDelegate fbRequestPhotoComplete:(int) [totalRecords count]];
                }
            });
            
        });
    } else if (self.filterMode == HPPRFacebookFilteredPhotoProviderModeDate) {
         [self photoForDayInDate:self.fbDelegate.fbFilterContentByDate withRefresh:reload andPaging:self.maxPhotoID andCompletion:^(NSDictionary *photoInfo, NSError *error) {
             NSArray *records = nil;
             
             if (!error) {
                 NSArray * photos = [photoInfo objectForKey:@"data"];
                 NSString *maxPhotoID = [[[photoInfo objectForKey:@"paging"] objectForKey:@"cursors"] objectForKey:@"after"];
                 NSMutableArray *mutableRecords = [NSMutableArray array];
                 for (NSDictionary * photo in photos) {
                     __block HPPRFacebookMedia * media = [[HPPRFacebookMedia alloc] initWithAttributes:photo];
                     [mutableRecords addObject:media];
                 }
                 
                 records = mutableRecords.copy;
                 
                 if (self.maxPhotoID) {
                     [self updateImagesWithRecords:records];
                 } else {
                     [self replaceImagesWithRecords:records];
                 }
                 self.maxPhotoID = maxPhotoID;
             } else {
                 NSLog(@"ALBUM PHOTOS ERROR\n%@", error);
                 [self lostAccess];
             }
             
             if (completion) {
                 completion(records);
             }
             
             if ([self.fbDelegate respondsToSelector:@selector(fbRequestPhotoComplete:)]) {
                 [self.fbDelegate fbRequestPhotoComplete:(int) [records count]];
             }
         }];
    }
 }


@end
