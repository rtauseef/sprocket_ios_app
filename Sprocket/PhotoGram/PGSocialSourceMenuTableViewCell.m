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

#import "PGSocialSourceMenuTableViewCell.h"

#import "UIColor+Style.h"
#import "UIFont+Style.h"
#import "UIImageView+MaskImage.h"

CGFloat const kPGSocialSourceMenuTableViewCellSmallFontSize = 16.0f;
CGFloat const kPGSocialSourceMenuTableViewCellSignInSmallFontSize = 13.0f;

@implementation PGSocialSourceMenuTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)configureCell:(PGSocialSource *)socialSource
{
    self.socialSource = socialSource;
    self.socialTitle.text = socialSource.title;
    self.socialTitle.textColor = [UIColor whiteColor];
    
    if (IS_IPHONE_4 || IS_IPHONE_5) {
        self.socialTitle.font = [UIFont fontWithName:self.socialTitle.font.fontName size:kPGSocialSourceMenuTableViewCellSmallFontSize];
        self.signInButton.titleLabel.font = [UIFont fontWithName:self.signInButton.titleLabel.font.fontName size:kPGSocialSourceMenuTableViewCellSignInSmallFontSize];
    }
    
    self.signInButton.hidden = !socialSource.needsSignIn;
    self.backgroundColor = [UIColor HPGrayColor]; // bugfix iOS 8
    
    [self configureSocialSourceImage];
    [self configureSignInButton];
    
    UIView *selectionColorView = [[UIView alloc] init];
    selectionColorView.backgroundColor = [UIColor HPTableRowSelectionColor];
    self.selectedBackgroundView = selectionColorView;
}

- (IBAction)signInButtonTapped:(id)sender {
    if (self.socialSource.isLogged) {
        [self displaySignOutAlert];
    }
}

- (void)configureSignInButton
{
    NSString *title = (self.socialSource.isLogged) ? NSLocalizedString(@"Sign Out", nil) : NSLocalizedString(@"Sign In", nil);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.signInButton setTitle:title forState:UIControlStateNormal];
        self.signInButton.userInteractionEnabled = self.socialSource.isLogged;
    });
}

- (void)configureSocialSourceImage
{
    switch (self.socialSource.type) {
        case PGSocialSourceTypeFacebook: {
            [self configureFacebookUserView];
            break;
        }
        case PGSocialSourceTypeInstagram: {
            [self configureInstagramUserView];
            break;
        }
        case PGSocialSourceTypeFlickr: {
            [self configureFlickrUserView];
            break;
        }
        default: {
            [self resetSocialSourceImage];
            break;
        }
    }
}

- (void)resetSocialSourceImage
{
    dispatch_async(dispatch_get_main_queue(), ^ {
        self.socialImageView.image = self.socialSource.menuIcon;
    });
}

#pragma mark - Sign In/Out Methods

- (void)configureFacebookUserView
{
    [[HPPRFacebookLoginProvider sharedInstance] checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
        self.socialSource.isLogged = loggedIn;
        
        if (loggedIn) {
            [self fetchFacebookData];
        } else {
            [self resetSocialSourceImage];
        }
    }];
}

- (void)fetchFacebookData
{
    [[HPPRFacebookPhotoProvider sharedInstance] userInfoWithRefresh:NO andCompletion:^(NSDictionary *userInfo, NSError *error) {
        __weak PGSocialSourceMenuTableViewCell *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^ {
            if (!error) {
                NSString *profilePictureUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square",  [userInfo objectForKey:@"id"]];
                [weakSelf.socialImageView setMaskImageWithURL:profilePictureUrl];
            } else {
                weakSelf.socialSource.isLogged = NO;
                [weakSelf resetSocialSourceImage];
            }
            
            [weakSelf configureSignInButton];
        });
    }];
}

- (void)configureInstagramUserView
{
    [HPPRInstagramUser userProfileWithId:@"self" completion:^(NSString *userName, NSString *userId, NSString *profilePictureUrl, NSNumber *posts, NSNumber *followers, NSNumber *following) {
        
        __weak PGSocialSourceMenuTableViewCell *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^ {
            if (profilePictureUrl) {
                [weakSelf.socialImageView setMaskImageWithURL:profilePictureUrl];
                weakSelf.socialSource.isLogged = YES;
            } else {
                weakSelf.socialSource.isLogged = NO;
                [weakSelf resetSocialSourceImage];
            }
            
            [weakSelf configureSignInButton];
        });
        
    }];
}

- (void)configureFlickrUserView
{
    [[HPPRFlickrLoginProvider sharedInstance] checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
        
        __weak PGSocialSourceMenuTableViewCell *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (loggedIn) {
                NSDictionary *user = [HPPRFlickrLoginProvider sharedInstance].user;
                [weakSelf.socialImageView setMaskImageWithURL:[user objectForKey:@"imageURL"]];
                weakSelf.socialSource.isLogged = YES;
            } else {
                weakSelf.socialSource.isLogged = NO;
                [weakSelf resetSocialSourceImage];
            }
            
            [weakSelf configureSignInButton];
        });
    }];
}

- (void)signOut
{
    [self.socialSource.loginProvider logoutWithCompletion:^(BOOL loggedOut, NSError *error) {
        __weak PGSocialSourceMenuTableViewCell *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CHECK_PROVIDER_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:self.socialSource.photoProvider.name forKey:kSocialNetworkKey]];
            
            weakSelf.socialSource.isLogged = !loggedOut;
            weakSelf.socialImageView.image = weakSelf.socialSource.menuIcon;
            [weakSelf configureSignInButton];
        });
    }];
}

#pragma mark - Sign Out UIAlertView

- (void)displaySignOutAlert
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *alertMessage = [NSString localizedStringWithFormat:
                                  NSLocalizedString(@"Would you like to sign out of %@?",
                                                    @"Ask user if he/she wishes to sign out of a particular social media site."), self.socialSource.photoProvider.localizedName];
        NSString *cancel = [NSString localizedStringWithFormat:
                            NSLocalizedString(@"Cancel",
                                              @"Generic Cancel from an action.")];
        NSString *signOut = [NSString localizedStringWithFormat:
                             NSLocalizedString(@"Sign Out",
                                               @"Signing out of a social media site.")];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:alertMessage
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel
                                                             handler:nil];
        
        UIAlertAction *signOutAction = [UIAlertAction actionWithTitle:signOut style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  [self signOut];
                                                              }];
        
        [alert addAction:cancelAction];
        [alert addAction:signOutAction];
        
        // Setting the preferred action is only available in iOS9 and later
        if ([alert respondsToSelector:@selector(setPreferredAction:)]) {
            [alert performSelector:@selector(setPreferredAction:) withObject:cancelAction];
        }
        
        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        [topController presentViewController:alert animated:YES completion:nil];
    });
}


@end
