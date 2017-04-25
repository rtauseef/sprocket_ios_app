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
#import <HPPRMedia.h>

@interface PGPreviewViewController : UIViewController

@property (strong, nonatomic) UIImage *selectedPhoto;
@property (strong, nonatomic) NSString *source;
@property (strong, nonatomic) IBOutlet UIView *transitionEffectView;

+ (NSString *)cameraSource;
+ (void)presentPreviewPhotoFrom:(UIViewController *)currentViewController andSource:(NSString *)source animated:(BOOL)animated;
+ (void)presentCameraFrom:(UIViewController *)currentViewController animated:(BOOL)animated;

@end
