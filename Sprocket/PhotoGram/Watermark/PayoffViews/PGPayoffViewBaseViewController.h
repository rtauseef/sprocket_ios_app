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
#import "PGMetarMedia.h"
#import "PGMetarpayoffViewController.h"

@interface PGPayoffViewBaseViewController : UIViewController

@property (strong, nonatomic) NSString *viewTitle;
@property (strong, nonatomic) PGMetarMedia *metadata;
@property (strong, nonatomic) NSString *externalLinkURL;
@property (strong, nonatomic) PGMetarPayoffViewController* parentVc;

@end
