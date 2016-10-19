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
#import <HPPRCameraRollLoginProvider.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PGSaveToCameraRollActivity ()

@end

@implementation PGSaveToCameraRollActivity

+ (NSString *)activityType
{
    return @"PGSaveToCameraRollActivity";
}

- (NSString *)activityType
{
    return [PGSaveToCameraRollActivity activityType];
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
            if (!self.image) {
                self.image = obj;
            }
            return YES;
        }
    }
    
    return NO;
}

- (void)performActivity
{
    [[HPPRCameraRollLoginProvider sharedInstance] loginWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
        }
        
        [self activityDidFinish:loggedIn];
    }];
}

@end
