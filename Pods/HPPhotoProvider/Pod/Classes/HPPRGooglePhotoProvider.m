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
#import "HPPRCacheService.h"
#import "NSBundle+HPPRLocalizable.h"
#import <Google/SignIn.h>


static const long GOOGLE_PAGE_SIZE = 20;
static const NSInteger GOOGLE_FIRST_PHOTO_INDEX = 1;

@interface HPPRGooglePhotoProvider() <NSXMLParserDelegate>
{
    NSXMLParser *rssParser;
    NSMutableDictionary *item;
    NSMutableDictionary *link;
    NSString *currentElement;
    NSMutableString *ElementValue;
    BOOL errorParsing;
}

@property (nonatomic, assign) NSInteger nextPhoto;
@property (nonatomic, strong) NSString *numberOfAllPhotos;
@property (nonatomic, strong) NSString *lastUserID;
@property (nonatomic, strong) NSMutableArray *currentItems;
@property (nonatomic, strong) NSMutableArray *currentParsingItems;
@property (nonatomic, strong) NSString *userThumbnail;
@property (nonatomic, strong) NSString *userName;
@property (strong) NSString *latestRequest;
@property (copy) void (^xmlCompletionBlock)(NSError *error);


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

- (NSArray *)photosFromCurrentItems
{
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    for (NSDictionary *photo in self.currentItems) {
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
    
    [self photosForAlbum:self.album.objectID withRefresh:reload andPaging:[NSString stringWithFormat:@"%ld", (long)self.nextPhoto] andCompletion:^(NSDictionary *records, NSError *error) {
        NSArray *photos = nil;
        if (nil == error) {
            photos = [self photosFromCurrentItems];
            
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
    allPhotos.name = HPPRLocalizedString(@"All Photos", @"Indicates that all photos will be displayed");
    
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
    [self getAlbums:^(NSError *error) {
        NSArray *finalAlbums = nil;
       
        if (nil == error) {
            NSMutableArray *albums = [NSMutableArray array];
            
            HPPRGoogleAlbum *allPhotos = [self allPhotosAlbum];
            [albums addObject:allPhotos];
            
            for (NSDictionary *record in self.currentItems) {
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

- (void)getPhotos:(NSString *)startIndex completion:(void (^)(NSError *error))completion
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

- (void) getAlbums:(void (^)(NSError *error))completion
{
    [self parseXMLFileAtURL:@"https://picasaweb.google.com/data/feed/api/user/default?kind=album" completion:completion];
}

- (void)photosForAlbum:(NSString *)albumID withRefresh:(BOOL)refresh andPaging:(NSString *)startIndex andCompletion:(void (^)(NSDictionary *photos, NSError *error))completion
{
    if ([self hasMoreImages]) {
        [self getPhotos:startIndex completion:^(NSError *error) {
            if (completion) {
                completion(nil, error);
            }
        }];
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

- (void)parseXMLFileAtURL:(NSString *)URL completion:(void (^)(NSError *error))completion
{
    self.latestRequest = [URL componentsSeparatedByString:@"?"][0];
    
    self.currentParsingItems = [[NSMutableArray alloc] init];
    self.xmlCompletionBlock = completion;
    
    NSString *agentString = @"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_6; en-us) AppleWebKit/525.27.1 (KHTML, like Gecko) Version/3.2.1 Safari/525.27.1";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:URL]];
    [request setValue:agentString forHTTPHeaderField:@"User-Agent"];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", [GIDSignIn sharedInstance].currentUser.authentication.accessToken] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"3" forHTTPHeaderField:@"GData-Version"];
    
    __weak HPPRGooglePhotoProvider * weakSelf = self;
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable xmlData, NSError * _Nullable error) {
        if (error) {
            if (self.xmlCompletionBlock) {
                self.xmlCompletionBlock(error);
            }
        } else if ([[request.URL.absoluteString componentsSeparatedByString:@"?"][0] isEqualToString:weakSelf.latestRequest]) {
            errorParsing=NO;
            
            rssParser = [[NSXMLParser alloc] initWithData:xmlData];
            [rssParser setDelegate:self];            
            [rssParser setShouldProcessNamespaces:NO];
            [rssParser setShouldReportNamespacePrefixes:NO];
            [rssParser setShouldResolveExternalEntities:NO];
            
            [rssParser parse];
        } else {
            NSLog(@"Ignoring stale request: %@", request.URL.absoluteString);
        }

    }];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    errorParsing=YES;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    currentElement = [elementName copy];
    ElementValue = [[NSMutableString alloc] init];
    if ([elementName isEqualToString:@"entry"]) {
        item = [[NSMutableDictionary alloc] init];
        
    } else if ([elementName isEqualToString:@"media:thumbnail"]) {
        NSMutableArray *thumbnails = [item objectForKey:@"thumbnails"];
        
        if (nil == thumbnails) {
            thumbnails = [[NSMutableArray alloc] init];
        }
        
        [thumbnails addObject:attributeDict];
        [item setObject:thumbnails forKey:@"thumbnails"];
    } else if ([elementName isEqualToString:@"content"]) {
        [item setObject:attributeDict forKey:@"original"];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"entry"]) {
        [item setObject:self.userThumbnail forKey:@"userThumbnail"];
        [item setObject:self.userName forKey:@"userName"];
        [self.currentParsingItems addObject:item];
    } else if ([elementName isEqualToString:@"gphoto:thumbnail"]) {
        self.userThumbnail = ElementValue;
    } else if ([elementName isEqualToString:@"gphoto:nickname"]) {
        self.userName = ElementValue;
    } else {
        [item setObject:ElementValue forKey:elementName];
    }
    
    // For use with querying for "All Photos"
    if ([elementName isEqualToString:@"openSearch:totalResults"] ) {
        self.album.photoCount = [ElementValue integerValue];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    [ElementValue appendString:string];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
    NSError *error = nil;
    if (errorParsing == NO)
    {
        NSLog(@"XML processing done!");
    } else {
        NSLog(@"Error occurred during XML processing");
        error = [NSError errorWithDomain:HP_PHOTO_PROVIDER_DOMAIN code:PARSE_ERROR userInfo:nil];
        self.currentParsingItems = [[NSMutableArray alloc] init];
    }

    self.currentItems = self.currentParsingItems;
    
    if (self.xmlCompletionBlock) {
        self.xmlCompletionBlock(error);
        self.xmlCompletionBlock = nil;
    }
}

@end
