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

@interface PGMetarPayoffViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *paginationView;

@property (strong, nonatomic) NSMutableArray <UIViewController *> *arrayOfViewControllers;
@property (strong, nonatomic) UIPageViewController *pageViewController;

@end

@implementation PGMetarPayoffViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.metadata != nil && self.metadata.data != nil && [self.metadata.data objectForKey:kPGPayoffUUIDKey] != nil) {
        // resolve metadata
        [self.activityIndicator startAnimating];
        
        PGMetarAPI * api = [[PGMetarAPI alloc] init];
        
        [api authenticate:^(BOOL success) {
            if (success) {
                [api requestImageMetadataWithUUID:[self.metadata.data objectForKey:kPGPayoffUUIDKey] completion:^(NSError * _Nullable error, PGMetarMedia * _Nullable metarMedia) {
                    
                    NSLog(@"Got metar media info...");
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.activityIndicator stopAnimating];
                    });
                }];
            } else {
                NSLog(@"METAR API Auth Error");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activityIndicator stopAnimating];
                });
            }
        }];
    }
    
    PGPayoffViewImageViewController *viewImageVc = [[PGPayoffViewImageViewController alloc] initWithNibName:@"PGPayoffViewImageViewController" bundle:nil];
    PGPayoffViewVideoViewController *viewVideoVc = [[PGPayoffViewVideoViewController alloc]
        initWithNibName:@"PGPayoffViewVideoViewController" bundle:nil];
    
    self.arrayOfViewControllers = [NSMutableArray array];
    [self.arrayOfViewControllers addObject:viewImageVc];
    [self.arrayOfViewControllers addObject:viewVideoVc];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    [_pageViewController.view setFrame:self.paginationView.bounds];
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
 
    [_pageViewController setViewControllers:@[[self.arrayOfViewControllers objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        
    }];
    
    [self.paginationView addSubview:_pageViewController.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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

@end
