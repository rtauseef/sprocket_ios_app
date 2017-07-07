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
#import "PGPayoffMetadata.h"
#import "PGMetarMedia.h"

@interface PGMetarPayoffViewController : UIViewController

@property (strong, nonatomic) PGPayoffMetadata *metadata;
@property (strong, nonatomic) NSURL *externalLinkURL;
@property (strong, nonatomic) PGMetarMedia *metarMedia;

- (IBAction)closeButtonTapped:(id)sender;
- (void) getMetadataFromMetar;
- (void) updateCurrentViewLabel: (NSString *) name forView: (UIViewController *) view;
- (IBAction)tapDropDownButton:(id)sender;

@end
