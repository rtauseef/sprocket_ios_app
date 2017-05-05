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
#import "AlphaGradientView.h"
#import "PGFeatureFlag.h"
#import "PGHamburgerButton.h"

static NSString * const kMediaNavigationNextButtonFormat = @"%li  〉";

@interface PGMediaNavigation()

@property (weak, nonatomic) IBOutlet UIView *navigationView;
@property (weak, nonatomic) IBOutlet AlphaGradientView *gradientBar;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *titleButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *albumsArrow;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet PGHamburgerButton *hamburgerButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation PGMediaNavigation

+ (instancetype)sharedInstance {
    static PGMediaNavigation *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PGMediaNavigation alloc] initWithFrame:CGRectZero];
    });

    return instance;
}

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
    self.selectButton.hidden = ![PGFeatureFlag isMultiPrintEnabled];
    self.cancelButton.hidden = YES;
    self.nextButton.hidden = YES;
    [self updateSelectedItemsCount:0];

    self.navigationView.backgroundColor = [PGAppAppearance navBarColor];

    self.gradientBar.direction = GRADIENT_DOWN;
    [self.hamburgerButton refreshIndicator];
}

-(void)showAlbumsDropDownButton:(BOOL)show
{
    self.titleButton.enabled = show;
    self.albumsArrow.alpha = (show) ? 1.0f : 0.0f;
}

- (void)showAlbumsDropDownButtonUp:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.albumsArrow.transform = CGAffineTransformMakeRotation(M_PI);
        }];
    } else {
        self.albumsArrow.transform = CGAffineTransformMakeRotation(M_PI);
    }

    [self showAlbumsDropDownButton:YES];
}

- (void)showAlbumsDropDownButtonDown:(BOOL)animated
{
    if (animated) {
        CGAffineTransform transform = CGAffineTransformIdentity;

        if (!CGAffineTransformIsIdentity(self.albumsArrow.transform)) {
            transform = CGAffineTransformMakeRotation(-M_PI * 2);
        }

        [UIView animateWithDuration:0.3 animations:^{
            self.albumsArrow.transform = transform;
        } completion:^(BOOL finished) {
            self.albumsArrow.transform = CGAffineTransformIdentity;
        }];
    } else {
        self.albumsArrow.transform = CGAffineTransformIdentity;
    }

    [self showAlbumsDropDownButton:YES];
}

- (void)hideAlbumsDropDownButton
{
    [self showAlbumsDropDownButton:NO];
}


#pragma mark - UI State control

- (void)beginSelectionMode {
    self.cancelButton.hidden = NO;
    self.hamburgerButton.hidden = YES;
    self.selectButton.hidden = YES;
    self.cameraButton.enabled = NO;
}

- (void)endSelectionMode {
    self.cancelButton.hidden = YES;
    self.nextButton.hidden = YES;
    self.hamburgerButton.hidden = NO;
    self.selectButton.hidden = ![PGFeatureFlag isMultiPrintEnabled];
    self.cameraButton.enabled = YES;
}

- (void)disableSelectionMode {
    self.cancelButton.hidden = YES;
    self.nextButton.hidden = YES;
    self.hamburgerButton.hidden = NO;
    self.selectButton.hidden = YES;
}

- (void)updateSelectedItemsCount:(NSInteger)count {
    NSString *title = [NSString stringWithFormat:kMediaNavigationNextButtonFormat, count];

    [self.nextButton setTitle:title forState:UIControlStateNormal];

    self.nextButton.hidden = (count <= 0);
}

- (void)showGradientBar {
    [UIView animateWithDuration:0.2 animations:^{
        self.gradientBar.transform = CGAffineTransformIdentity;
    }];
}

- (void)hideGradientBar {
    [UIView animateWithDuration:0.2 animations:^{
        self.gradientBar.transform = CGAffineTransformMakeTranslation(0.0, self.gradientBar.frame.size.height);
    }];
}

- (void)showCameraButton {
    [UIView animateWithDuration:0.2 animations:^{
        self.cameraButton.alpha = 1.0f;
    }];
}

- (void)hideCameraButton {
    [UIView animateWithDuration:0.2 animations:^{
        self.cameraButton.alpha = 0.0f;
    }];
}

- (void)setSocialSource:(PGSocialSource *)socialSource
{
    _socialSource = socialSource;

    self.titleLabel.text = socialSource.title;
}

- (IBAction)didPressFolderButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(mediaNavigationDidPressFolderButton:)]) {
        [self.delegate mediaNavigationDidPressFolderButton:self];
    }
}

- (IBAction)didPressMenuButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(mediaNavigationDidPressMenuButton:)]) {
        [self.delegate mediaNavigationDidPressMenuButton:self];
    }
}

- (IBAction)didPressCameraButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(mediaNavigationDidPressCameraButton:)]) {
        [self.delegate mediaNavigationDidPressCameraButton:self];
    }
}

- (IBAction)didPressSelectButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(mediaNavigationDidPressSelectButton:)]) {
        [self.delegate mediaNavigationDidPressSelectButton:self];
    }
}

- (IBAction)didPressCancelButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(mediaNavigationDidPressCancelButton:)]) {
        [self.delegate mediaNavigationDidPressCancelButton:self];
    }
}

- (IBAction)didPressNextButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(mediaNavigationDidPressNextButton:)]) {
        [self.delegate mediaNavigationDidPressNextButton:self];
    }
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL overNavigationView = point.y <= self.navigationView.frame.size.height;

    BOOL overCameraButton = NO;
    if (self.cameraButton.alpha > 0.0) {
        BOOL overCameraBar = point.y >= self.gradientBar.frame.origin.y;

        BOOL leftOfCameraButton = point.x < self.cameraButton.frame.origin.x;
        BOOL rightOfCameraButton = point.x > (self.cameraButton.frame.origin.x + self.cameraButton.frame.size.width);

        overCameraButton = overCameraBar && ( !leftOfCameraButton && !rightOfCameraButton );
    }

    return overNavigationView || overCameraButton;
}

@end
