//
//  PGMediaNavigation.m
//  Sprocket
//
//  Created by Susy Snowflake on 6/30/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import "PGMediaNavigation.h"
#import "PGAppAppearance.h"
#import "UIFont+Style.h"
#import "SSRollingButtonScrollView.h"

@interface PGMediaNavigation() <SSRollingButtonScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *navigationView;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet SSRollingButtonScrollView *scrollView;
@property (strong, nonatomic) NSArray *providers;

@end

@implementation PGMediaNavigation

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.navigationView.backgroundColor = [PGAppAppearance navBarColor];
    
    self.providers = [NSArray arrayWithObjects:@"Instagram", @"Facebook", @"Flickr", @"Camera Roll", nil];
    self.scrollView.spacingBetweenButtons = 0.0f;
    
    self.scrollView.centerButtonTextColor = [UIColor whiteColor];
    self.scrollView.buttonCenterFont = [UIFont HPNavigationBarTitleFont];

    self.scrollView.notCenterButtonTextColor = [UIColor grayColor];
    self.scrollView.buttonNotCenterFont = [UIFont HPNavigationBarSubTitleFont];
    
    [self.scrollView createButtonArrayWithButtonTitles:self.providers andLayoutStyle:SShorizontalLayout];
    self.scrollView.ssRollingButtonScrollViewDelegate = self;
}

-(void)setScrollProgress:(UIScrollView *)scrollView progress:(CGFloat)progress forPage:(NSInteger)page
{
    [self.scrollView setScrollProgress:progress onPage:page];
}

- (void)selectButton:(NSString *)title animated:(BOOL)animated
{
    [self.scrollView selectButton:title animated:animated];
}

- (IBAction)didPressFolderButton:(id)sender {
    if ([PGAppAppearance navBarColor] == self.navigationView.backgroundColor) {
        self.navigationView.backgroundColor = [UIColor blueColor];
    } else {
        self.navigationView.backgroundColor = [PGAppAppearance navBarColor];
    }
}

- (IBAction)didPressMenuButton:(id)sender {
    // need to pass request for hamburger menu to view controller
    
//    UIBarButtonItem *hamburgerButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Hamburger"] style:UIBarButtonItemStyleBordered target:self.revealViewController action:@selector(revealToggle:)];
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // Only accept events for the top and bottom bars
    BOOL inNavigationView = point.y < self.navigationView.frame.size.height;
    BOOL inCameraBar = point.y > (self.bounds.size.height - self.cameraView.frame.size.height);
    
    return ( inNavigationView || inCameraBar );
}

@end
