//
//  PGPayoffViewImageViewController.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/15/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGPayoffViewImageViewController.h"
#import "HPPRSelectPhotoCollectionViewController.h"
#import "HPPRCameraRollPartialPhotoProvider.h"
#import "HPPRMedia.h"
#import "hPPR.h"
#import "PGPhotoSelection.h"
#import "PGPreviewViewController.h"
#import "PGPayoffFullScreenTmpViewController.h"

@interface PGPayoffViewImageViewController () <HPPRSelectPhotoCollectionViewControllerDelegate, PGPayoffFullScreenTmpViewControllerDelegate>

@property (strong, nonatomic) HPPRSelectPhotoCollectionViewController *photoCollectionViewController;
@property (strong, nonatomic) HPPRCameraRollPartialPhotoProvider *provider;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) NSDate* filteringDate;
@property (strong, nonatomic) CLLocation* filteringLocation;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) PGPayoffFullScreenTmpViewController* tmpViewController;
@property (strong, nonatomic) CLGeocoder *geocoder;

@end

#define kPayoffViewInset 60
#define kPGLocationDistance 1000 // 1km

@implementation PGPayoffViewImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPR" bundle:nil];
    
    self.photoCollectionViewController = [storyboard instantiateViewControllerWithIdentifier:@"HPPRSelectPhotoCollectionViewController"];
    self.photoCollectionViewController.delegate = self;
    self.provider = [[HPPRCameraRollPartialPhotoProvider alloc] init];
    self.photoCollectionViewController.provider = self.provider;
    [self.photoCollectionViewController setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.mainView addSubview:self.photoCollectionViewController.view];
    self.viewTitle = [NSString string];
    [self.activityIndicator startAnimating];
    self.photoCollectionViewController.view.hidden = YES;
    
    if (self.filteringDate) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.provider populateImagesForSameDayAsDate:self.filteringDate];
            [self providerUpdateDone];
        });
        
        if (self.metadata && self.metadata.created) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setLocalizedDateFormatFromTemplate:@"MMM d, yyyy"];
            self.viewTitle = [NSString stringWithFormat:@"Photos from %@",[formatter stringFromDate:self.metadata.created]];
        } else {
            self.viewTitle = NSLocalizedString(@"Photos taken on the same day", nil);
        }
    } else if (self.filteringLocation) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.provider populateIMagesForSameLocation:self.filteringLocation andDistance:kPGLocationDistance];
            [self providerUpdateDone];
        });

        if (self.metadata &&self.metadata.location && CLLocationCoordinate2DIsValid(self.metadata.location.geo)) {
            CLLocation *loc = [[CLLocation alloc] initWithLatitude:self.metadata.location.geo.latitude longitude:self.metadata.location.geo.longitude];
            
            if (!self.geocoder)
                self.geocoder = [[CLGeocoder alloc] init];
            
            [self.geocoder reverseGeocodeLocation:loc completionHandler:
             ^(NSArray* placemarks, NSError* error){
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (!error && placemarks && [placemarks count] > 0)
                     {
                         CLPlacemark *_placemark = [placemarks firstObject];
                         NSString *name = _placemark.name;
                         self.viewTitle = [NSString stringWithFormat:@"Photos near %@",name];
                     } else {
                         [self updateViewTitleLocally];
                     }
                     
                     [self.parentVc updateCurrentViewLabel:self.viewTitle];
                 });
             }];
        } else {
            [self updateViewTitleLocally];
        }
    }
}

- (void) updateViewTitleLocally {
    if (self.metadata.location && self.metadata.location.venue.area != nil) {
        self.viewTitle = [NSString stringWithFormat:@"Photos near %@",self.metadata.location.venue.area];
    } else if (self.metadata.location.venue &&
               self.metadata.location.venue.city && self.metadata.location.venue.state) {
        self.viewTitle = [NSString stringWithFormat:@"Photos near %@, %@",self.metadata.location.venue.city, self.metadata.location.venue.state];
    } else {
        self.viewTitle = NSLocalizedString(@"Photos taken nearoi  the same location", nil);
    }
}

- (void) providerUpdateDone {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.photoCollectionViewController refresh];
        
        [self.activityIndicator stopAnimating];
        self.photoCollectionViewController.view.hidden = NO;
        
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    CGRect frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, floorf(self.mainView.bounds.size.height));
    [self.photoCollectionViewController.view setFrame:frame];
    [self.photoCollectionViewController.view setNeedsDisplay];
    
    if (self.tmpViewController) {
        [self.tmpViewController.view removeFromSuperview];
        self.tmpViewController = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)showImagesSameLocation: (CLLocation *) location {
    self.filteringLocation = location;
}

- (void)showImageSameDayAsDate: (NSDate *) date {
    self.filteringDate = date;
}

#pragma mark Collection View Delegate

- (UIEdgeInsets)collectionViewContentInset {
    return UIEdgeInsetsMake(0, 0, kPayoffViewInset, 0);
}

- (void)selectPhotoCollectionViewController:(HPPRSelectPhotoCollectionViewController *)selectPhotoCollectionViewController didSelectImage:(UIImage *)image source:(NSString *)source media:(HPPRMedia *)media {
    [[PGPhotoSelection sharedInstance] selectMedia:media];
    self.tmpViewController = [[PGPayoffFullScreenTmpViewController alloc] init];
    self.tmpViewController.view.frame = self.view.bounds;
    [self.mainView addSubview:_tmpViewController.view];
    [PGPreviewViewController presentPreviewPhotoFrom:_tmpViewController andSource:source animated:YES];
    self.tmpViewController.delegate = self;
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:DISABLE_PAGE_CONTROLLER_FUNCTIONALITY_NOTIFICATION object:nil];
}

#pragma mark Temp View Controller Delegate

//TODO: I don't like this, need to revisit - it's a hack because the preview controller is messing up with the current view controller frame

-(void)tmpViewIsBack {
    [self.tmpViewController.view removeFromSuperview];
    self.tmpViewController = nil;
}

@end
