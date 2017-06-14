//
//  HPPRInstagramFilteredPhotoProvider.m
//  Pods
//
//  Created by Fernando Caprio on 6/13/17.
//
//

#import "HPPRInstagramFilteredPhotoProvider.h"
#import "HPPRInstagramError.h"
#import "HPPRInstagramTagMedia.h"
#import "HPPRInstagramUserMedia.h"

@interface HPPRInstagramFilteredPhotoProvider()

@property (strong, nonatomic) NSString *nextPageImagesMaxId;
@property (assign, nonatomic) HPPRInstagramFilteredPhotoProviderMode filterMode;
@property (assign, nonatomic) int totalRecordsCount;

@end

@implementation HPPRInstagramFilteredPhotoProvider {
    BOOL _fetchingInstagramPage;
}

- (instancetype) initWithMode: (HPPRInstagramFilteredPhotoProviderMode) filteringMode
{
    self = [super init];
    if (self) {
        self.totalRecordsCount = 0;
        self.filterMode = filteringMode;
    }
    return self;
}

- (void)setRequestBusy
{
    _fetchingInstagramPage = YES;
}

- (void)clearRequestBusy
{
    _fetchingInstagramPage = NO;
}

- (BOOL)isRequestBusy
{
    return _fetchingInstagramPage;
}

- (void)requestImagesWithCompletion:(void (^)(NSArray *records))completion andReloadAll:(BOOL)reload lastRequestOfTheChain:(BOOL)lastRequestOfTheChain
{
    [self clearRequestBusy];
    
    if ([self isRequestBusy]) {
        NSLog(@"Ignoring request for images due to request already in process");
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    [self setRequestBusy];
    
    if (reload) {
        self.nextPageImagesMaxId = nil;
    }
    
    __weak HPPRInstagramFilteredPhotoProvider * weakSelf = self;
    
    void (^completionBlock)(NSDictionary *, NSError *) = ^(NSDictionary *instagramPage, NSError *error) {
        __block BOOL last = lastRequestOfTheChain;
        
        if (error != nil) {
            
            HPPRInstagramErrorType instagramError = [HPPRInstagramError errorType:error];
            
            switch (instagramError) {
                case INSTAGRAM_OP_COULD_NOT_COMPLETE:
                    // When switching between my photos and my feed, the first thing the app do is canceling the current request. When this happens the AFNetworking protocol used for communicating with the instagram API returns "The operation couldn’t be completed"
                    break;
                case INSTAGRAM_NO_INTERNET_CONNECTION:
                    [weakSelf lostConnection];
                    break;
                case INSTAGRAM_TOKEN_IS_INVALID:
                    [weakSelf lostAccess];
                    break;
                    
                case INSTAGRAM_USER_ACCOUNT_IS_PRIVATE:
                {
                    [weakSelf accessedPrivateAccount];
                    break;
                }
                case INSTAGRAM_UNRECOGNIZED_ERROR:
                    
                default:
                    break;
            }
            
            if (completion) {
                completion(nil);
            }
            
            [weakSelf clearRequestBusy];
            return;
            
        } else if ((instagramPage == nil) && (error == nil)) {
            [weakSelf lostAccess];
            return;
        }
        
        NSArray *records = nil;
        
        if (instagramPage != nil) {
            
            records = instagramPage[@"records"];
            NSUInteger imageCount = records.count;
            
            self.totalRecordsCount += (int) records.count;
            
            if (records != nil) {
                weakSelf.nextPageImagesMaxId = [instagramPage valueForKeyPath:@"pagination.next_max_id"];
                
                BOOL passedDate = NO;
                
                if (self.filterMode == HPPRInstagramFilteredPhotoProviderModeDate) {
                    NSDate *filterDate = self.instagramDelegate.instagramFilterContentByDate;
                    
                    HPPRMedia *lastRecord = [records lastObject];
                    
                    if (lastRecord) {
                        if ([[lastRecord createdTime] earlierDate:filterDate] == [lastRecord createdTime]) {
                            
                            // already passed
                            passedDate = YES;
                        }
                    }
                    
                    records = [self filterRecordsForDate:filterDate andRecords:records];
                } else if (self.filterMode == HPPRInstagramFilteredPhotoProviderModeLocation) {
                    CLLocation *filterLocation = [self.instagramDelegate instagramFilterContentByLocation];
                    int distance = [self.instagramDelegate instagramDistanceForLocationFilter];
                    
                    records = [self filterRecordsForLocation:filterLocation distance:distance andRecords:records];
                }
                
                if (reload) {
                    imageCount = [weakSelf replaceImagesWithRecords:records];
                } else {
                    imageCount = [weakSelf updateImagesWithRecords:records];
                }
                
                // Note: To make sure we have enough photos to fullfil the entire collection view for having scroll we need to recursevily call the request images until we get that number or there are no more pics in the account.
                
                if ((self.filterMode == HPPRInstagramFilteredPhotoProviderModeDate && self.totalRecordsCount > [self.instagramDelegate instagramMaxSearchDepth]) || passedDate) {
                    [weakSelf clearRequestBusy];
                    last = YES;
                } else if (imageCount < [weakSelf imagesPerScreen] && weakSelf.nextPageImagesMaxId != nil) {
                    [weakSelf clearRequestBusy];
                    last = NO;
                    [weakSelf requestImagesWithCompletion:completion andReloadAll:NO lastRequestOfTheChain:YES];
                }
            }
        }
        
        if (last && completion) {
            self.totalRecordsCount = 0;
            
            completion(records);
            
            if ([self.instagramDelegate respondsToSelector:@selector(instagramRequestPhotoComplete:)]) {
                [self.instagramDelegate instagramRequestPhotoComplete: (int) self.imageCount];
            }
        }
        
        [weakSelf clearRequestBusy];
    };
    
    [HPPRInstagramUserMedia userMediaRecentWithId:@"self" nextMaxId:self.nextPageImagesMaxId completion:completionBlock];
}


@end
