//
//  PGMetarPayoffViewController.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/15/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarPayoffViewController.h"
#import "PGMetarAPI.h"
#import "PGPayoffViewVideoViewController.h"
#import "PGPayoffViewImageViewController.h"
#import "PGPayoffViewErrorViewController.h"
#import "PGPageControl.h"

@interface PGMetarPayoffViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *paginationView;
@property (weak, nonatomic) IBOutlet PGPageControl *pageControl;

@property (strong, nonatomic) NSMutableArray <UIViewController *> *arrayOfViewControllers;
@property (strong, nonatomic) UIPageViewController *pageViewController;

@property (assign, nonatomic) NSUInteger pendingIndex;

@end

@implementation PGMetarPayoffViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.metadata != nil && self.metadata.data != nil && [self.metadata.data objectForKey:kPGPayoffUUIDKey] != nil) {
        // resolve metadata
        [self getMetadataFromMetar];
    }
    

    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];

    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    self.pageControl.hidesForSinglePage = YES;
 
    [self.paginationView addSubview:_pageViewController.view];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_pageViewController.view setFrame:self.paginationView.bounds];
}

- (void) renderPagesWithMetadata: (PGMetarMedia *) metadata {
    self.arrayOfViewControllers = [NSMutableArray array];
    
    if (metadata != nil) {
        
        if (metadata.mediaType == PGMetarMediaTypeVideo) {
            PGPayoffViewVideoViewController *viewVideoVc = [[PGPayoffViewVideoViewController alloc]
                                                        initWithNibName:@"PGPayoffViewVideoViewController" bundle:nil];
        
            if (metadata.source.social != nil && metadata.source.uri != nil) {
                [viewVideoVc setVideoWithURL:metadata.source.uri];
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
        }
        
        if (metadata.created) {
            PGPayoffViewImageViewController *viewImageVc = [[PGPayoffViewImageViewController alloc]
                                                            initWithNibName:@"PGPayoffViewImageViewController" bundle:nil];
            
            [viewImageVc showImageSameDayAsDate:metadata.created];
            [self.arrayOfViewControllers addObject:viewImageVc];
        }
        
        if (metadata.location && CLLocationCoordinate2DIsValid(metadata.location.geo)) {
            PGPayoffViewImageViewController *viewImageVc = [[PGPayoffViewImageViewController alloc]
                                                            initWithNibName:@"PGPayoffViewImageViewController" bundle:nil];
            
            CLLocation *loc = [[CLLocation alloc] initWithLatitude:metadata.location.geo.latitude longitude:metadata.location.geo.longitude];
            [viewImageVc showImagesSameLocation:loc];
            [self.arrayOfViewControllers addObject:viewImageVc];
        }
    } else {
        PGPayoffViewErrorViewController *viewErrorVc = [[PGPayoffViewErrorViewController alloc]
                                                        initWithNibName:@"PGPayoffViewErrorViewController" bundle:nil];
        viewErrorVc.parentVc = self;
        
        [self.arrayOfViewControllers addObject:viewErrorVc];
    }

    __weak __typeof__(self) weakSelf = self;
    
    [_pageViewController setViewControllers:@[[self.arrayOfViewControllers objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        [weakSelf.activityIndicator stopAnimating];
        weakSelf.pageViewController.view.hidden = NO;

        weakSelf.pageControl.numberOfPages = [weakSelf.arrayOfViewControllers count];
        weakSelf.pageControl.currentPage = 0;
        [weakSelf.pageControl setHidden:NO];
    }];
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

- (IBAction)closeButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
    self.pendingIndex = [self.arrayOfViewControllers indexOfObject:[pendingViewControllers firstObject]];
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
       transitionCompleted:(BOOL)completed {
    if (completed) {
        self.pageControl.currentPage = self.pendingIndex;
    }
}
@end
