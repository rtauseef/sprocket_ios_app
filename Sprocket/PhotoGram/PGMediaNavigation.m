//
//  PGMediaNavigation.m
//  Sprocket
//
//  Created by Susy Snowflake on 6/30/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import "PGMediaNavigation.h"
#import "SSRollingButtonScrollView.h"

@interface PGMediaNavigation() <SSRollingButtonScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *navigationView;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet SSRollingButtonScrollView *scrollView;

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
        NSArray *phoneticAlphabet = [NSArray arrayWithObjects:@"Instagram", @"Facebook", @"Flickr", @"Camera Roll", nil];
    self.scrollView.spacingBetweenButtons = 10.0f;
    self.scrollView.notCenterButtonTextColor = [UIColor grayColor];
    self.scrollView.centerButtonTextColor = [UIColor whiteColor];
    [self.scrollView createButtonArrayWithButtonTitles:phoneticAlphabet andLayoutStyle:SShorizontalLayout];
    self.scrollView.ssRollingButtonScrollViewDelegate = self;
}

- (IBAction)didPressFolderButton:(id)sender {
    if ([UIColor blackColor] == self.navigationView.backgroundColor) {
        self.navigationView.backgroundColor = [UIColor blueColor];
    } else {
        self.navigationView.backgroundColor = [UIColor blackColor];
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
