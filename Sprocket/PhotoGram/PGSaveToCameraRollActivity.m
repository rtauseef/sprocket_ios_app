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

#import "PGSaveToCameraRollActivity.h"

@interface PGSaveToCameraRollActivity ()

@property (strong, nonatomic) UIImage *image;

@end

@implementation PGSaveToCameraRollActivity

- (NSString *)activityType
{
    return @"PGSaveToCameraRollActivity";
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"Save to Camera Roll", nil);
}

- (UIImage *)_activityImage
{
    return [UIImage imageNamed:@"SaveToCamera"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (id obj in activityItems) {
        if ([obj isKindOfClass:[UIImage class]]) {
            self.image = obj;
            return YES;
        }
    }
    
    return NO;
}

- (void)performActivity
{
    UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
    [self activityDidFinish:YES];
}

@end
