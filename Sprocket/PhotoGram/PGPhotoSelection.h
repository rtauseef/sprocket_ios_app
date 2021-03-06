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

#import <Foundation/Foundation.h>
#import <HPPRMedia.h>
#import "PGGesturesView.h"

@interface PGPhotoSelection : NSObject

+ (instancetype)sharedInstance;

- (void)beginSelectionMode;
- (void)clearSelection;
- (void)endSelectionMode;
- (BOOL)isInSelectionMode;
- (BOOL)isMaxedOut;
- (BOOL)hasMultiplePhotos;

- (void)selectMedia:(HPPRMedia *)media;
- (void)deselectMedia:(HPPRMedia *)media;
- (NSArray<HPPRMedia *> *)selectedMedia;
- (BOOL)isSelected:(HPPRMedia *)media;

@end
