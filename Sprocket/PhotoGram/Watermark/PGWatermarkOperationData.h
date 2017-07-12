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
#import "PGMetarMedia.h"

/**
 The data used to execute a 'PGWatermarkOperation' operation.
 */

@interface PGWatermarkOperationData : NSObject

@property (nonatomic, nonnull) UIImage *originalImage;
// The identifier of the device to which the watermark data will be associated to
@property (nonatomic, nonnull) NSString *localOperationIdentifier;
@property (nonatomic, nonnull) NSString *printerIdentifier;
// The URL that will be shown when the image is scanned
@property (nonatomic, nonnull) NSURL *payoffURL;
@property (strong, nonatomic) PGMetarMedia * _Nullable metadata;

@end

