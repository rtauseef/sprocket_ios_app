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

#import "PGCustomStickerManager.h"
#import "PGCustomStickerViewController.h"
#import "UIImage+Fixup.h"
#import "PGStickerItem.h"
#import "PGImglyManager.h"
#import "PGCameraManager.h"

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@implementation PGCustomStickerManager

static NSString * const kPGCustomStickerManagerLastStickerNumberKey = @"com.hp.sprocket.imgly.last-sticker";
static NSString * const kPGCustomStickerManagerDirectory = @"stickers";
static NSString * const kCustomStickerManagerThumbnailSuffix = @"_TN";
static NSString * const kPGCustomStickerManagerRawSuffix = @"_RAW";
static int const kCustomStickerManagerPrefixLength = 8;

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static PGCustomStickerManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[PGCustomStickerManager alloc] init];
    });
    return sharedInstance;
}


- (void)presentCameraFromViewController:(UIViewController *)parentController
{
    [[PGCameraManager sharedInstance] checkCameraPermission:^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
        PGCustomStickerViewController *vc = (PGCustomStickerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGCustomStickerViewController"];
        [parentController presentViewController:vc animated:YES completion:nil];
    } andFailure:^{
        [[PGCameraManager sharedInstance] showCameraPermissionFailedAlert];
    }];
}

- (NSURL *)stickerDirectoryURL
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *stickerDirectory = [documentsDirectory URLByAppendingPathComponent:kPGCustomStickerManagerDirectory];
    [manager createDirectoryAtURL:stickerDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    return stickerDirectory;
}

- (NSInteger)stickerCount
{
    NSFileManager *manager = [NSFileManager defaultManager];
    return [[manager contentsOfDirectoryAtURL:[self stickerDirectoryURL] includingPropertiesForKeys:@[] options:0 error:nil] count];
}

- (NSInteger)nextStickerNumber
{
    NSInteger lastStickerNumber = [[NSUserDefaults standardUserDefaults] integerForKey:kPGCustomStickerManagerLastStickerNumberKey];

    return lastStickerNumber + 1;
}

- (void)deleteAllStickers:(UIViewController *)viewController
{
    if ([PGCustomStickerManager stickers].count > 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete All Stickers", nil)
                                                                       message:NSLocalizedString(@"Are you sure you want to delete all stickers?", nil)
                                                                preferredStyle:[self alertStyle]];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete All", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            for (NSURL *url in [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[self stickerDirectoryURL] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil]) {
                [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kPGImglyManagerStickersChangedNotification object:nil];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
        [viewController presentViewController:alert animated:YES completion:nil];
    } else {
        // indicate no stickers
    }
}

- (void)deleteSticker:(NSString *)sticker viewController:(UIViewController *)viewController
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete Sticker", nil)
                                                                   message:NSLocalizedString(@"Are you sure you want to delete this sticker?", nil)
                                                            preferredStyle:[self alertStyle]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSURL *stickerUrl = [[self stickerDirectoryURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", sticker]];
        NSURL *thumbUrl = [[self stickerDirectoryURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.png", sticker, kCustomStickerManagerThumbnailSuffix]];
        [[NSFileManager defaultManager] removeItemAtURL:stickerUrl error:nil];
        [[NSFileManager defaultManager] removeItemAtURL:thumbUrl error:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPGImglyManagerStickersChangedNotification object:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [viewController presentViewController:alert animated:YES completion:nil];
}

- (void)saveSticker:(UIImage *)sticker thumbnail:(UIImage *)thumbnail
{
    NSInteger number = [self nextStickerNumber];
    // Appending a random suffix to prevent caching by imgly
    NSString *unique = [[[NSProcessInfo processInfo] globallyUniqueString] substringToIndex:4];
    
    NSData *data = UIImagePNGRepresentation(sticker);
    NSURL *url = [[self stickerDirectoryURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%0*ld-%@.png", kCustomStickerManagerPrefixLength, (long)number, unique]];
    [data writeToURL:url atomically:YES];
    
    data = UIImagePNGRepresentation(thumbnail);
    url = [[self stickerDirectoryURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%0*ld-%@%@.png", kCustomStickerManagerPrefixLength, (long)number, unique, kCustomStickerManagerThumbnailSuffix]];
    [data writeToURL:url atomically:YES];

    [[NSUserDefaults standardUserDefaults] setInteger:number forKey:kPGCustomStickerManagerLastStickerNumberKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

+ (NSArray<IMGLYSticker *> *)stickers
{
    NSMutableArray *stickers = [NSMutableArray array];

    for (NSURL *url in [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[[PGCustomStickerManager sharedInstance] stickerDirectoryURL] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil]) {
        NSString *base = [[url lastPathComponent] stringByReplacingOccurrencesOfString:@".png" withString:@""];
        if (![base containsString:kCustomStickerManagerThumbnailSuffix]) {
            NSURL *thumb = [[[PGCustomStickerManager sharedInstance] stickerDirectoryURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.png", base, kCustomStickerManagerThumbnailSuffix]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:[thumb path]]) {
                IMGLYSticker *sticker = [[IMGLYSticker alloc] initWithImageURL:url thumbnailURL:thumb tintMode:IMGLYStickerTintModeSolid]; // IMGLYStickerTintModeNone
                sticker.accessibilityLabel = [NSString stringWithFormat:@"Custom Sticker %@", base];
                [stickers addObject:sticker];
            }
        }
    }
    
    return [[stickers reverseObjectEnumerator] allObjects];
}

- (UIAlertControllerStyle)alertStyle
{
    if (UIUserInterfaceIdiomPad == [[UIDevice currentDevice] userInterfaceIdiom]) {
        return UIAlertControllerStyleAlert;
    } else {
        return UIAlertControllerStyleActionSheet;
    }
}

@end

