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

#import "HPPRSelectPhotoCollectionViewController.h"
#import "HPPRCameraRollPhotoProvider.h"
#import "HPPR.h"
#import "HPPRSelectPhotoCollectionViewCell.h"
#import "HPPRNoInternetConnectionRetryView.h"
#import "HPPRNoInternetConnectionMessageView.h"
#import "HPPRCacheService.h"
#import "HPPRSelectPhotoProvider.h"
#import "HPPRAppearance.h"
#import "UIView+HPPRAnimation.h"
#import "NSBundle+HPPRLocalizable.h"

#define LAYOUT_SEGMENTED_CONTROL_GRID_INDEX 0
#define LAYOUT_SEGMENTED_CONTROL_LIST_INDEX 1

NSString * const kPhotoSelectionScreenName = @"Photo Selection Screen";

@interface HPPRSelectPhotoCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UIAlertViewDelegate, HPPRNoInternetConnectionRetryViewDelegate, HPPRSelectPhotoCollectionViewCellDelegate, HPPRSelectPhotoProviderDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) UIImage *selectedImage;
@property (weak, nonatomic) IBOutlet UILabel *userAccountIsPrivateLabel;
@property (weak, nonatomic) IBOutlet UILabel *noPhotosLabel;

@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet HPPRNoInternetConnectionRetryView *noInternetConnectionRetryView;
@property (weak, nonatomic) IBOutlet HPPRNoInternetConnectionMessageView *noInternetConnectionMessageView;

@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIAlertView *deletedAlbumAlertView;
@property (assign, nonatomic, getter = isRequestingImages) BOOL requestingImages;
@property (assign, nonatomic, getter = isReloadingImages) BOOL reloadingImages;

@property (strong, nonatomic) HPPRSelectPhotoCollectionViewCell *currentSelectedCell;

@property (assign, nonatomic) BOOL showGridView;

@end

@implementation HPPRSelectPhotoCollectionViewController {
    CGPoint _contentOffsetStart;
}

#pragma mark - View management

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cameraButtonInCollectionView = NO;
    }
    return self;
}
- (void)initRefreshControl
{
    if (!self.refreshControl) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl setTintColor:[[HPPR sharedInstance].appearance.settings objectForKey:kHPPRTintColor]];
        [self.refreshControl addTarget:self action:@selector(startRefreshing:) forControlEvents:UIControlEventValueChanged];
        [self.collectionView addSubview:self.refreshControl];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.noPhotosLabel.text = HPPRLocalizedString(@"No Photos Found", @"Message shown when the album is empty in the select photo screen");
    self.userAccountIsPrivateLabel.text = HPPRLocalizedString(@"The user account is private.", @"Message shown when the user account is private in the select photo screen");
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];
    
    if ([self.delegate respondsToSelector:@selector(collectionViewContentInset)]) {
        self.collectionView.contentInset = [self.delegate collectionViewContentInset];
    }
    
    self.backgroundView.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];
    self.showGridView = YES;
    
    UIFont *labelFont = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRSecondaryLabelFont];
    UIColor *labelColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRSecondaryLabelColor];
    
    [self initForDisplayType];
    
    self.spinner = [self.view HPPRAddSpinner];
    
    self.provider.imageRequestsCancelled = NO;

    self.noInternetConnectionRetryView.delegate = self;
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer  alloc] initWithTarget:self action:@selector(handlePinchToZoom:)];
    [self.collectionView addGestureRecognizer:pinchRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.customNoPhotosMessage) {
        self.noPhotosLabel.text = self.customNoPhotosMessage;
    }

    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    [self.spinner startAnimating];
    [self refreshImages:^{
        [self.spinner stopAnimating];

        [self initRefreshControl];
    }];

    [[NSNotificationCenter defaultCenter] postNotificationName:HPPR_TRACKABLE_SCREEN_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@ %@", self.provider.name, kPhotoSelectionScreenName] forKey:kHPPRTrackableScreenNameKey]];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
    [self.collectionView reloadData];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView == self.deletedAlbumAlertView) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (UIAlertView *)deletedAlbumAlertView
{
    if (nil == _deletedAlbumAlertView) {
        NSError *error = [HPPRAlbum albumDeletedError];
        
        _deletedAlbumAlertView = [[UIAlertView alloc] initWithTitle:error.localizedFailureReason message:error.localizedDescription delegate:self cancelButtonTitle:HPPRLocalizedString(@"OK", @"Button caption") otherButtonTitles:nil];
    }
    
    return _deletedAlbumAlertView;
}

#pragma mark - Pull to refresh

- (void)startRefreshing:(UIRefreshControl *)refreshControl
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HPPR_PHOTO_COLLECTION_BEGIN_REFRESH object:nil];

    self.noPhotosLabel.hidden = YES;

    [self refreshImages:^{
        if ((nil != refreshControl) && refreshControl.refreshing) {
            [refreshControl endRefreshing];
            [[NSNotificationCenter defaultCenter] postNotificationName:HPPR_PHOTO_COLLECTION_END_REFRESH object:nil];
        }
    }];
}

#pragma mark - Labels

- (void)initForDisplayType
{
    self.title = [NSString stringWithFormat:HPPRLocalizedString(@"%@ Photos", @"Photos of the specified social network"), self.provider.localizedName];
    
    if (!self.provider.showSearchButton) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - Image request

- (void)refreshImages:(void (^)())completion {
    [self.provider refreshAlbumWithCompletion:^(NSError *error) {
        if (error == nil) {
            [self requestImagesWithCompletion:^(NSArray *records, BOOL complete) {
                if (complete) {
                    [self finishImageRequestWithRecords:nil];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) {
                            completion();
                        }
                    });
                }
            } andReloadAll:YES];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (([error.domain isEqualToString:HP_PHOTO_PROVIDER_DOMAIN]) && (error.code == ALBUM_DOES_NOT_EXISTS)) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:HPPR_ALBUM_CHANGE_NOTIFICATION object:nil];

                    [self.deletedAlbumAlertView show];
                } else {
                    [[[UIAlertView alloc] initWithTitle:error.localizedFailureReason message:error.localizedDescription delegate:self cancelButtonTitle:HPPRLocalizedString(@"OK", @"Button caption") otherButtonTitles:nil] show];
                }

                if (completion) {
                    completion();
                }
            });
        }
    }];
}

- (void)requestImagesWithCompletion:(void (^)(NSArray *records, BOOL complete))completion andReloadAll:(BOOL)reload
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        if (reload) {
            self.reloadingImages = YES;
            self.requestingImages = NO;
        }
        
        if (!self.isRequestingImages) {
            self.requestingImages = YES;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.noPhotosLabel.hidden = YES;
                self.noInternetConnectionRetryView.hidden = YES;
                
                [self.provider requestImagesWithCompletion:^(NSArray *records) {
                    if (completion) {
                        completion(records, YES);
                    }
                    self.requestingImages = NO;
                } andReloadAll:reload];
            });
        } else {
            if (completion) {
                completion(nil, NO);
            }
        }
    });
}

- (void)finishImageRequestWithRecords:(NSArray *)records
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (nil == records) {
            self.noPhotosLabel.hidden = ([self.provider imageCount] > 0);
            [self.collectionView reloadData];
            self.reloadingImages = NO;
        } else {
            if (!self.isReloadingImages) {
                // If there is an image request with reload while the batch updates is being called then a crash can be produced ('NSInternalInconsistencyException', reason: 'Invalid update: invalid number of items in section 0.  The number of items contained in an existing section after the update (50) must be equal to the number of items contained in that section before the update (150), plus or minus the number of items inserted or deleted from that section (50 inserted, 0 deleted) and plus or minus the number of items moved into or out of that section (0 moved in, 0 moved out).'). The solution is to avoid doing batch updates while a higher request (a request with reload) is on progress.
                [self.collectionView performBatchUpdates:^{
                    NSInteger imageCount = [self.provider imageCount];
                    NSInteger originalCount = imageCount - records.count;
                    NSLog(@"(imageCount %ld) (originalCount %ld) (records.count %ld)", (long)imageCount, (long)originalCount, (unsigned long)records.count);
                    
                    NSMutableArray *newItemsIndexes = [NSMutableArray array];
                    for (int idx = 0; idx < [records count]; idx++) {
                        [newItemsIndexes addObject:[NSIndexPath indexPathForItem:(idx + originalCount) inSection:0]];
                    }
                    [self.collectionView insertItemsAtIndexPaths:[newItemsIndexes copy]];
                } completion:nil];
            }
        }
    });
}


#pragma mark - Collection View Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.cameraButtonInCollectionView) {
        return [self.provider imageCount] + 1;
    }
    
    return [self.provider imageCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cameraButtonInCollectionView && indexPath.item == 0) {
        UICollectionView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CameraCell" forIndexPath:indexPath];
        
        return cell;
    } else {
        HPPRSelectPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
        cell.delegate = self;
        cell.retrieveLowQuality = self.showGridView;
        cell.media = [self.provider imageAtIndex:indexPath.row];
        
        return cell;
    }
}

#pragma mark - MCSelectPhotoViewCellDelegate

- (void)selectPhotoCollectionViewCellDidFailRetrievingImage:(HPPRSelectPhotoCollectionViewCell *)cell
{
    if (self.provider.showNetworkWarning) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self.noInternetConnectionMessageView show];
        });
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if  (self.cameraButtonInCollectionView && indexPath.item == 0) {
        if ([self.delegate respondsToSelector:@selector(selectPhotoCollectionViewControllerDidSelectCamera:)]) {
            [self.delegate selectPhotoCollectionViewControllerDidSelectCamera:self];
        }
        
        return;
    }
    
    HPPRSelectPhotoCollectionViewCell *cell = (HPPRSelectPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [cell showLoading];
    
    if (self.currentSelectedCell) {
        [self.currentSelectedCell.media cancelImageRequestWithCompletion:nil];
        [self.currentSelectedCell hideLoading];
    }
    
    self.currentSelectedCell = cell;
    
    [self.provider retrieveExtraMediaInfo:cell.media withRefresh:NO andCompletion:^(NSError *error) {
        
        if (!self.provider.isImageRequestsCancelled) {
            
            if (cell.media.asset) {
                __weak HPPRSelectPhotoCollectionViewController *weakSelf = self;
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self.spinner stopAnimating];
                    
                    [cell.media requestImageWithCompletion:^(UIImage *image) {
                        dispatch_async(dispatch_get_main_queue(), ^(void){
                            [weakSelf selectImage:image andMedia:cell.media];
                            [weakSelf.spinner stopAnimating];
                            [cell hideLoading];
                            weakSelf.currentSelectedCell = nil;
                        });
                    }];
                });
                
                return;
            }
            
            // We continue even if we don't get the extra info because of an error
            [[HPPRCacheService sharedInstance] imageForUrl:cell.media.standardUrl asThumbnail:NO withCompletion:^(UIImage *image, NSString *url, NSError *error) {
                if (!self.provider.isImageRequestsCancelled) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell hideLoading];
                        
                        [self selectImage:image andMedia:cell.media];
                        
                        collectionView.userInteractionEnabled = YES;
                    });
                } else {
                    [cell hideLoading];
                }
                
                self.currentSelectedCell = nil;
            }];
        } else {
            [cell hideLoading];
            self.currentSelectedCell = nil;
        }
    }];
}

- (void)selectImage:(UIImage *)image andMedia:(HPPRMedia *)media
{
    if (nil == image) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:HPPRLocalizedString(@"Error", @"Title of an alert")
                                                            message:[NSString stringWithFormat:HPPRLocalizedString(@"Could not retrieve the picture from %@", @"Message of an alert when is not possible to retrieve the pictures from the specified social network"), self.provider.name]
                                                           delegate:nil
                                                  cancelButtonTitle:HPPRLocalizedString(@"OK", @"Button caption")
                                                  otherButtonTitles:nil];
        [alertView show];
    } else {
        if ([self.delegate respondsToSelector:@selector(selectPhotoCollectionViewController:didSelectImage:source:media:)]) {
            NSString *source = [self.provider.name stringByReplacingOccurrencesOfString:@" " withString:@""];
            [self.delegate selectPhotoCollectionViewController:self didSelectImage:image source:source media:media];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.showGridView) ? GRID_COLLECTION_VIEW_SIZE : LIST_COLLECTION_VIEW_SIZE;
}

#pragma mark - Button actions

- (IBAction)backButtonTapped:(id)sender
{
    [self.provider cancelAllOperations];
    
    UIViewController *vc = [self.navigationController popViewControllerAnimated:YES];
    
    if (vc == nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIPinchGestureRecognizer

- (void)handlePinchToZoom:(UIGestureRecognizer *)gestureRecognizer
{
    static NSIndexPath *indexPath = nil;
    static const CGFloat pinchChangeThreshold = 1.0F;
    static NSNumber *lastPinchScale = nil;

    if (gestureRecognizer.state == UIGestureRecognizerStateBegan  ||  nil == indexPath) {
        CGPoint lastPoint = [gestureRecognizer locationInView:self.collectionView];
        indexPath = [self.collectionView indexPathForItemAtPoint:lastPoint];
    }
    
    BOOL performPinchResponse = NO;
    UIPinchGestureRecognizer *pinchRecognizer = (UIPinchGestureRecognizer *)gestureRecognizer;
    if (lastPinchScale) {
        if (pinchRecognizer.scale > [lastPinchScale floatValue] + pinchChangeThreshold) {
            if (YES == self.showGridView) {
                self.showGridView = NO;
                performPinchResponse = YES;
            }
            lastPinchScale = [NSNumber numberWithFloat:pinchRecognizer.scale];
        } else if (pinchRecognizer.scale < [lastPinchScale floatValue] - pinchChangeThreshold){
            if (NO == self.showGridView) {
                self.showGridView = YES;
                performPinchResponse = YES;
            }
            lastPinchScale = [NSNumber numberWithFloat:pinchRecognizer.scale];
        }
    } else {
        lastPinchScale = [NSNumber numberWithFloat:pinchRecognizer.scale];
    }
    
    if (performPinchResponse) {
        [self.collectionView reloadData];
        [self.collectionView layoutIfNeeded];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
        indexPath = nil;

        if ([self.delegate respondsToSelector:@selector(selectPhotoCollectionViewController:didChangeViewMode:)]) {
            HPPRSelectPhotoCollectionViewMode mode;
            if (self.showGridView) {
                mode = HPPRSelectPhotoCollectionViewModeGrid;
            } else {
                mode = HPPRSelectPhotoCollectionViewModeList;
            }

            [self.delegate selectPhotoCollectionViewController:self didChangeViewMode:mode];
        }
    }
}

#pragma mark - Scroll View Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _contentOffsetStart = scrollView.contentOffset;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ((targetContentOffset->y <= _contentOffsetStart.y || targetContentOffset->y <= 0) || !self.provider.hasMoreImages) {
        return;
    }
    
    CGFloat frameHeight = scrollView.frame.size.height;
    CGFloat contentHeight = scrollView.contentSize.height;
    CGFloat verticalThreshold = frameHeight * 1.0f;
    
    if ((targetContentOffset->y + frameHeight) >= (contentHeight - verticalThreshold)) {
        [self requestImagesWithCompletion:^(NSArray *records, BOOL complete) {
            if (complete) {
                [self finishImageRequestWithRecords:records];
            }
        } andReloadAll:NO];
    }
}

#pragma mark - MCNoInternetConnectionRetryViewDelegate

- (void)noInternetConnectionRetryViewDidTapRetry:(HPPRNoInternetConnectionRetryView *)noInternetConnectionRetryView
{
    [self requestImagesWithCompletion:^(NSArray *records, BOOL complete) {
        if (complete) {
            [self finishImageRequestWithRecords:nil];
        }
    } andReloadAll:YES];
}

#pragma mark - Screen size calculations

- (CGFloat)worstCaseNumberOfPhotosPerLine
{
    NSInteger worstCollectionViewWidth = (self.collectionView.bounds.size.width > self.collectionView.bounds.size.height) ? self.collectionView.bounds.size.width : self.collectionView.bounds.size.height;
    
    NSInteger result = (NSInteger) ceil(worstCollectionViewWidth / [self worstCaseSmallerPhotoHeight]);
    
    return result;
}

- (CGFloat)worstCaseSmallerPhotoHeight
{
    if (IS_IPHONE_4 || IS_IPHONE_5) {
        return IPHONE_4_AND_5_GRID_COLLECTION_VIEW_SIZE.height;
    } else if (IS_IPHONE_6) {
        return IPHONE_6_GRID_COLLECTION_VIEW_SIZE.height;
    } else if (IS_IPHONE_6_PLUS) {
        return IPHONE_6_PLUS_GRID_COLLECTION_VIEW_SIZE.height;
    } else {
        if (IPAD_GRID_COLLECTION_VIEW_SIZE_PORTRAIT.height < IPAD_GRID_COLLECTION_VIEW_SIZE_LANDSCAPE.height) {
            return IPAD_GRID_COLLECTION_VIEW_SIZE_PORTRAIT.height;
        } else {
            return IPAD_GRID_COLLECTION_VIEW_SIZE_LANDSCAPE.height;
        }
    }
}

#pragma mark - MCSelectPhotoProviderDelegate

- (void)setProvider:(HPPRSelectPhotoProvider *)provider
{
    _provider = provider;
    _provider.delegate = self;
}

- (void)providerLostAccess
{
    // do nothing
}

- (void)providerLostConnection
{
    if (self.provider.showNetworkWarning) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            if ([self.provider imageCount] == 0) {
                [self.collectionView reloadData];
                self.collectionView.contentOffset = CGPointZero;
                self.noInternetConnectionRetryView.hidden = NO;
                self.noPhotosLabel.hidden = YES;
            } else {
                [self.noInternetConnectionMessageView show];
            }
        });
    }
}

- (void)providerAccessedPrivateAccount
{
    dispatch_async(dispatch_get_main_queue(), ^ {
        self.userAccountIsPrivateLabel.hidden = NO;
        self.collectionView.hidden = YES;
    });
}

- (NSUInteger)imagesPerScreen
{
    NSInteger worstCollectionViewHeight = (self.collectionView.bounds.size.height > self.collectionView.bounds.size.width) ? self.collectionView.bounds.size.height : self.collectionView.bounds.size.width;
    
    NSInteger result = (NSInteger) ceil(worstCollectionViewHeight / [self worstCaseSmallerPhotoHeight]);
    
    result *= [self worstCaseNumberOfPhotosPerLine];
    
    return (NSUInteger)result;
}

@end
