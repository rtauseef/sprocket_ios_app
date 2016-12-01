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

#import "HPPRQzonePhotoProvider.h"
#import "HPPRQzoneLoginProvider.h"
#import "HPPRQzoneAlbum.h"
#import "HPPRQzoneMedia.h"
#import "NSBundle+HPPRLocalizable.h"

@interface HPPRQzonePhotoProvider()

@end

@implementation HPPRQzonePhotoProvider

#pragma mark - Initialization

+ (HPPRQzonePhotoProvider *)sharedInstance
{
    static dispatch_once_t once;
    static HPPRQzonePhotoProvider *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[HPPRQzonePhotoProvider alloc] init];
        sharedInstance.loginProvider = [HPPRQzoneLoginProvider sharedInstance];
        sharedInstance.loginProvider.delegate = sharedInstance;
    });
    return sharedInstance;
}


#pragma mark - User Interface

- (NSString *)name
{
    return @"Qzone";
}

- (NSString *)localizedName
{
    return HPPRLocalizedString(@"Qzone", nil);
}

- (BOOL)showSearchButton
{
    return NO;
}

- (NSString *)titleText
{
    return [NSString stringWithFormat:HPPRLocalizedString(@"%@ Photos", @"Photos of the specified social network"), self.localizedName];
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

#pragma mark - Albums and Photos requests

- (void)albumsWithRefresh:(BOOL)refresh andCompletion:(void (^)(NSArray *albums, NSError *error))completion
{
    [[HPPRQzoneLoginProvider sharedInstance] listAlbums:^(NSDictionary *albums, NSError *error) {
        if (error) {
            NSLog(@"QZONE ALBUMS ERROR\n%@", error);
            if (completion) {
                completion(nil, error);
            }
        } else {
            NSMutableArray *allAlbums = [NSMutableArray array];
            
            for (NSDictionary *album in albums) {
                [allAlbums addObject:[[HPPRQzoneAlbum alloc] initWithAttributes:album]];
            }
            
            if (completion) {
                completion(allAlbums, nil);
            }
        }
    }];
}

- (void)requestImagesWithCompletion:(void (^)(NSArray *records))completion andReloadAll:(BOOL)reload
{
    [[HPPRQzoneLoginProvider sharedInstance] listPhotosForAlbum:self.album.objectID completion:^(NSDictionary *photos, NSError *error) {
        NSMutableArray *allPhotos = [NSMutableArray array];
        
        for (NSDictionary *photo in photos) {
            [allPhotos addObject:[[HPPRQzoneMedia alloc] initWithAttributes:photo]];
        }
        
        if (reload) {
            [self replaceImagesWithRecords:allPhotos];
        } else {
            [self updateImagesWithRecords:allPhotos];
        }
        
        if (completion) {
            completion(allPhotos);
        }
    }];
}

@end
