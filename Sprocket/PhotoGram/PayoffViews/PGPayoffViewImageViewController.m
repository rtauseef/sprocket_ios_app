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
#import <MapKit/MapKit.h>
#import "HPPRCameraRollMedia.h"

@interface PGPayoffViewImageViewController () <HPPRSelectPhotoCollectionViewControllerDelegate, PGPayoffFullScreenTmpViewControllerDelegate>

@property (strong, nonatomic) HPPRSelectPhotoCollectionViewController *photoCollectionViewController;
@property (strong, nonatomic) HPPRCameraRollPartialPhotoProvider *provider;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) NSDate* filteringDate;
@property (strong, nonatomic) CLLocation* filteringLocation;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) PGPayoffFullScreenTmpViewController* tmpViewController;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (assign, nonatomic) BOOL scrollViewNeedsUpdate;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *blockImageButton;
@property (strong, nonatomic) PHAsset *localAsset;

- (IBAction)clickImageBlock:(id)sender;

@end

#define kPayoffBottomMargin 20
#define kPayoffViewInset 60
#define kPGLocationDistance 1000 // 1km

@implementation PGPayoffViewImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPR" bundle:nil];
    
    self.scrollViewNeedsUpdate = YES;
    self.photoCollectionViewController = [storyboard instantiateViewControllerWithIdentifier:@"HPPRSelectPhotoCollectionViewController"];
    self.photoCollectionViewController.delegate = self;
    self.provider = [[HPPRCameraRollPartialPhotoProvider alloc] init];
    self.photoCollectionViewController.provider = self.provider;
    [self.photoCollectionViewController setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.mainView addSubview:self.photoCollectionViewController.view];
    self.viewTitle = [NSString string];
    [self.activityIndicator startAnimating];
    self.photoCollectionViewController.view.hidden = YES;
    self.photoCollectionViewController.collectionView.scrollEnabled = NO;
    self.mapView.hidden = YES;
    self.blockImageButton.hidden = YES;
    
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
                         if (_placemark.thoroughfare == nil) {
                             self.viewTitle = [NSString stringWithFormat:@"Photos near %@",name];
                         } else if (_placemark.thoroughfare != nil && [name rangeOfString:_placemark.thoroughfare].location == NSNotFound) {
                             self.viewTitle = [NSString stringWithFormat:@"Photos near %@",name];
                         } else {
                             [self updateViewTitleLocally];
                         }
                     } else {
                         [self updateViewTitleLocally];
                     }
                     
                     [self.parentVc updateCurrentViewLabel:self.viewTitle forView:self];
                 });
             }];
        } else {
            [self updateViewTitleLocally];
        }
    }
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTap:)];
    [recognizer setNumberOfTapsRequired:1];
    self.scrollView.userInteractionEnabled = YES;
    [self.scrollView addGestureRecognizer:recognizer];
}



- (void) updateViewTitleLocally {
    if (self.metadata.location && self.metadata.location.venue.area != nil) {
        self.viewTitle = [NSString stringWithFormat:@"Photos near %@",self.metadata.location.venue.area];
    } else if (self.metadata.location.venue &&
               self.metadata.location.venue.city && self.metadata.location.venue.state) {
        self.viewTitle = [NSString stringWithFormat:@"Photos near %@, %@",self.metadata.location.venue.city, self.metadata.location.venue.state];
    } else {
        self.viewTitle = NSLocalizedString(@"Photos taken near the same location", nil);
    }
}

- (void) providerUpdateDone {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.photoCollectionViewController refresh];
        [self.activityIndicator stopAnimating];
        self.photoCollectionViewController.view.hidden = NO;
        
    
        self.scrollViewNeedsUpdate = YES;
        
        if (self.view.window != nil) {
            [self fixScrollViewSize];
        }
    });
}


- (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size
{
    double newCropWidth, newCropHeight;
    
    newCropWidth = image.size.width;
    newCropHeight = image.size.width/size.width*size.height;
    
    
    double x = image.size.width/2.0 - newCropWidth/2.0;
    double y = image.size.height/2.0 - newCropHeight/2.0;
    
    CGRect cropRect = CGRectMake(x, y, newCropWidth, newCropHeight);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}

- (void) fixScrollViewSize {
    [self.photoCollectionViewController.collectionView reloadData];
    [self.photoCollectionViewController.collectionView layoutIfNeeded];
    CGSize calculatedSize = self.photoCollectionViewController.collectionView.contentSize;
    CGRect frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, calculatedSize.height);
    CGSize totalScrollSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, calculatedSize.height + self.mainView.frame.origin.y + kPayoffBottomMargin);
    
    self.scrollView.contentSize = totalScrollSize;
    self.scrollViewNeedsUpdate = NO;
    [self.photoCollectionViewController.view setFrame:frame];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.scrollViewNeedsUpdate) {
        [self fixScrollViewSize];
    }
    
    if (self.blockImageButton.hidden && self.filteringDate != nil) {
        NSString *localId = self.metadata.source.identifier;
        PHFetchResult * assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:nil];
        
        if ([assets count] > 0) {
            PHAsset *firstAsset = assets[0];
            self.localAsset = firstAsset;
            
            [[PHImageManager defaultManager] requestImageForAsset:firstAsset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                
                [self.blockImageButton setImage:[self imageByCroppingImage:result toSize:self.blockImageButton.frame.size] forState:UIControlStateNormal];
                [self.blockImageButton setHidden:NO];
            }];
        } else {
            //TODO: placeholder image
        }
    } else if (self.blockImageButton.hidden && self.filteringLocation != nil) {
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:self.metadata.location.geo.latitude longitude:self.metadata.location.geo.longitude];
        
        CLLocationCoordinate2D center = self.metadata.location.geo;
        MKCoordinateRegion region = MKCoordinateRegionMake(center, MKCoordinateSpanMake(0.01, 0.01));
        self.mapView.userInteractionEnabled = NO;
        self.mapView.hidden = NO;
    
        [self.mapView setRegion:region animated:YES];
        
        MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
        pin.coordinate = loc.coordinate;
        [self.mapView addAnnotation:pin];
        
    }
    
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

- (IBAction)clickImageBlock:(id)sender {
    if (self.localAsset) {
        HPPRMedia *media = [[HPPRCameraRollMedia alloc] initWithAsset:self.localAsset];
        [[PGPhotoSelection sharedInstance] selectMedia:media];
        self.tmpViewController = [[PGPayoffFullScreenTmpViewController alloc] init];
        self.tmpViewController.view.frame = self.view.bounds;
        [self.mainView addSubview:_tmpViewController.view];
        [PGPreviewViewController presentPreviewPhotoFrom:_tmpViewController andSource:@"1:n" animated:YES];
        self.tmpViewController.delegate = self;
    }
}

-(void)scrollViewTap:(UITapGestureRecognizer *) sender
{
    CGPoint touchLocation = [sender locationOfTouch:0 inView:self.photoCollectionViewController.collectionView];
    NSIndexPath *indexPath = [self.photoCollectionViewController.collectionView indexPathForItemAtPoint:touchLocation];
    
    [self.photoCollectionViewController.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    
    [self.photoCollectionViewController collectionView:self.photoCollectionViewController.collectionView didSelectItemAtIndexPath:indexPath];
}



@end
