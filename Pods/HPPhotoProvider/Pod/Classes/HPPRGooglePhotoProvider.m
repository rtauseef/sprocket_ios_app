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

#import "HPPRGooglePhotoProvider.h"
#import "HPPR.h"
#import "HPPRGoogleLoginProvider.h"
#import "HPPRGoogleMedia.h"
#import "HPPRGoogleAlbum.h"
#import "HPPRGoogleXmlParser.h"
#import "HPPRCacheService.h"
#import "NSBundle+HPPRLocalizable.h"


static const long GOOGLE_PAGE_SIZE = 100;
static const NSInteger GOOGLE_FIRST_PHOTO_INDEX = 1;

@interface HPPRGooglePhotoProvider() <HPPRGoogleXmlParserDelegate>

@property (nonatomic, assign) NSInteger nextPhoto;
@property (nonatomic, strong) NSString *numberOfAllPhotos;
@property (nonatomic, strong) NSString *lastUserID;
@property (nonatomic, strong) NSMutableArray *currentItems;
@property (nonatomic, strong) NSString *userThumbnail;
@property (nonatomic, strong) NSString *userName;
@property (strong) NSString *latestRequest;

@end

@implementation HPPRGooglePhotoProvider

#pragma mark - Initialization

+ (HPPRGooglePhotoProvider *)sharedInstance
{
    static dispatch_once_t once;
    static HPPRGooglePhotoProvider *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[HPPRGooglePhotoProvider alloc] init];
        sharedInstance.loginProvider = [HPPRGoogleLoginProvider sharedInstance];
        sharedInstance.currentItems = [[NSMutableArray alloc] init];
        sharedInstance.nextPhoto = GOOGLE_FIRST_PHOTO_INDEX;
    });
    return sharedInstance;
}

- (void)applicationDidStart
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[HPPRGoogleLoginProvider sharedInstance] checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
            if (loggedIn) {
                [self albumsWithRefresh:YES andCompletion:^(NSArray *albums, NSError *error) {
                    if (!error) {
                        for (HPPRGoogleAlbum *album in albums) {
                            [self coverPhotoForAlbum:album withRefresh:YES andCompletion:nil];
                        }
                        [self landingPagePhotoWithRefresh:YES andCompletion:nil];
                    }
                }];
            }
        }];
    });
}

#pragma mark - User Interface

- (NSString *)name
{
    return @"Google";
}

- (BOOL)showSearchButton
{
    return NO;
}

- (NSString *)titleText
{
    return [NSString stringWithFormat:HPPRLocalizedString(@"%@ Photos", @"Photos of the specified social network"), self.name];
}

- (NSString *)headerText
{
    NSMutableString *text = [NSMutableString stringWithString:@""];
    NSUInteger count = self.album.photoCount;
    
    if (nil != self.album.name) {
        text = [NSMutableString stringWithFormat:@"%@", self.album.name];
    }
    
    if (1 == count) {
        [text appendString:HPPRLocalizedString(@" (1 photo)", nil)];
    } else if (count > 1) {
        [text appendFormat:HPPRLocalizedString(@" (%lu photos)", @"Number of photos"), (unsigned long)count];
    }

    return [NSString stringWithString:text];
}

#pragma mark - Photo requests

- (void)cancelAllOperations
{
    [super cancelAllOperations];
}

- (BOOL)isImageRequestsCancelled
{
    BOOL cancelled = super.isImageRequestsCancelled;
    
    return cancelled;
}

- (BOOL)hasMoreImages
{
    NSInteger nextPhoto = self.nextPhoto;
    
    return ((nextPhoto <= self.album.photoCount) ||  (nil == self.album.objectID  &&  0 == self.album.photoCount));
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
    }
    
    [self photosForAlbum:self.album.objectID withPaging:[NSString stringWithFormat:@"%ld", (long)self.nextPhoto] andCompletion:^(NSArray *records, NSError *error) {
        NSArray *photos = nil;
        if (nil == error) {
            photos = [self photosFromItems:records];
            
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
    }];
}

#pragma mark - Albums

- (HPPRGoogleAlbum *)allPhotosAlbum
{
    HPPRGoogleAlbum *allPhotos = [[HPPRGoogleAlbum alloc] init];
    allPhotos.name = HPPRLocalizedString(@"Recent Photos", @"Indicates that recent photos will be displayed");
    
    return allPhotos;
}

- (void)refreshAlbumWithCompletion:(void (^)(NSError *error))completion
{
    // We don't need to refresh album contents in Google, we query directly for album photos
    if (completion) {
        completion(nil);
    }
}

- (void)albumsWithRefresh:(BOOL)refresh andCompletion:(void (^)(NSArray *albums, NSError *error))completion
{
    [self getAlbums:^(NSArray *records, NSError *error) {
        NSArray *finalAlbums = nil;
       
        if (nil == error) {
            NSMutableArray *albums = [NSMutableArray array];
            
            HPPRGoogleAlbum *allPhotos = [self allPhotosAlbum];
            [albums addObject:allPhotos];
            
            for (NSDictionary *record in records) {
                HPPRGoogleAlbum *album = [[HPPRGoogleAlbum alloc] initWithAttributes:record];
                [albums addObject:album];
            }
            
            allPhotos.coverPhotoThumbnailURL = ((HPPRGoogleAlbum *)(albums[albums.count - 1])).coverPhotoThumbnailURL;
            allPhotos.coverPhotoFullSizeURL = ((HPPRGoogleAlbum *)(albums[albums.count - 1])).coverPhotoFullSizeURL;
            allPhotos.provider = ((HPPRGoogleAlbum *)(albums[albums.count - 1])).provider;
        
            finalAlbums = [NSArray arrayWithArray:albums];
        }
        
        if (completion) {
            completion(finalAlbums, error);
        }
    }];
}

#pragma mark - getting data

- (void)getPhotos:(NSString *)startIndex completion:(void (^)(NSArray *records, NSError *error))completion
{
    if (nil == self.album) {
        self.album = [self allPhotosAlbum];
    }
    
    // We need to sub the %5B and %5D for [ and ] in order to string compare
    //  on the query returned by our NSURLRequest...
    NSString *searchFields = @"entry%5Bmedia:group/media:content/@medium!='video'%5D(title,content,media:group/media:content,media:group/media:thumbnail)";
    
    NSString *url = [NSString stringWithFormat:@"https://picasaweb.google.com/data/feed/api/user/default?kind=photo&fields=openSearch:totalResults,gphoto:thumbnail,gphoto:nickname,%@", searchFields];

    if (self.album.objectID) {
        url = [NSString stringWithFormat:@"https://picasaweb.google.com/data/feed/api/user/default/albumid/%@?fields=openSearch:totalResults,%@", self.album.objectID, searchFields];
        url = [url stringByAppendingString:[NSString stringWithFormat:@"&start-index=%@&max-results=%ld", startIndex, GOOGLE_PAGE_SIZE]];
    }
   
    [self parseXMLFileAtURL:url completion:completion];
}

- (void) getAlbums:(void (^)(NSArray *records, NSError *error))completion
{
    [self parseXMLFileAtURL:@"https://picasaweb.google.com/data/feed/api/user/default?kind=album" completion:completion];
}
    
- (void)photosForAlbum:(NSString *)albumID withPaging:(NSString *)startIndex andCompletion:(void (^)(NSArray *items, NSError *error))completion
{
    if ([self hasMoreImages]) {
        [self getPhotos:startIndex completion:completion];
    }
}

- (void)landingPagePhotoWithRefresh:(BOOL)refresh andCompletion:(void (^)(UIImage *photo, NSError *error))completion
{
    [self albumsWithRefresh:refresh andCompletion:^(NSArray *albums, NSError *error) {
        if (error) {
            NSLog(@"LANDING PAGE PHOTO ERROR\n%@", error);
            if (completion) {
                completion(nil, error);
            }
        } else {
            if (0 == [albums count]) {
                if (completion) {
                    completion(nil, [[NSError alloc] init]);
                }
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    HPPRGoogleAlbum * firstAlbum = (HPPRGoogleAlbum *)albums[0];
                    UIImage * photo = [[HPPRCacheService sharedInstance] imageForUrl:firstAlbum.coverPhotoFullSizeURL];
                    if (completion) {
                        completion(photo, nil);
                    }
                });
            }
        }
    }];
}

- (void)coverPhotoForAlbum:(HPPRAlbum *)album withRefresh:(BOOL)refresh andCompletion:(void (^)(HPPRAlbum *album, UIImage *coverPhoto, NSError *error))completion
{
    HPPRGoogleAlbum *googleAlbum = (HPPRGoogleAlbum *)album;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        album.coverPhoto = [[HPPRCacheService sharedInstance] imageForUrl:googleAlbum.coverPhotoThumbnailURL];
        if (completion) {
            completion(album, album.coverPhoto, nil);
        }
    });
}

#pragma mark - XML File Retrieval and Parsing

- (void)parseXMLFileAtURL:(NSString *)URL completion:(void (^)(NSArray *records, NSError *error))completion
{
    self.latestRequest = [URL componentsSeparatedByString:@"?"][0];
    
    HPPRGoogleXmlParser *parser = [[HPPRGoogleXmlParser alloc] initWithUrl:URL delegate:self completion:completion];
    [parser startParsing];
}

- (void)didFinishParsing:(HPPRGoogleXmlParser *)parser items:(NSMutableArray *)items completion:(void (^)(NSArray *records, NSError *error))completion
{
    NSString *baseUrl = [parser.url componentsSeparatedByString:@"?"][0];
    
    if ([baseUrl isEqualToString:self.latestRequest]  &&  completion) {
        self.currentItems = items;
        completion(self.currentItems, parser.error);
    } else {
        NSLog(@"Ignoring results from URL: %@", parser.url);
    }
    
    parser = nil;
}

@end
