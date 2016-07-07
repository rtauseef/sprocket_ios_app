//
//  PGMediaNavigation.m
//  Sprocket
//
//  Created by Susy Snowflake on 6/30/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import "PGMediaNavigation.h"
#import "PGAppAppearance.h"
#import <HPPRInstagramPhotoProvider.h>
#import <HPPRFacebookPhotoProvider.h>
#import <HPPRFlickrPhotoProvider.h>
#import <HPPRCameraRollPhotoProvider.h>
#import "UIFont+Style.h"
#import "SSRollingButtonScrollView.h"

@interface PGMediaNavigation() <SSRollingButtonScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *navigationView;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet SSRollingButtonScrollView *scrollView;
@property (strong, nonatomic) NSArray *providers;
@property (weak, nonatomic) IBOutlet UIButton *folderButton;

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
    
    self.providers = [NSArray arrayWithObjects:
                      [HPPRInstagramPhotoProvider sharedInstance].name,
                      [HPPRFacebookPhotoProvider sharedInstance].name,
                      [HPPRFlickrPhotoProvider sharedInstance].name,
                      [HPPRCameraRollPhotoProvider sharedInstance].name, nil];
    self.scrollView.spacingBetweenButtons = 0.0f;
    
    self.scrollView.centerButtonTextColor = [UIColor whiteColor];
    self.scrollView.buttonCenterFont = [UIFont HPNavigationBarTitleFont];

    self.scrollView.notCenterButtonTextColor = [UIColor grayColor];
    self.scrollView.buttonNotCenterFont = [UIFont HPNavigationBarSubTitleFont];
    
    [self.scrollView createButtonArrayWithButtonTitles:self.providers andLayoutStyle:SShorizontalLayout];
    self.scrollView.ssRollingButtonScrollViewDelegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFolderIcon) name:SHOW_ALBUMS_FOLDER_ICON object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideFolderIcon) name:HIDE_ALBUMS_FOLDER_ICON object:nil];

    self.cameraView.backgroundColor = [UIColor clearColor];
    self.cameraView.alpha = 0.7F;
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.cameraView.bounds;
    gradient.colors = @[(id)[UIColor blackColor].CGColor, (id)[UIColor clearColor].CGColor];
    gradient.startPoint = CGPointMake(0,1);
    gradient.endPoint = CGPointMake(1, 0);
    [self.cameraView.layer insertSublayer:gradient atIndex:0];
}

-(void)showFolderIcon:(BOOL)show
{
    self.folderButton.hidden = !show;
}

-(void)showFolderIcon
{
    [self showFolderIcon:YES];
}

-(void)hideFolderIcon
{
    [self showFolderIcon:NO];
}

-(void)setScrollProgress:(UIScrollView *)scrollView progress:(CGFloat)progress forPage:(NSInteger)page
{
    [self.scrollView setScrollProgress:progress onPage:page];
}

-(void)showFolderButton:(BOOL)show
{
    self.folderButton.hidden = !show;
}

- (void)selectButton:(NSString *)title animated:(BOOL)animated
{
    [self.scrollView selectButton:title animated:animated];
}

- (IBAction)didPressFolderButton:(id)sender {
    
    if (self.delegate  &&  [self.delegate respondsToSelector:@selector(mediaNavigationDidPressFolderButton:)]) {
        [self.delegate mediaNavigationDidPressFolderButton:self];
    }
    
    if ([PGAppAppearance navBarColor] == self.navigationView.backgroundColor) {
        self.navigationView.backgroundColor = [UIColor blueColor];
    } else {
        self.navigationView.backgroundColor = [PGAppAppearance navBarColor];
    }
}

- (IBAction)didPressMenuButton:(id)sender {
    if (self.delegate  &&  [self.delegate respondsToSelector:@selector(mediaNavigationDidPressMenuButton:)]) {
        [self.delegate mediaNavigationDidPressMenuButton:self];
    }
}

- (IBAction)didPressCameraButton:(id)sender {
    if (self.delegate  &&  [self.delegate respondsToSelector:@selector(mediaNavigationDidPressCameraButton:)]) {
        [self.delegate mediaNavigationDidPressCameraButton:self];
    }
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // Only accept events for the top and bottom bars
    BOOL inNavigationView = NO;
    if( point.y < self.navigationView.frame.size.height &&
        (point.x < self.scrollView.frame.origin.x  ||
         point.x > self.scrollView.frame.origin.x + self.scrollView.frame.size.width) ) {
        inNavigationView = YES;
    }
       
    BOOL inCameraBar = point.y > (self.bounds.size.height - self.cameraView.frame.size.height);
    
    return ( inNavigationView || inCameraBar );
}

@end
