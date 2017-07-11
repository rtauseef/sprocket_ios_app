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


#import "PGPayoffViewGoogleStreetViewController.h"
#import "GoogleMaps/GoogleMaps.h"

@interface PGPayoffViewGoogleStreetViewController ()

@end

@implementation PGPayoffViewGoogleStreetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewTitle = @"Google Street View";

    if (self.metadata &&self.metadata.location && CLLocationCoordinate2DIsValid(self.metadata.location.geo)) {
        GMSPanoramaView *panoView = [[GMSPanoramaView alloc] initWithFrame:CGRectZero];
        self.view = panoView;
        [panoView moveNearCoordinate:CLLocationCoordinate2DMake(self.metadata.location.geo.latitude, self.metadata.location.geo.longitude)];
    }
}

@end
