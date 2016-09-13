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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HPPRMedia.h"
#import "HPPRCachingObject.h"
#import "HPPRAlbum.h"
#import "HPPRLoginProvider.h"

@protocol HPPRSelectPhotoProviderDelegate;

@interface HPPRSelectPhotoProvider : HPPRCachingObject;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *localizedName;
@property (strong, nonatomic) NSString *titleText;
@property (strong, nonatomic) NSString *headerText;
@property (strong, nonatomic) UIImage *headerImage;
@property (assign, nonatomic) BOOL showSearchButton;
@property (readonly, nonatomic) BOOL showNetworkWarning;
@property (weak, nonatomic) id<HPPRSelectPhotoProviderDelegate> delegate;
@property (strong, nonatomic) HPPRAlbum *album;
@property (strong, nonatomic) HPPRLoginProvider * loginProvider;
@property (assign, nonatomic, getter=isImageRequestsCancelled) BOOL imageRequestsCancelled;

- (void)applicationDidStart;

- (NSUInteger)replaceImagesWithRecords:(NSArray *)records;
- (NSUInteger)updateImagesWithRecords:(NSArray *)records;

- (void)resetAccess;
- (void)lostAccess;
- (void)lostConnection;
- (void)accessedPrivateAccount;

- (NSUInteger)imageCount;
- (HPPRMedia *)imageAtIndex:(NSInteger)index;
- (BOOL)hasMoreImages;
- (void)clearImagesWithCompletion:(void (^)(void))completion;
- (void)requestImagesWithCompletion:(void (^)(NSArray *records))completion andReloadAll:(BOOL)reload;
- (void)cancelAllOperations;
- (NSUInteger)imagesPerScreen;
- (UIAlertView *)lostAccessAlertView;

- (void)landingPagePhotoWithRefresh:(BOOL)refresh andCompletion:(void (^)(UIImage *photo, NSError *error))completion;
- (void)retrieveExtraMediaInfo:(HPPRMedia *)media withRefresh:(BOOL)refresh andCompletion:(void (^)(NSError *error))completion;
- (void)albumsWithRefresh:(BOOL)refresh andCompletion:(void (^)(NSArray *albums, NSError *error))completion;
- (void)refreshAlbumWithCompletion:(void (^)(NSError *error))completion;
- (void)photosForAlbum:(NSString *)albumID withRefresh:(BOOL)refresh andPaging:(NSString *)afterID andCompletion:(void (^)(NSDictionary *photos, NSError *error))completion;
- (void)coverPhotoForAlbum:(HPPRAlbum *)album withRefresh:(BOOL)refresh andCompletion:(void (^)(HPPRAlbum *album, UIImage *coverPhoto, NSError *error))completion;

@end

@protocol HPPRSelectPhotoProviderDelegate <NSObject>

- (void)providerLostAccess;
- (void)providerLostConnection;
- (NSUInteger)selectedSegmentIndex;
- (NSUInteger)imagesPerScreen;

@optional

- (void)providerAccessedPrivateAccount;

@end