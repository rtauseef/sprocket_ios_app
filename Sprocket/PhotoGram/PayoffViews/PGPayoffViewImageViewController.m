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
#import "HPPRFacebookFilteredPhotoProvider.h"
#import "UIButton+AFNetworking.h"
#import "HPPRInstagramFilteredPhotoProvider.h"
#import "HPPRFacebookLoginProvider.h"
#import "HPPRInstagramLoginProvider.h"
#import "HPPRGoogleFilteredPhotoProvider.h"
#import "HPPRGoogleLoginProvider.h"
#import "AFImageDownloader.h"

@interface PGPayoffViewImageViewController () <HPPRSelectPhotoCollectionViewControllerDelegate, PGPayoffFullScreenTmpViewControllerDelegate, HPPRFacebookFilteredPhotoProviderDelegate, HPPRInstagramFilteredPhotoProviderDelegate, HPPRGoogleFilteredPhotoProviderDelegate>

@property (strong, nonatomic) HPPRSelectPhotoCollectionViewController *photoCollectionViewController;
@property (strong, nonatomic) HPPRSelectPhotoCollectionViewController *fbPhotoCollectionViewController;
@property (strong, nonatomic) HPPRSelectPhotoCollectionViewController *instagramPhotoCollectionViewController;
@property (strong, nonatomic) HPPRSelectPhotoCollectionViewController *googlePhotoCollectionViewController;

@property (strong, nonatomic) HPPRCameraRollPartialPhotoProvider *cameraRollProvider;
@property (strong, nonatomic) HPPRFacebookFilteredPhotoProvider *facebookProvider;
@property (strong, nonatomic) HPPRInstagramFilteredPhotoProvider *instagramProvider;
@property (strong, nonatomic) HPPRGoogleFilteredPhotoProvider *googleProvider;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) PGPayoffFullScreenTmpViewController* tmpViewController;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *blockImageButton;
@property (strong, nonatomic) PHAsset *localAsset;
@property (assign, nonatomic) BOOL hasLocalContent;
@property (assign, nonatomic) BOOL hasFacebookContent;
@property (assign, nonatomic) BOOL hasInstagramContent;
@property (assign, nonatomic) BOOL hasGoogleContent;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorSocial;

- (IBAction)clickImageBlock:(id)sender;

@end

#define kPayoffBottomMargin 20
#define kPayoffViewInset 60
#define kPGLocationDistance 5000 // 5km
#define kInstagramMaxImagesSearch 300

#define kPayoffFBLabelTag 101
#define kPayoffInstagramLabelTag 102
#define kPayoffGoogleLabelTag 103

@implementation PGPayoffViewImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.hasFacebookContent = NO;
    self.hasInstagramContent = NO;
    self.hasGoogleContent = NO;
    self.hasLocalContent = NO;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPR" bundle:nil];

    self.photoCollectionViewController = [storyboard instantiateViewControllerWithIdentifier:@"HPPRSelectPhotoCollectionViewController"];
    self.photoCollectionViewController.delegate = self;
    self.cameraRollProvider = [[HPPRCameraRollPartialPhotoProvider alloc] init];
    self.photoCollectionViewController.provider = self.cameraRollProvider;
    [self.photoCollectionViewController setEdgesForExtendedLayout:UIRectEdgeNone];
    self.photoCollectionViewController.view.hidden = YES;
    self.photoCollectionViewController.collectionView.scrollEnabled = NO;
    
    self.fbPhotoCollectionViewController = [storyboard instantiateViewControllerWithIdentifier:@"HPPRSelectPhotoCollectionViewController"];
    self.fbPhotoCollectionViewController.delegate = self;
    [self.fbPhotoCollectionViewController setEdgesForExtendedLayout:UIRectEdgeNone];
    self.fbPhotoCollectionViewController.view.hidden = YES;
    self.fbPhotoCollectionViewController.collectionView.scrollEnabled = NO;
    
    self.instagramPhotoCollectionViewController = [storyboard instantiateViewControllerWithIdentifier:@"HPPRSelectPhotoCollectionViewController"];
    self.instagramPhotoCollectionViewController.delegate = self;
    [self.instagramPhotoCollectionViewController setEdgesForExtendedLayout:UIRectEdgeNone];
    self.instagramPhotoCollectionViewController.view.hidden = YES;
    self.instagramPhotoCollectionViewController.collectionView.scrollEnabled = NO;
    
    self.googlePhotoCollectionViewController = [storyboard instantiateViewControllerWithIdentifier:@"HPPRSelectPhotoCollectionViewController"];
    self.googlePhotoCollectionViewController.delegate = self;
    [self.googlePhotoCollectionViewController setEdgesForExtendedLayout:UIRectEdgeNone];
    self.googlePhotoCollectionViewController.view.hidden = YES;
    self.googlePhotoCollectionViewController.collectionView.scrollEnabled = NO;
    
    [self.mainView addSubview:self.photoCollectionViewController.view];
    [self.mainView addSubview:self.fbPhotoCollectionViewController.view];
    [self.mainView addSubview:self.instagramPhotoCollectionViewController.view];
    [self.mainView addSubview:self.googlePhotoCollectionViewController.view];
    
    self.viewTitle = [NSString string];
    [self.activityIndicator startAnimating];
    
    self.mapView.hidden = YES;
    self.blockImageButton.hidden = YES;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTap:)];
    [recognizer setNumberOfTapsRequired:1];
    self.scrollView.userInteractionEnabled = YES;
    [self.scrollView addGestureRecognizer:recognizer];
    
    self.activityIndicatorSocial = [[UIActivityIndicatorView alloc] init];
    [self.activityIndicatorSocial setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self.activityIndicatorSocial setHidden:YES];
    [self.mainView addSubview:self.activityIndicatorSocial];
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

- (void) facebookUpdateDone: (int) count {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"Payoff -- facebook: %d",count);
        self.hasFacebookContent = YES;
        
        [self fixScrollViewSize];
    });
}

- (void) instagramUpdateDone: (int) count {
    dispatch_async(dispatch_get_main_queue(), ^{

        NSLog(@"Payoff -- instagram: %d",count);
        self.hasInstagramContent = YES;
        
        [self fixScrollViewSize];
    });
}

- (void) googleUpdateDone: (int) count {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"Payoff -- google: %d",count);
        self.hasGoogleContent = YES;
        
        [self fixScrollViewSize];
    });
}

- (void) cameraRollProviderUpdateDone {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.photoCollectionViewController refresh];
        [self.activityIndicator stopAnimating];
        
        self.hasLocalContent = YES;
        
        if (self.view.window != nil) {
            [self fixScrollViewSize];
        }
    });
}


- (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size
{
    double newCropWidth, newCropHeight;
    
    float imageWidth = image.size.width * image.scale;
    float imageHeight = image.size.height * image.scale;
    
    newCropWidth = imageWidth;
    newCropHeight = imageWidth/size.width*size.height;
    
    double x = imageWidth/2.0 - newCropWidth/2.0;
    double y = imageHeight/2.0 - newCropHeight/2.0;
    
    CGRect cropRect = CGRectMake(x, y, newCropWidth, newCropHeight);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    
    if (cropped.size.width < size.width || cropped.size.height < size.height) {
         UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        [cropped drawInRect:CGRectMake(0, 0, size.width, size.height)];
        cropped = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    CGImageRelease(imageRef);
    
    return cropped;
}

- (void) fixScrollViewSize {
    // force content size calculation
    
    if (self.photoCollectionViewController.view.hidden) {
        [self.photoCollectionViewController.collectionView reloadData];
        [self.photoCollectionViewController.collectionView layoutIfNeeded];
    }
    
    if (self.fbPhotoCollectionViewController.view.hidden) {
        [self.fbPhotoCollectionViewController.collectionView reloadData];
        [self.fbPhotoCollectionViewController.collectionView layoutIfNeeded];
    }
    
    if (self.instagramPhotoCollectionViewController.view.hidden) {
        [self.instagramPhotoCollectionViewController.collectionView reloadData];
        [self.instagramPhotoCollectionViewController.collectionView layoutIfNeeded];
    }
    
    if (self.googlePhotoCollectionViewController.view.hidden) {
        [self.googlePhotoCollectionViewController.collectionView reloadData];
        [self.googlePhotoCollectionViewController.collectionView layoutIfNeeded];
    }
    
    CGSize instagramSize = self.instagramPhotoCollectionViewController.collectionView.contentSize;
    CGSize fbSize = self.fbPhotoCollectionViewController.collectionView.contentSize;
    CGSize photosSize = self.photoCollectionViewController.collectionView.contentSize;
    CGSize googleSize = self.googlePhotoCollectionViewController.collectionView.contentSize;
 
    CGSize calculatedSize = CGSizeMake(photosSize.width, 0);
    
    if (photosSize.height > 0) {
        CGRect frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, photosSize.height);
        [self.photoCollectionViewController.view setFrame:frame];
        calculatedSize.height += photosSize.height;
        calculatedSize.height += kPayoffBottomMargin;
        
        self.photoCollectionViewController.view.hidden = NO;
    }
    
    
    if ((!_hasFacebookContent || !_hasInstagramContent || !_hasGoogleContent) && _hasLocalContent) {
        // add spinner
        CGRect frame =  CGRectMake(8, calculatedSize.height, [[UIScreen mainScreen] bounds].size.width - 8, 20);
        [self.activityIndicatorSocial setFrame:frame];
        [self.activityIndicatorSocial startAnimating];
        
        calculatedSize.height += frame.size.height;
        calculatedSize.height += kPayoffBottomMargin;
        
        self.activityIndicatorSocial.hidden = NO;
    } else {
        [self.activityIndicatorSocial stopAnimating];
        self.activityIndicatorSocial.hidden = YES;
    
    
        if (fbSize.height > 0 && self.hasFacebookContent) {
            CGRect fbLabelFrame = CGRectMake(8, calculatedSize.height, [[UIScreen mainScreen] bounds].size.width - 8, 21);
            UILabel *facebookLabel = [[UILabel alloc] initWithFrame:fbLabelFrame];
            [facebookLabel setTag:kPayoffFBLabelTag];
            
            [facebookLabel setText:@"Facebook Photos"];
            [facebookLabel setTextColor:[UIColor whiteColor]];
            
            if (![self.mainView viewWithTag:kPayoffFBLabelTag]) {
                [self.mainView addSubview:facebookLabel];
            } else {
                UILabel *label = [self.mainView viewWithTag:kPayoffFBLabelTag];
                label.frame = CGRectMake(8, calculatedSize.height, [[UIScreen mainScreen] bounds].size.width - 8, 21);
            }
            
            calculatedSize.height += fbLabelFrame.size.height;
            
            CGRect fbFrame = CGRectMake(0, calculatedSize.height, [[UIScreen mainScreen] bounds].size.width, fbSize.height);
            [self.fbPhotoCollectionViewController.view setFrame:fbFrame];
            calculatedSize.height += fbSize.height;
            calculatedSize.height += kPayoffBottomMargin;
            
            self.fbPhotoCollectionViewController.view.hidden = NO;
        }
        
        if (instagramSize.height > 0 && self.hasInstagramContent) {
            CGRect instLabelFrame = CGRectMake(8, calculatedSize.height, [[UIScreen mainScreen] bounds].size.width - 8, 21);
            UILabel *instLabel = [[UILabel alloc] initWithFrame:instLabelFrame];
            [instLabel setTag:kPayoffInstagramLabelTag];
            
            [instLabel setText:@"Instagram Photos"];
            [instLabel setTextColor:[UIColor whiteColor]];
            
            if (![self.mainView viewWithTag:kPayoffInstagramLabelTag]) {
                [self.mainView addSubview:instLabel];
            } else {
                UILabel *label = [self.mainView viewWithTag:kPayoffInstagramLabelTag];
                label.frame = CGRectMake(8, calculatedSize.height, [[UIScreen mainScreen] bounds].size.width - 8, 21);
            }
            
            calculatedSize.height += instLabelFrame.size.height;
            
            CGRect instFrame = CGRectMake(0, calculatedSize.height, [[UIScreen mainScreen] bounds].size.width, instagramSize.height);
            [self.instagramPhotoCollectionViewController.view setFrame:instFrame];
            calculatedSize.height += instagramSize.height;
            calculatedSize.height += kPayoffBottomMargin;
            
            self.instagramPhotoCollectionViewController.view.hidden = NO;
        }
        
        if (googleSize.height > 0 && self.hasGoogleContent) {
            CGRect googleLabelFrame = CGRectMake(8, calculatedSize.height, [[UIScreen mainScreen] bounds].size.width - 8, 21);
            UILabel *googleLabel = [[UILabel alloc] initWithFrame:googleLabelFrame];
            [googleLabel setTag:kPayoffGoogleLabelTag];
            
            [googleLabel setText:@"Google Photos"];
            [googleLabel setTextColor:[UIColor whiteColor]];
            
            if (![self.mainView viewWithTag:kPayoffGoogleLabelTag]) {
                [self.mainView addSubview:googleLabel];
            } else {
                UILabel *label = [self.mainView viewWithTag:kPayoffGoogleLabelTag];
                label.frame = CGRectMake(8, calculatedSize.height, [[UIScreen mainScreen] bounds].size.width - 8, 21);
            }
            
            calculatedSize.height += googleLabelFrame.size.height;
            
            CGRect googleFrame = CGRectMake(0, calculatedSize.height, [[UIScreen mainScreen] bounds].size.width, googleSize.height);
            [self.googlePhotoCollectionViewController.view setFrame:googleFrame];
            calculatedSize.height += googleSize.height;
            calculatedSize.height += kPayoffBottomMargin;
            
            self.googlePhotoCollectionViewController.view.hidden = NO;
        }
    }
    
    CGSize totalScrollSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, self.mainView.frame.origin.y + calculatedSize.height);
    self.scrollView.contentSize = totalScrollSize;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self fixScrollViewSize];
    
    if (self.metadata.source.from == PGMetarSourceFromSocial && self.metadata.source.uri) {
        [self.parentVc setExternalLinkURL:[NSURL URLWithString:self.metadata.source.uri]];
    }
    
    if (self.blockImageButton.hidden && self.filteringDate != nil) {
        
        NSString *localId = self.metadata.source.identifier;
        
        if (self.metadata.source.from == PGMetarSourceFromLocal && localId) {
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
                [self.blockImageButton setHidden:NO];
            }
        } else if (self.metadata.source.from == PGMetarSourceFromSocial) {
            if (self.metadata.source.uri) {
                AFImageDownloader *downloader = [[AFImageDownloader alloc] init];
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.metadata.source.uri]];
                [downloader downloadImageForURLRequest:request success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull responseObject) {
                    UIImage *renderImage = [self imageByCroppingImage:responseObject toSize:self.blockImageButton.frame.size];
                    [self.blockImageButton setImage:renderImage forState:UIControlStateNormal];
                } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                    // TODO: placeholder image
                }];
            }

            [self.blockImageButton setHidden:NO];
        }
    } else if (self.blockImageButton.hidden && self.filteringLocation != nil && self.mapView.hidden) {
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
    
    if (self.facebookProvider || self.instagramProvider) {
        return;
    }

    [[HPPRFacebookLoginProvider sharedInstance] checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            if (self.filteringDate) {
                self.facebookProvider = [[HPPRFacebookFilteredPhotoProvider alloc] initWithMode:HPPRFacebookFilteredPhotoProviderModeDate];
                self.facebookProvider.fbDelegate = self;
                self.fbPhotoCollectionViewController.provider = self.facebookProvider;
                [self.fbPhotoCollectionViewController refresh];
            } else if (self.filteringLocation) {
                self.facebookProvider = [[HPPRFacebookFilteredPhotoProvider alloc] initWithMode:HPPRFacebookFilteredPhotoProviderModeLocation];
                self.facebookProvider.fbDelegate = self;
                self.fbPhotoCollectionViewController.provider = self.facebookProvider;
                [self.fbPhotoCollectionViewController refresh];
            }
        } else {
            self.hasFacebookContent = YES;
            [self fixScrollViewSize];
        }
    }];
    
    [[HPPRInstagramLoginProvider sharedInstance] checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            if (self.filteringDate) {
                self.instagramProvider = [[HPPRInstagramFilteredPhotoProvider alloc] initWithMode:HPPRInstagramFilteredPhotoProviderModeDate];
                self.instagramProvider.instagramDelegate = self;
                self.instagramPhotoCollectionViewController.provider = self.instagramProvider;
                [self.instagramPhotoCollectionViewController refresh];
            } else if (self.filteringLocation) {
                self.instagramProvider = [[HPPRInstagramFilteredPhotoProvider alloc] initWithMode:HPPRInstagramFilteredPhotoProviderModeLocation];
                self.instagramProvider.instagramDelegate = self;
                self.instagramPhotoCollectionViewController.provider = self.instagramProvider;
                [self.instagramPhotoCollectionViewController refresh];
            }
        } else {
            self.hasInstagramContent = YES;
            [self fixScrollViewSize];
        }
    }];
    
    [[HPPRGoogleLoginProvider sharedInstance] checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            if (self.filteringDate) {
                self.googleProvider = [[HPPRGoogleFilteredPhotoProvider alloc] initWithMode:HPPRGoogleFilteredPhotoProviderModeDate];
                self.googleProvider.googleDelegate = self;
                self.googlePhotoCollectionViewController.provider = self.googleProvider;
                [self.googlePhotoCollectionViewController refresh];
            } else if (self.filteringLocation) {
                self.googleProvider = [[HPPRGoogleFilteredPhotoProvider alloc] initWithMode:HPPRGoogleFilteredPhotoProviderModeLocation];
                self.googleProvider.googleDelegate = self;
                self.googlePhotoCollectionViewController.provider = self.googleProvider;
                [self.googlePhotoCollectionViewController refresh];
            }
        } else {
            self.hasGoogleContent = YES;
            [self fixScrollViewSize];
        }
    }];
    
    if (self.filteringDate) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.cameraRollProvider populateImagesForSameDayAsDate:self.filteringDate];
            [self cameraRollProviderUpdateDone];
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
            [self.cameraRollProvider populateIMagesForSameLocation:self.filteringLocation andDistance:kPGLocationDistance];
            [self cameraRollProviderUpdateDone];
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
    [self.tmpViewController dismissViewControllerAnimated:NO completion:^{
        self.tmpViewController = nil;
    }];
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
    
    if (indexPath != nil) {
        [self.photoCollectionViewController.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    
        [self.photoCollectionViewController collectionView:self.photoCollectionViewController.collectionView didSelectItemAtIndexPath:indexPath];
    } else {
        
        touchLocation = [sender locationOfTouch:0 inView:self.fbPhotoCollectionViewController.collectionView];
        indexPath = [self.fbPhotoCollectionViewController.collectionView indexPathForItemAtPoint:touchLocation];
    
        if (indexPath != nil) {
            [self.fbPhotoCollectionViewController.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            
            [self.fbPhotoCollectionViewController collectionView:self.fbPhotoCollectionViewController.collectionView didSelectItemAtIndexPath:indexPath];
        } else {
            
            touchLocation = [sender locationOfTouch:0 inView:self.instagramPhotoCollectionViewController.collectionView];
            indexPath = [self.instagramPhotoCollectionViewController.collectionView indexPathForItemAtPoint:touchLocation];
            
            if (indexPath != nil) {
                [self.instagramPhotoCollectionViewController.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                [self.instagramPhotoCollectionViewController collectionView:self.instagramPhotoCollectionViewController.collectionView didSelectItemAtIndexPath:indexPath];
            }
        }
    }
}

#pragma mark Facebook provider delegate

- (NSDate *) fbFilterContentByDate {
    return self.filteringDate;
}

- (void) fbRequestPhotoComplete:(int) count {
    [self facebookUpdateDone:count];
}

- (CLLocation *)fbFilterContentByLocation {
    return self.filteringLocation;
}

- (int)fbDistanceForLocationFilter {
    return kPGLocationDistance;
}

#pragma mark Instagram provider delegate

- (NSDate *) instagramFilterContentByDate {
    return self.filteringDate;
}

- (void) instagramRequestPhotoComplete:(int) count {
    [self instagramUpdateDone:count];
}

- (int)instagramMaxSearchDepth {
    return kInstagramMaxImagesSearch;
}

- (CLLocation *)instagramFilterContentByLocation {
    return self.filteringLocation;
}

- (int)instagramDistanceForLocationFilter {
    return kPGLocationDistance;
}

#pragma mark Google provider delegate

- (NSDate *) googleFilterContentByDate {
    return self.filteringDate;
}

- (void) googleRequestPhotoComplete:(int) count {
    [self googleUpdateDone:count];
}

- (int)googleMaxSearchDepth {
    return kInstagramMaxImagesSearch;
}

- (CLLocation *)googleFilterContentByLocation {
    return self.filteringLocation;
}

- (int)googleDistanceForLocationFilter {
    return kPGLocationDistance;
}

@end
