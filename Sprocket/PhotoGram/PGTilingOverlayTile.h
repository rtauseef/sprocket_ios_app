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

#import <UIKit/UIKit.h>
#import "PGView.h"

@interface PGTilingOverlayTile : PGView

/**
 * Index used to identify this tile in a collection of tiles.
 * This value is usually defined in xib files in the user defined runtime attributes section.
 */
@property (strong, nonatomic) NSNumber *index;
@property (assign, nonatomic, readonly) BOOL isChecked;

@end
