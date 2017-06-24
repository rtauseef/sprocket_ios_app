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

#import "PGPrintProcessingInfo.h"
#import <MPPrintItemFactory.h>

@interface PGPrintProcessingInfo()

@end

@implementation PGPrintProcessingInfo

- (instancetype)initWithImage:(UIImage *)image
                        media:(HPPRMedia *)media
                       origin:(NSString *)origin
                      offramp:(NSString *)offramp
                       copies:(NSInteger)copies
                    connected:(BOOL)connected
              extendedMetrics:(NSDictionary *)metrics
{
    self = [super init];
    if (self) {
        _image = image;
        _media = media;
        _origin = origin;
        _offramp = offramp;
        _copies = copies;
        _connected = connected;
        _extendedMetrics = metrics;
    }
    return self;
}

- (MPPrintItem *)printItem
{
    return [MPPrintItemFactory printItemWithAsset:self.image];
}

@end
