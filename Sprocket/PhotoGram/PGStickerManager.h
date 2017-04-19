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
#import <imglyKit/imglyKit-Swift.h>
#import "PGStickerItem.h"

@interface PGStickerManager : NSObject

+ (PGStickerManager *)sharedInstance;

- (NSArray<IMGLYStickerCategory *> *)IMGLYStickersCategories;
- (NSArray<IMGLYSticker *> *)imglyStickers;

@end
