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

#import "HPPRInstagramPhotoProvider.h"
#import "HPPRInstagram.h"
#import "HPPRInstagramUser.h"
#import "HPPRInstagramLoginProvider.h"
#import "HPPRInstagramTagMedia.h"
#import "HPPRInstagramUserMedia.h"
#import "HPPRInstagramError.h"
#import "UIView+HPPRAnimation.h"
#import "NSBundle+HPPRLocalizable.h"

#define PHOTO_SOURCE_SEGMENTED_CONTROL_MY_PHOTOS_INDEX 0
#define PHOTO_SOURCE_SEGMENTED_CONTROL_MY_FEED_INDEX 1

enum MCInstagramDisplayType {
    kStandard,
    kUserSearchResults,
    kHashtagSearchResults,
} MCInstagramDisplayType;

@interface HPPRInstagramPhotoProvider ()

@property (strong, nonatomic) NSString  *username;
@property (strong, nonatomic) NSString  *userId;
@property (strong, nonatomic) NSString *hashtag;
@property (strong, nonatomic) NSNumber *numPosts;
@property (strong, nonatomic) UIImage *userImage;
@property enum MCInstagramDisplayType displayType;
@property (strong, nonatomic) NSString *nextPageImagesMaxId;

@end

@implementation HPPRInstagramPhotoProvider{
    BOOL _fetchingInstagramPage;
}


#pragma mark - Initializers

+ (HPPRInstagramPhotoProvider *)sharedInstance
{
    static dispatch_once_t once;
    static HPPRInstagramPhotoProvider *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[HPPRInstagramPhotoProvider alloc] init];
        sharedInstance.loginProvider = [HPPRInstagramLoginProvider sharedInstance];
    });
    return sharedInstance;
}

- (void)initForStandardDisplay
{
    self.displayType = kStandard;
}

- (void)initWithHashtag:(NSString *)hashtag withNumPosts:(NSNumber *)numPosts
{
    self.displayType = kHashtagSearchResults;
    self.hashtag = hashtag;
    self.numPosts = numPosts;
}

- (void)initWithUsername:(NSString *)username andUserId:(NSNumber *)userId andImage:(UIImage *)userImage
{
    self.displayType = kUserSearchResults;
    self.username = username;
    self.userId = [NSString stringWithFormat:@"%@", userId];
    self.userImage = userImage;
}

- (void)applicationDidStart
{
    // TODO - prefetch stuff
}

#pragma mark - User Interface

- (NSString *)name
{
    return @"Instagram";
}

- (BOOL)showSearchButton
{
    return false; //(kStandard == self.displayType);
}

- (NSString *)titleText
{
    NSString *formattedText = [NSString stringWithFormat:HPPRLocalizedString(@"%@ Photos", @"Photos of the specified social network"), self.name];
    
    if (kHashtagSearchResults == self.displayType) {
        formattedText = [NSString stringWithFormat:@"#%@", self.hashtag];
    } else if (kUserSearchResults == self.displayType) {
        formattedText = [NSString stringWithFormat:@"@%@", self.username];
    }
    
    return formattedText;
}

- (NSString *)headerText
{
    NSString *formattedText = nil;
    
    if (kHashtagSearchResults == self.displayType) {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
        numberFormatter.locale = [NSLocale currentLocale];// this ensures the right separator behavior
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        numberFormatter.usesGroupingSeparator = YES;
        formattedText = [NSString stringWithFormat:HPPRLocalizedString(@"%@ posts", @"Number of posts"), [numberFormatter stringForObjectValue:self.numPosts]];
    } else if (kUserSearchResults == self.displayType) {
        formattedText = [NSString stringWithFormat:@"@%@", self.username];
    }
    
    return formattedText;
}

- (UIImage *)headerImage
{
    UIImage *image = nil;
    
    if (kUserSearchResults == self.displayType) {
        image = self.userImage;
    }
    
    return image;
}

#pragma mark - Network Access

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

- (void)cancelAllOperations
{
    [[[HPPRInstagram sharedClient] operationQueue] cancelAllOperations];
}

#pragma mark - Image Requesting

- (BOOL)hasMoreImages
{
    return self.nextPageImagesMaxId != nil;
}

- (void)requestImagesWithCompletion:(void (^)(NSArray *records))completion andReloadAll:(BOOL)reload
{
    [self requestImagesWithCompletion:completion andReloadAll:reload lastRequestOfTheChain:YES];
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
    
    __weak HPPRInstagramPhotoProvider * weakSelf = self;
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
            
            if (records != nil) {
                
                weakSelf.nextPageImagesMaxId = [instagramPage valueForKeyPath:@"pagination.next_max_id"];
                
                if (reload) {
                    imageCount = [weakSelf replaceImagesWithRecords:records];
                } else {
                    imageCount = [weakSelf updateImagesWithRecords:records];
                }
                
                // Note: To make sure we have enough photos to fullfil the entire collection view for having scroll we need to recursevily call the request images until we get that number or there are no more pics in the account.
                if (imageCount < [weakSelf imagesPerScreen] && weakSelf.nextPageImagesMaxId != nil) {
                    [weakSelf clearRequestBusy];
                    last = NO;
                    [weakSelf requestImagesWithCompletion:completion andReloadAll:NO lastRequestOfTheChain:YES];
                }
                
            }
        }
        
        if (last && completion) {
            completion(records);
        }
        
        [weakSelf clearRequestBusy];
    };
    
    if( kHashtagSearchResults == self.displayType ) {
        [HPPRInstagramTagMedia tagMediaRecent:self.hashtag nextMaxId:self.nextPageImagesMaxId completion:completionBlock];
    } else if( kUserSearchResults == self.displayType ) {
        [HPPRInstagramUserMedia userMediaRecentWithId:self.userId nextMaxId:self.nextPageImagesMaxId completion:completionBlock];
    }
    else {
        [HPPRInstagramUserMedia userMediaRecentWithId:@"self" nextMaxId:self.nextPageImagesMaxId completion:completionBlock];
    }
}

- (void)landingPagePhotoWithRefresh:(BOOL)refresh andCompletion:(void (^)(UIImage *photo, NSError *error))completion
{
    [HPPRInstagramUserMedia userFirstImageWithId:@"self" completion:^(UIImage *image) {
        if (image) {
            if (completion) {
                completion(image, nil);
            }
        } else {
            if (completion) {
                completion(nil, [[NSError alloc] init]);
            }
        }
    }];
}

@end