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

#import "PGGesturesView.h"

#import <MPPrintItem.h>
#import <HPPRMedia.h>

@interface PGPrintProcessingInfo : NSObject

@property (strong, nonatomic) UIImage *image;

@property (nonatomic, readonly) MPPrintItem *printItem;
@property (nonatomic, readonly) HPPRMedia *media;
@property (nonatomic, readonly) NSString *origin;
@property (nonatomic, readonly) NSString *offramp;
@property (nonatomic, readonly) NSDictionary *extendedMetrics;
@property (nonatomic, readonly) BOOL connected;
@property (nonatomic, readonly) NSInteger copies;

- (instancetype)initWithImage:(UIImage *)image
                        media:(HPPRMedia *)media
                       origin:(NSString *)origin
                      offramp:(NSString *)offramp
                       copies:(NSInteger)copies
                    connected:(BOOL)connected
              extendedMetrics:(NSDictionary *)metrics;

@end
