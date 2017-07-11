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

#import "PGMetarPayoffViewController.h"
#import "PGMetarAPI.h"
#import "PGPayoffViewVideoViewController.h"
#import "PGPayoffViewImageViewController.h"
#import "PGPayoffViewErrorViewController.h"
#import "PGPayoffViewWikipediaViewController.h"
#import "PGPayoffViewLivePhotoViewController.h"
#import "PGPayoffViewBaseViewController.h"
#import "HPPR.h"
#import "PGMetarPayoffFeedbackViewController.h"
#import "PGPayoffFeedbackDatabase.h"
#import "PGWikipediaDropdownViewController.h"
#import "PGPayoffViewGoogleStreetViewController.h"

static const NSUInteger kPGReviewViewHeight = 38;

@interface PGMetarPayoffViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *paginationView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) NSMutableArray <UIViewController *> *arrayOfViewControllers;
@property (strong, nonatomic) UIPageViewController *pageViewController;

@property (assign, nonatomic) NSUInteger pendingIndex;
@property (weak, nonatomic) IBOutlet UILabel *currentViewLabel;
@property (weak, nonatomic) IBOutlet UIButton *externalPageButton;

@property (weak, nonatomic) IBOutlet UIButton *thumbsUpButton;
@property (weak, nonatomic) IBOutlet UIButton *thumbsDownButton;
@property (weak, nonatomic) IBOutlet UILabel *reviewLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reviewViewConstraint;
@property (weak, nonatomic) IBOutlet UIView *reviewView;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleArrow;
@property (strong, nonatomic) PGMetarMedia *metarMedia;
@property (weak, nonatomic) IBOutlet UIView *wikipediaTitleView;
@property (strong, nonatomic) PGWikipediaDropdownViewController *dropDownViewController;
@property (assign, nonatomic) BOOL wikipediaDropDownExpanded;
@property (weak, nonatomic) IBOutlet UIButton *wikipediaDropDownArrow;


- (IBAction)openExternalButtonTapped:(id)sender;
- (IBAction)thumbsUpButtonTapped:(id)sender;
- (IBAction)thumbsDownButtonTapped:(id)sender;
- (IBAction)reviewButtonTapped:(id)sender;

@end

@implementation PGMetarPayoffViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.metadata != nil && self.metadata.data != nil && [self.metadata.data objectForKey:kPGPayoffUUIDKey] != nil) {
        // resolve metadata
        [self getMetadataFromMetar];
    }
    

    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];

    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    self.pageControl.hidesForSinglePage = YES;
 
    [self.paginationView addSubview:_pageViewController.view];
    
    self.reviewViewConstraint.constant = 0;
    self.reviewView.hidden = YES;
    self.wikipediaDropDownExpanded = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.reviewViewConstraint.constant = 0;
    self.reviewView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.pageViewController.view.frame = self.paginationView.bounds;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void) updateCurrentViewLabel:(NSString *) name forView:(PGPayoffViewBaseViewController *) view {
    PGPayoffViewBaseViewController *currentVc = (PGPayoffViewBaseViewController *) [self.arrayOfViewControllers objectAtIndex:self.pageControl.currentPage];
    
    if (view == currentVc) {
        if ([view isKindOfClass:[PGPayoffViewWikipediaViewController class]]) {
            self.currentViewLabel.hidden = YES;
            self.wikipediaTitleView.hidden = NO;
        } else {
            self.wikipediaTitleView.hidden = YES;
            self.currentViewLabel.text = name;
            self.currentViewLabel.hidden = NO;
        }
    }
}

- (void) renderPagesWithMetadata: (PGMetarMedia *) metadata {
    self.arrayOfViewControllers = [NSMutableArray array];
    
    if (metadata != nil) {
        
        self.metarMedia = metadata;
        
        if (metadata.mediaType == PGMetarMediaTypeVideo) {
            PGPayoffViewVideoViewController *viewVideoVc = [[PGPayoffViewVideoViewController alloc]
                                                        initWithNibName:@"PGPayoffViewVideoViewController" bundle:nil];
        
            if (metadata.source.social != nil && metadata.source.uri != nil) {
                [viewVideoVc setVideoWithURL:metadata.source.uri];
                [viewVideoVc setMetadata:metadata];
                [viewVideoVc setParentVc:self];
                [self.arrayOfViewControllers addObject:viewVideoVc];
            } else if (metadata.source.from == PGMetarSourceFromLocal) {
                NSString *localId = metadata.source.identifier;
                
                PHFetchResult * assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:nil];
                if( assets.count ) {
                    PHAsset * firstAsset = assets[0];
                    [viewVideoVc setVideoWithAsset:firstAsset];
                    [self.arrayOfViewControllers addObject:viewVideoVc];
                }
            }
        } else if (metadata.mediaType == PGMetarMediaTypeImage && metadata.source.livePhoto && [metadata.source.livePhoto boolValue]) {
            
            NSString *localId = metadata.source.identifier;
            PHFetchResult * assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:nil];
            
            if( assets.count ) {
                PGPayoffViewLivePhotoViewController *livePhotoVc = [[PGPayoffViewLivePhotoViewController alloc]
                                                                initWithNibName:@"PGPayoffViewLivePhotoViewController" bundle:nil];
                
                PHAsset * firstAsset = assets[0];
                [livePhotoVc setLivePhotoAsset:firstAsset];
                [self.arrayOfViewControllers addObject:livePhotoVc];
            }
        }
        
        if (metadata.created) {
            PGPayoffViewImageViewController *viewImageVc = [[PGPayoffViewImageViewController alloc]
                                                            initWithNibName:@"PGPayoffViewImageViewController" bundle:nil];
            
            [viewImageVc setParentVc:self];
            [viewImageVc setMetadata:metadata];
            [viewImageVc showImageSameDayAsDate:metadata.created];
            [self.arrayOfViewControllers addObject:viewImageVc];
        }
        
        if (metadata.location && CLLocationCoordinate2DIsValid(metadata.location.geo)) {
            PGPayoffViewImageViewController *viewImageVc = [[PGPayoffViewImageViewController alloc]
                                                            initWithNibName:@"PGPayoffViewImageViewController" bundle:nil];
            
            CLLocation *loc = [[CLLocation alloc] initWithLatitude:metadata.location.geo.latitude longitude:metadata.location.geo.longitude];
            [viewImageVc setParentVc:self];
            [viewImageVc setMetadata:metadata];
            [viewImageVc showImagesSameLocation:loc];
            [self.arrayOfViewControllers addObject:viewImageVc];
        }
        
        if (metadata.location.content.wikipedia != nil) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PGPayoffView" bundle:nil];
            
            PGPayoffViewWikipediaViewController *viewWikipedia  = [storyboard instantiateViewControllerWithIdentifier:@"wikipediaVc"];
            
            [viewWikipedia setParentVc:self];
            [viewWikipedia setMetadata:metadata];
            
            if ([viewWikipedia metadataValidForCurrentLang]) {
                [self.arrayOfViewControllers addObject:viewWikipedia];
            }
        }
        
        if (metadata.location && CLLocationCoordinate2DIsValid(metadata.location.geo)) {
            
            PGPayoffViewGoogleStreetViewController *googleVc = [[PGPayoffViewGoogleStreetViewController alloc] initWithNibName:@"PGPayoffViewGoogleStreetViewController" bundle:nil];
            [googleVc setParentVc:self];
            [googleVc setMetadata:metadata];
            
            [self.arrayOfViewControllers addObject:googleVc];
        }
    }

    if ([self.arrayOfViewControllers count] == 0) {
        PGPayoffViewErrorViewController *viewErrorVc = [[PGPayoffViewErrorViewController alloc]
                                                        initWithNibName:@"PGPayoffViewErrorViewController" bundle:nil];
        
        viewErrorVc.parentVc = self;
        viewErrorVc.errorCustomMessage = NSLocalizedString(@"Sorry, no information available about the scanned content.", nil);
        viewErrorVc.shouldHideRetry = YES;
        
        [self.arrayOfViewControllers addObject:viewErrorVc];
    }
    
    __weak __typeof__(self) weakSelf = self;
    
    [self.pageViewController setViewControllers:@[[self.arrayOfViewControllers objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        [weakSelf.activityIndicator stopAnimating];
        weakSelf.pageViewController.view.hidden = NO;

        weakSelf.pageControl.numberOfPages = [weakSelf.arrayOfViewControllers count];
        weakSelf.pageControl.currentPage = 0;
        [weakSelf.pageControl setHidden:NO];
        
        PGPayoffViewBaseViewController *currentVc = (PGPayoffViewBaseViewController *) [weakSelf.arrayOfViewControllers objectAtIndex:0];
        
        [weakSelf updateCurrentViewLabel:currentVc.viewTitle forView:currentVc];
        //weakSelf.currentViewLabel.text = currentVc.viewTitle;
        weakSelf.currentViewLabel.alpha = 0;
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ weakSelf.currentViewLabel.alpha = 1;}
                         completion:nil];
    }];
    
    [self fixThumbsUpThumbsDown];
}

- (void) fixThumbsUpThumbsDown {
    PGPayoffFeedbackDatabaseResult result = [[PGPayoffFeedbackDatabase sharedInstance] checkFeedbackForMedia:self.metarMedia andViewKind:[self getCurrentKind]];
    
    if (result == PGPayoffFeedbackDatabaseResultThumbsUp) {
        [self.thumbsUpButton setImage:[UIImage imageNamed:@"thumbsUpBlue"] forState:UIControlStateNormal];
        [self.thumbsDownButton setImage:[UIImage imageNamed:@"thumbsDownWhite"] forState:UIControlStateNormal];
    } else if (result == PGPayoffFeedbackDatabaseResultThumbsDown) {
        [self.thumbsUpButton setImage:[UIImage imageNamed:@"thumbsUpWhite"] forState:UIControlStateNormal];
        [self.thumbsDownButton setImage:[UIImage imageNamed:@"thumbsDownBlue"] forState:UIControlStateNormal];
    } else {
        [self.thumbsUpButton setImage:[UIImage imageNamed:@"thumbsUpWhite"] forState:UIControlStateNormal];
        [self.thumbsDownButton setImage:[UIImage imageNamed:@"thumbsDownWhite"] forState:UIControlStateNormal];
    }
}

- (void) getMetadataFromMetar {
    self.pageViewController.view.hidden = YES;
    self.pageControl.hidden = YES;
    
    [self.activityIndicator startAnimating];
    
    PGMetarAPI * api = [[PGMetarAPI alloc] init];
    
    [api authenticate:^(BOOL success) {
        if (success) {
            [api requestImageMetadataWithUUID:[self.metadata.data objectForKey:kPGPayoffUUIDKey] completion:^(NSError * _Nullable error, PGMetarMedia * _Nullable metarMedia) {
                
                NSLog(@"Got metar media info...");
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self renderPagesWithMetadata:metarMedia];
                });
            }];
        } else {
            NSLog(@"METAR API Auth Error");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self renderPagesWithMetadata:nil];
            });
        }
    }];
}

- (IBAction)closeButtonTapped:(id)sender {
    PGPayoffViewBaseViewController *currentVc = (PGPayoffViewBaseViewController *) [self.arrayOfViewControllers objectAtIndex:self.pageControl.currentPage];
    
    PGPayoffViewBaseViewController *previousVc = (PGPayoffViewBaseViewController *) [self.arrayOfViewControllers objectAtIndex:self.pageControl.currentPage - 1];
    
    __weak __typeof__(self) weakSelf = self;
    
    if ([currentVc isKindOfClass:[PGPayoffViewGoogleStreetViewController class]]) {
        
        
        [self.pageViewController setViewControllers:@[previousVc] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
                [weakSelf.pageControl setCurrentPage:self.pageControl.currentPage - 1];
                [weakSelf updateCurrentViewLabel:currentVc.viewTitle forView:currentVc];
            
        }];
    
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];

    }
}

- (IBAction)openExternalButtonTapped:(id)sender {
    if (self.externalLinkURL) {
        [[UIApplication sharedApplication] openURL:self.externalLinkURL];
    }
}

- (PGPayoffFeedbackDatabaseViewKind) getCurrentKind {
    PGPayoffViewBaseViewController *currentVc = (PGPayoffViewBaseViewController *) [self.arrayOfViewControllers objectAtIndex:self.pageControl.currentPage];
    
    if ([currentVc isKindOfClass:[PGPayoffViewImageViewController class]]) {
        PGPayoffViewImageViewController *vImageVc = (PGPayoffViewImageViewController *) currentVc;
        
        if (vImageVc.filteringDate) {
            return PGPayoffFeedbackDatabaseViewKindImageByDate;
        } else if (vImageVc.filteringLocation) {
            return PGPayoffFeedbackDatabaseViewKindImageByLocation;
        }
    } else if ([currentVc isKindOfClass:[PGPayoffViewWikipediaViewController class]]) {
        return PGPayoffFeedbackDatabaseViewKindWikipedia;
    } else if ([currentVc isKindOfClass:[PGPayoffViewVideoViewController class]]) {
        return PGPayoffFeedbackDatabaseViewKindVideo;
    } else if ([currentVc isKindOfClass:[PGPayoffViewLivePhotoViewController class] ]) {
        return PGPayoffFeedbackDatabaseViewKindLivePhoto;
    }
    
    return PGPayoffFeedbackDatabaseViewKindUnknown;
}

- (IBAction)thumbsUpButtonTapped:(id)sender {
    self.reviewLabel.text = NSLocalizedString(@"Thanks! Tell us what you liked!", nil);
    self.reviewViewConstraint.constant = kPGReviewViewHeight;
    CGRect frame = self.bubbleArrow.frame;
    frame.origin.x = self.thumbsUpButton.frame.origin.x;
    self.bubbleArrow.frame = frame;
    
    [self.thumbsUpButton setImage:[UIImage imageNamed:@"thumbsUpBlue"] forState:UIControlStateNormal];
    [self.thumbsDownButton setImage:[UIImage imageNamed:@"thumbsDownWhite"] forState:UIControlStateNormal];

    self.reviewView.hidden = NO;
    
    [[PGPayoffFeedbackDatabase sharedInstance] saveFeedbackForMedia:self.metarMedia withViewKind:[self getCurrentKind] andFeedback:PGPayoffFeedbackDatabaseResultThumbsUp];
}

- (IBAction)thumbsDownButtonTapped:(id)sender {
    self.reviewLabel.text = NSLocalizedString(@"Thanks! Could you tell us more?", nil);
    self.reviewViewConstraint.constant = kPGReviewViewHeight;
    CGRect frame = self.bubbleArrow.frame;
    frame.origin.x = self.thumbsDownButton.frame.origin.x;
    self.bubbleArrow.frame = frame;

    [self.thumbsUpButton setImage:[UIImage imageNamed:@"thumbsUpWhite"] forState:UIControlStateNormal];
    [self.thumbsDownButton setImage:[UIImage imageNamed:@"thumbsDownBlue"] forState:UIControlStateNormal];
    
    self.reviewView.hidden = NO;
    
    [[PGPayoffFeedbackDatabase sharedInstance] saveFeedbackForMedia:self.metarMedia withViewKind:[self getCurrentKind] andFeedback:PGPayoffFeedbackDatabaseResultThumbsDown];
}

- (IBAction)reviewButtonTapped:(id)sender {
    self.reviewViewConstraint.constant = 0;
    self.reviewView.hidden = YES;
    
    PGMetarPayoffFeedbackViewController *feedback = [[PGMetarPayoffFeedbackViewController alloc] initWithNibName:@"PGMetarPayoffFeedbackViewController" bundle:nil];

    CATransition *transition = [[CATransition alloc] init];
    transition.duration = 0.3;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    [self presentViewController:feedback animated:NO completion:nil];
}

- (void) setExternalLinkURL:(NSURL *)url {
    if (url != nil) {
        _externalLinkURL = url;
        self.externalPageButton.hidden = NO;
    } else {
        _externalLinkURL = nil;
        self.externalPageButton.hidden = YES;
    }
}

- (IBAction)tapDropDownButton:(id)sender {
    if (!self.wikipediaDropDownExpanded) {
        
        if (self.dropDownViewController == nil) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PGPayoffView" bundle:nil];
            self.dropDownViewController = [storyboard instantiateViewControllerWithIdentifier:@"dropdownVc"];
            
            PGPayoffViewBaseViewController *currentVc = (PGPayoffViewBaseViewController *) [self.arrayOfViewControllers objectAtIndex:self.pageControl.currentPage];
            if ([currentVc isKindOfClass:[PGPayoffViewWikipediaViewController class]]) {
                PGPayoffViewWikipediaViewController *vcWiki = (PGPayoffViewWikipediaViewController *) currentVc;
                [self.dropDownViewController setArticles:[vcWiki pageTitlesArray]];
                self.dropDownViewController.delegate = vcWiki;
                self.dropDownViewController.metarVc = self;
            }
        }
        
        CGRect bounds = self.paginationView.bounds;
        CGRect frameUp = CGRectMake(0, 0 - bounds.size.height, bounds.size.width, bounds.size.height);
        CGRect frameDown = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
        
        self.dropDownViewController.view.frame = frameUp;
        
        [self.paginationView addSubview:self.dropDownViewController.view];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.wikipediaDropDownArrow.transform = CGAffineTransformMakeRotation(M_PI);
        }];

        [UIView animateWithDuration:0.5
                              delay:0.0
             usingSpringWithDamping:1.0
              initialSpringVelocity:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.dropDownViewController.view.frame = frameDown;
                         }
                         completion:^(BOOL finished) {
                             self.wikipediaDropDownExpanded = YES;
                         }];
    } else {
        if (self.dropDownViewController) {
            CGRect bounds = self.view.bounds;
            CGRect frame = CGRectMake(0, 0 - bounds.size.height, bounds.size.width, bounds.size.height);
   

            [UIView animateWithDuration:0.5
                                      delay:0.0
                     usingSpringWithDamping:1.0
                      initialSpringVelocity:0.0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     self.dropDownViewController.view.frame = frame;
                                 } completion:^(BOOL finished) {
                                     [self.dropDownViewController.view removeFromSuperview];
                                     self.wikipediaDropDownExpanded = NO;
                                 }];
            
            CGAffineTransform transform = CGAffineTransformIdentity;
            
            if (!CGAffineTransformIsIdentity(self.wikipediaDropDownArrow.transform)) {
                transform = CGAffineTransformMakeRotation(-M_PI * 2);
            }
            
            [UIView animateWithDuration:0.3 animations:^{
                self.wikipediaDropDownArrow.transform = transform;
            } completion:^(BOOL finished) {
                self.wikipediaDropDownArrow.transform = CGAffineTransformIdentity;
            }];
        }
    }
}


#pragma mark UIPageViewController data source

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    for (int i = 0; i < [_arrayOfViewControllers count]; i++) {
        if ([self.arrayOfViewControllers objectAtIndex:i] == viewController) {
            int pos = i-1;
            if (pos>=0 && pos < [_arrayOfViewControllers count]) {
                return [self.arrayOfViewControllers  objectAtIndex:pos];
            }
        }
    }
    return nil;
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    for (int i = 0; i < [_arrayOfViewControllers count]; i++) {
        if ([self.arrayOfViewControllers objectAtIndex:i] == viewController) {
            int pos = i+1;
            if (pos>=0 && pos < [_arrayOfViewControllers count]) {
                return [self.arrayOfViewControllers  objectAtIndex:pos];
            }
        }
    }
    
    return nil;
}

#pragma mark UIPageViewController delegate

- (void)pageViewController:(UIPageViewController *)pageViewController
willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers{
    self.externalPageButton.hidden = YES;
    
    // fade out
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ self.currentViewLabel.alpha = 0;}
                     completion:nil];
    
    self.pendingIndex = [self.arrayOfViewControllers indexOfObject:[pendingViewControllers firstObject]];
    
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
       transitionCompleted:(BOOL)completed {
    if (completed) {
        self.pageControl.currentPage = self.pendingIndex;
        
        PGPayoffViewBaseViewController *currentVc = (PGPayoffViewBaseViewController *) [self.arrayOfViewControllers objectAtIndex:self.pendingIndex];
        
        [self updateCurrentViewLabel:currentVc.viewTitle forView:currentVc];
        //self.currentViewLabel.text = currentVc.viewTitle;
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ self.currentViewLabel.alpha = 1;}
                         completion:nil];
        
        self.reviewViewConstraint.constant = 0;
        self.reviewView.hidden = YES;
        
        [self fixThumbsUpThumbsDown];
    } else {
        PGPayoffViewBaseViewController *currentVc = (PGPayoffViewBaseViewController *) [self.arrayOfViewControllers objectAtIndex:self.pageControl.currentPage];
        
        //self.currentViewLabel.text = currentVc.viewTitle;
        [self updateCurrentViewLabel:currentVc.viewTitle forView:currentVc];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ self.currentViewLabel.alpha = 1;}
                         completion:nil];
    }
}

@end
