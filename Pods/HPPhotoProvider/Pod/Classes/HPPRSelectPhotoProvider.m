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

#import "HPPRSelectPhotoProvider.h"
#import "HPPR.h"
#import "NSBundle+HPPRLocalizable.h"

@interface HPPRSelectPhotoProvider ()

@property (strong, nonatomic) NSArray *images;

@end

@implementation HPPRSelectPhotoProvider

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidStart) name:PROVIDER_STARTUP_NOTIFICATION object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)localizedName
{
    return self.name;
}

- (void)applicationDidStart
{
    // Default is do nothing
}

#pragma mark - Setter methods

- (void)setAlbum:(HPPRAlbum *)album
{
    _album = album;
    self.images = nil;
}

#pragma mark - Access and connection

- (void)cancelAllOperations
{
    self.imageRequestsCancelled = YES;
}

- (void)resetAccess
{
    [self.loginProvider logoutWithCompletion:nil];
}

- (void)lostAccess
{
    [self resetAccess];
    if ([self.delegate respondsToSelector:@selector(providerLostAccess)]) {
        [self.delegate providerLostAccess];
    }
}

- (void)lostConnection
{
    if ([self.delegate respondsToSelector:@selector(providerLostConnection)]) {
        [self.delegate providerLostConnection];
    }
}

- (void)accessedPrivateAccount
{
    if ([self.delegate respondsToSelector:@selector(providerAccessedPrivateAccount)]) {
        [self.delegate providerAccessedPrivateAccount];
    }
}

- (BOOL)showNetworkWarning
{
    return YES;
}

#pragma mark - User interface

- (void)prepareSegmentView:(HPPRSegmentedControlView *)segmentedControlView
{
    segmentedControlView.hidden = YES;
}

- (NSUInteger)imagesPerScreen
{
    NSUInteger minimum = 0;
    if ([self.delegate respondsToSelector:@selector(imagesPerScreen)]) {
        minimum = [self.delegate imagesPerScreen];
    }
    return minimum;
}

- (NSUInteger)selectedSegmentIndex
{
    NSUInteger index = -1;
    if ([self.delegate respondsToSelector:@selector(selectedSegmentIndex)]) {
        index = [self.delegate selectedSegmentIndex];
    }
    return index;
}

- (UIAlertView *)lostAccessAlertView
{
    return [[UIAlertView alloc ] initWithTitle:[NSString stringWithFormat:HPPRLocalizedString(@"%@ Authorization", @"Title of an alert indicates the specified social network login is not longer valid"), self.name]
                                       message:[NSString stringWithFormat:HPPRLocalizedString(@"Your %@ login is no longer valid. Please sign in again.", @"Message of an alert indicates the specified social network login is not longer valid"), self.name]
                                      delegate:nil
                             cancelButtonTitle:HPPRLocalizedString(@"OK", nil)
                             otherButtonTitles: nil];
}

#pragma mark - Photo list information

- (NSArray *)images
{
    if (!_images) {
        _images = [[NSArray alloc] init];
    }
    return _images;
}

- (NSUInteger)imageCount;
{
    return self.images.count;
}

- (HPPRMedia *)imageAtIndex:(NSInteger)index
{
    // NOTE. If the user pull to refresh, and scrolls really fast the self.images is set with the first bulk of pics, but before we call the collection.reloadData the scroll cause the cellForItemAtIndexPath to be call with an index higher than the number of items in self.images producing a crash ( Terminating app due to uncaught exception 'NSRangeException', reason: '*** -[__NSArrayI objectAtIndex:]: index 150 beyond bounds [0 .. 49]'). If the index is higher than the number of items in the array then we return nil and we handle it correctly
    
    HPPRMedia *media = nil;
    
    if (index < self.images.count) {
        media = self.images[index];
    }
    return media;
}

- (BOOL)hasMoreImages
{
    return NO;
}

#pragma mark - Photo list operations

- (void)clearImagesWithCompletion:(void (^)(void))completion
{
    [self cancelAllOperations];
    self.images = nil;
    
    if (completion) {
        completion();
    }
}

- (void)requestImagesWithCompletion:(void (^)(NSArray *records))completion andReloadAll:(BOOL)reload
{
    if (completion) {
        completion(nil);
    }
}

- (NSUInteger)replaceImagesWithRecords:(NSArray *)records
{
    self.images = records;
    return self.images.count;
}

- (NSUInteger)updateImagesWithRecords:(NSArray *)records
{
    self.images = [self.images arrayByAddingObjectsFromArray:records];
    return self.images.count;
}

#pragma mark - Albums and photos

- (void)landingPagePhotoWithRefresh:(BOOL)refresh andCompletion:(void (^)(UIImage *photo, NSError *error))completion
{
    raise(-1);
}

- (void)retrieveExtraMediaInfo:(HPPRMedia *)media withRefresh:(BOOL)refresh andCompletion:(void (^)(NSError *error))completion
{
    if (completion) {
        completion(nil);
    }
}

- (void)albumsWithRefresh:(BOOL)refresh andCompletion:(void (^)(NSArray *albums, NSError *error))completion
{
    raise(-1);
}

- (void)refreshAlbumWithCompletion:(void (^)(NSError *error))completion
{
    if (completion) {
        completion(nil);
    }
}

- (void)photosForAlbum:(NSString *)albumID withRefresh:(BOOL)refresh andPaging:(NSString *)afterID andCompletion:(void (^)(NSDictionary *photos, NSError *error))completion
{
    raise(-1);
}

- (void)coverPhotoForAlbum:(HPPRAlbum *)album withRefresh:(BOOL)refresh andCompletion:(void (^)(HPPRAlbum *album, UIImage *coverPhoto, NSError *error))completion
{
    raise(-1);
}

@end
