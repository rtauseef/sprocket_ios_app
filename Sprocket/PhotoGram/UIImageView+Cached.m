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

#import "UIImageView+Cached.h"
#import "PGImageCache.h"

@implementation UIImageView (Cached)

- (void)imageWithUrl:(NSString *)url completion:(void (^)(UIImage * _Nullable))completion
{
    UIImage *image = [[PGImageCache sharedInstance] imageForKey:url];

    if (image) {
        completion(image);

    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
            if (data) {
                UIImage *image = [UIImage imageWithData:data];

                if (image) {
                    [[PGImageCache sharedInstance] setImage:image ForKey:url];
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(image);
                });
            }
        });
    }
}

@end
