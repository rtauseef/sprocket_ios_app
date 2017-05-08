//
//  PGWatermarkOperationData.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/3/17.
//  Copyright © 2017 HP. All rights reserved.
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

