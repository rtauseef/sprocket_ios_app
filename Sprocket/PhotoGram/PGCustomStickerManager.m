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

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@implementation PGCustomStickerManager

NSString * const kPGCustomStickerManagerDirectory = @"stickers";
NSString * const kCustomStickerManagerThumbnailSuffix = @"_TN";
NSString * const kPGCustomStickerManagerRawSuffix = @"_RAW";
int const kCustomStickerManagerPrefixLength = 8;

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
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    PGCustomStickerViewController *vc = (PGCustomStickerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGCustomStickerViewController"];
    [parentController presentViewController:vc animated:YES completion:nil];
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
    NSInteger next = 0;
    for (NSURL *url in [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[self stickerDirectoryURL] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil]) {
        NSInteger number = [[[url lastPathComponent] substringToIndex:kCustomStickerManagerPrefixLength] integerValue];
        next = fmaxf(number, next);
    }
    return next + 1;
}

- (void)deleteAllStickers:(UIViewController *)viewController
{
    if ([PGCustomStickerManager stickers].count > 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete All Stickers" message:@"Would you like to delete all stickers?" preferredStyle:[self alertStyle]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Delete All" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            for (NSURL *url in [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[self stickerDirectoryURL] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil]) {
                [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kPGImglyManagerStickersChangedNotification object:nil];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [viewController presentViewController:alert animated:YES completion:nil];
    } else {
        // indicate no stickers
    }
}

- (void)deleteSticker:(NSString *)sticker viewController:(UIViewController *)viewController
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Sticker" message:@"Would you like to delete this sticker?" preferredStyle:[self alertStyle]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSURL *stickerUrl = [[self stickerDirectoryURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", sticker]];
        NSURL *thumbUrl = [[self stickerDirectoryURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.png", sticker, kCustomStickerManagerThumbnailSuffix]];
        [[NSFileManager defaultManager] removeItemAtURL:stickerUrl error:nil];
        [[NSFileManager defaultManager] removeItemAtURL:thumbUrl error:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPGImglyManagerStickersChangedNotification object:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [viewController presentViewController:alert animated:YES completion:nil];
}

- (void)saveSticker:(UIImage *)sticker thumbnail:(UIImage *)thumbnail data:(NSData *)rawData
{
    NSInteger number = [self nextStickerNumber];
    NSString *unique = [[[NSProcessInfo processInfo] globallyUniqueString] substringToIndex:4];
    
    NSData *data = UIImagePNGRepresentation(sticker);
    NSURL *url = [[self stickerDirectoryURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%0*ld-%@.png", kCustomStickerManagerPrefixLength, (long)number, unique]];
    [data writeToURL:url atomically:YES];
    
    data = UIImagePNGRepresentation(thumbnail);
    url = [[self stickerDirectoryURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%0*ld-%@%@.png", kCustomStickerManagerPrefixLength, (long)number, unique, kCustomStickerManagerThumbnailSuffix]];
    [data writeToURL:url atomically:YES];
    
    if (rawData) {
        url = [[self stickerDirectoryURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%0*ld-%@%@.png", kCustomStickerManagerPrefixLength, (long)number, unique, kPGCustomStickerManagerRawSuffix]];
        [rawData writeToURL:url atomically:YES];
    }
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

