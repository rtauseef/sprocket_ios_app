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

#import "PGMediaNavigation.h"
#import "PGAppAppearance.h"
#import <HPPR.h>
#import "UIFont+Style.h"
#import "SSRollingButtonScrollView.h"
#import "AlphaGradientView.h"
#import "PGSocialSourcesManager.h"


@interface PGMediaNavigation() <SSRollingButtonScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *navigationView;
@property (weak, nonatomic) IBOutlet AlphaGradientView *cameraView;
@property (weak, nonatomic) IBOutlet SSRollingButtonScrollView *scrollView;
@property (strong, nonatomic) NSArray *providers;
@property (weak, nonatomic) IBOutlet UIButton *folderButton;
@property (assign, nonatomic) BOOL refreshing;

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

    NSMutableArray *titles = [[NSMutableArray alloc] init];

    for (PGSocialSource *socialSource in [[PGSocialSourcesManager sharedInstance] enabledSocialSources]) {
        [titles addObject:socialSource.title];
    }

    self.providers = [titles copy];

    self.scrollView.spacingBetweenButtons = 5.0f;
    
    self.scrollView.centerButtonTextColor = [UIColor whiteColor];
    self.scrollView.buttonCenterFont = [UIFont HPNavigationBarTitleFont];

    self.scrollView.notCenterButtonTextColor = [UIColor grayColor];
    self.scrollView.buttonNotCenterFont = [UIFont HPNavigationBarSubTitleFont];
    
    [self.scrollView createButtonArrayWithButtonTitles:self.providers andLayoutStyle:SShorizontalLayout];
    self.scrollView.ssRollingButtonScrollViewDelegate = self;
    self.refreshing = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFolderIcon) name:SHOW_ALBUMS_FOLDER_ICON object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideFolderIcon) name:HIDE_ALBUMS_FOLDER_ICON object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectSocialNetwork:) name:SHOW_SOCIAL_NETWORK_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoCollectionBeginRefresh:) name:HPPR_PHOTO_COLLECTION_BEGIN_REFRESH object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoCollectionEndRefresh:) name:HPPR_PHOTO_COLLECTION_END_REFRESH object:nil];

    self.cameraView.direction = GRADIENT_DOWN;
}

-(void)showFolderIcon:(BOOL)show
{
    [UIView animateWithDuration:0.3 animations:^{
        self.folderButton.alpha = (show) ? 1.0f : 0.0f;
    }];
}

-(void)showFolderIcon
{
    [self showFolderIcon:YES];
}

-(void)hideFolderIcon
{
    [self showFolderIcon:NO];
}

- (void)selectSocialNetwork:(NSNotification *)notification
{
    PGSocialSourceType socialSourceType = [[notification.userInfo objectForKey:kSocialNetworkKey] unsignedIntegerValue];

    PGSocialSource *socialSource = [[PGSocialSource alloc] initWithSocialSourceType:socialSourceType];

    [self selectButton:socialSource.title animated:YES];
}

- (void)selectButton:(NSString *)title animated:(BOOL)animated
{
    [self.scrollView selectButton:title animated:animated];
}

- (IBAction)didPressFolderButton:(id)sender {
    
    if (self.refreshing) {
        return;
    }
    
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

- (void)photoCollectionBeginRefresh:(id)sender
{
    self.refreshing = YES;
}

- (void)photoCollectionEndRefresh:(id)sender
{
    self.refreshing = NO;
}

@end
