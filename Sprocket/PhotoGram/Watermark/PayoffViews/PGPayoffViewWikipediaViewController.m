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

#import "PGPayoffViewWikipediaViewController.h"
#import "PGMetarPage.h"
#import "UIImageView+AFNetworking.h"
#import "PGWikipediaImageCollectionViewCell.h"
#import "PGWikipediaTableViewCell.h"
#import "PGPhotoSelection.h"
#import "HPPRWikipediaMedia.h"
#import "PGPayoffFullScreenTmpViewController.h"
#import "PGPreviewViewController.h"

@interface PGPayoffViewWikipediaViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PGPayoffFullScreenTmpViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *articleNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *articleDescriptionTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *articleDescriptionHeightConstraint;

@property (weak, nonatomic) IBOutlet UIButton *showMoreButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showMoreHeightConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *imagesShowMorebutton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageShowMoreButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITableView *blocksTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *blocksTableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *scrollViewInnerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *galleryGradientView;

@property (strong, nonatomic) PGPayoffFullScreenTmpViewController* tmpViewController;

- (IBAction)didClickShowMoreImagesButton:(id)sender;
- (IBAction)didClickArticleDescriptionShowMore:(id)sender;

@property (assign, nonatomic) BOOL descriptionExpanded;
@property (assign, nonatomic) BOOL imagesExpanded;
@property (assign, nonatomic) NSInteger currentIndex;
@property (strong, nonatomic) NSArray *collectionImageArray;
@property (strong, nonatomic) NSArray *blockArray;
@property (strong, nonatomic) PGMetarPage *currentPage;

@end

static const CGFloat kLongPressDurationForAlternative = 0.6f;
static const CGFloat kShortDescriptionFixedHeight = 200.0;
static const CGFloat kShowMoreButtonFixedHeight = 28.0;
static const CGFloat kImageGridSpacing = 3.0;
static const CGFloat kImageGridMargin = 3.0;
static const CGFloat kImageGridLineSpacing = 3.0;
static const NSInteger kNumberOfImagesPerRow = 3;
static const CGFloat kTableViewMargin = 15;

@implementation PGPayoffViewWikipediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewTitle = NSLocalizedString(@"Wikipedia", nil);
    self.currentIndex = 0;
    self.collectionImageArray = [NSArray array];
    self.blockArray = [NSArray array];
    
    // page description (check and render)
    // TODO: other languages
    
    self.blocksTableView.backgroundView = nil;
    self.blocksTableView.backgroundColor = [UIColor clearColor];
    self.scrollView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    self.scrollView.hidden = YES;

    self.collectionImageArray = [NSArray array];
    self.blockArray = [NSArray array];
    
    [self.activityIndicator startAnimating];
    
    UILongPressGestureRecognizer *longPressWikipedia = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressWikipedia:)];
    longPressWikipedia.minimumPressDuration = kLongPressDurationForAlternative;
    [self.view addGestureRecognizer:longPressWikipedia];

    self.contentViewHeightConstraint.constant = self.view.frame.size.height;
    
    if (self.tmpViewController) {
        [self.tmpViewController.view removeFromSuperview];
        self.tmpViewController = nil;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self renderPageAtIndex:_currentIndex];
        [self.activityIndicator stopAnimating];
        self.scrollView.hidden = NO;
    });

    [self.parentVc setExternalLinkURL:[self getURLForIndex:self.currentIndex]];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.galleryGradientView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id) [[UIColor blackColor] CGColor], nil];
    [self.galleryGradientView.layer insertSublayer:gradient atIndex:0];
}

- (void)handleLongPressWikipedia:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.currentIndex++;
        if (![self renderPageAtIndex:self.currentIndex]) {
            self.currentIndex = 0;
            [self renderPageAtIndex:self.currentIndex];
        }
        [self.parentVc setExternalLinkURL:[self getURLForIndex:self.currentIndex]];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {

    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if ([[self.view gestureRecognizers] count] > 0) {
        [self.view removeGestureRecognizer:[[self.view gestureRecognizers] firstObject]];
    }
}

- (BOOL) metadataValidForCurrentLang {
    if (self.metadata.location.content.wikipedia.pages) {
        return YES;
    }
    
    return NO;
}


- (NSURL *) getURLForIndex: (NSInteger) index {
    if (self.metadata != nil) {
        NSArray *pages = self.metadata.location.content.wikipedia.pages;
        
        if (pages != nil && [pages objectAtIndex:index] != nil) {
            PGMetarPage *page = pages[index];
            
            if (page.from) {
                return [NSURL URLWithString:page.from];
            }
        }
    }
    
    return nil;
}

- (NSArray <NSString *>*)pageTitlesArray {
    NSMutableArray *titleArray = [NSMutableArray array];
    
    if (self.metadata != nil && self.metadata.location.content.wikipedia.pages) {
        for (PGMetarPage *page in self.metadata.location.content.wikipedia.pages) {
            [titleArray addObject:page.title];
        }
    }
    
    return titleArray;
}

- (BOOL) renderPageAtIndex: (NSInteger) index {
    if (self.metadata != nil) {
        NSArray *pages = self.metadata.location.content.wikipedia.pages;
        
        if (pages != nil) {
            
            if (index < [pages count]) {
                PGMetarPage *page = [pages objectAtIndex:index];
                self.currentPage = page;
                self.descriptionExpanded = NO;
                self.articleNameLabel.text = page.title;
                self.articleDescriptionTextView.text = page.text;
                
                // Article Description
                self.descriptionExpanded = NO;
                CGRect newFrame = self.articleDescriptionTextView.frame;
                newFrame.size.height = kShortDescriptionFixedHeight;
                
                CGFloat fixedWidth = self.articleDescriptionTextView.frame.size.width;
                CGSize newSize = [self.articleDescriptionTextView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
                
                if (newSize.height <= kShortDescriptionFixedHeight) {
                    self.showMoreHeightConstraint.constant = 0;
                    self.articleDescriptionHeightConstraint.constant = newSize.height;
                } else {
                    self.showMoreHeightConstraint.constant = kShowMoreButtonFixedHeight;
                    self.articleDescriptionHeightConstraint.constant = kShortDescriptionFixedHeight;
                }
                
                [self.articleDescriptionTextView setNeedsLayout];
                
                // Article Images
                self.imagesExpanded = NO;
                
                if (page.images && [page.images count] > 0) {
                    self.collectionImageArray = page.images;
                    self.imagesCollectionView.hidden = NO;
                    self.imageCollectionViewHeightConstraint.constant = [self getImageSize] + kImageGridSpacing;
                    [self compactImageGallery];
                    [self.imagesCollectionView reloadData];
                } else {
                    self.imagesCollectionView.hidden = YES;
                    self.imageCollectionViewHeightConstraint.constant = 0;
                    self.imageShowMoreButtonHeightConstraint.constant = 0;
                }
                
                // Blocks
                
                if (page.blocks && [page.blocks count] > 0) {
                    self.blocksTableView.hidden = NO;
                    self.blockArray = page.blocks;
                    [self.blocksTableView reloadData];
                } else {
                    self.blocksTableView.hidden = YES;
                    self.blocksTableViewHeightConstraint.constant = 0;
                    self.blockArray = [NSArray array];
                    [self.blocksTableView reloadData];
                }

                return YES;
            }
        }
    }

    return NO;
}

- (void)compactImageGallery {
    int numberOfLines = ceil((float) [self.collectionImageArray count] / (float) kNumberOfImagesPerRow);
    
    if (numberOfLines >= 2) {
        CGRect imageGalleryFrame = self.imagesCollectionView.frame;
        float height = [self getImageSize] * 2 + (kImageGridLineSpacing);
        imageGalleryFrame.size.height = height;
        self.imagesCollectionView.frame = imageGalleryFrame;
        
        if (numberOfLines == 2) {
            self.imageCollectionViewHeightConstraint.constant = 0;
            self.galleryGradientView.hidden = YES;
        } else {
            self.imageCollectionViewHeightConstraint.constant = height;
            self.galleryGradientView.hidden = NO;
            self.imageShowMoreButtonHeightConstraint.constant = kShowMoreButtonFixedHeight;
        }
    } else if (numberOfLines == 1) {
        self.imageShowMoreButtonHeightConstraint.constant = 0;
        self.galleryGradientView.hidden = YES;
    } else {
        self.imageShowMoreButtonHeightConstraint.constant = 0;
        self.galleryGradientView.hidden = YES;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect oldFrame = self.blocksTableView.frame;
    oldFrame.size.height = self.blocksTableView.contentSize.height;
    self.blocksTableView.frame = oldFrame;
    
    self.blocksTableViewHeightConstraint.constant = self.blocksTableView.contentSize.height;

    CGFloat endPos = self.blocksTableView.contentSize.height + self.blocksTableView.frame.origin.y + kTableViewMargin;
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, endPos);
    self.contentViewHeightConstraint.constant = endPos;
}

- (IBAction)didClickShowMoreImagesButton:(id)sender {
    CGRect newFrame = self.imagesCollectionView.frame;
    
    if (self.imagesExpanded) {
        self.imagesExpanded = NO;
        [self compactImageGallery];
    } else {
        self.imagesExpanded = YES;
        int numberOfLines = ceil((float) [self.collectionImageArray count] / (float) kNumberOfImagesPerRow);
        float height = [self getImageSize] * numberOfLines + (kImageGridLineSpacing * (numberOfLines - 1));
        newFrame.size.height = height;
        self.imagesCollectionView.frame = newFrame;
        self.imageCollectionViewHeightConstraint.constant = height;
        self.galleryGradientView.hidden = YES;
    }
    
    [self.imagesCollectionView setNeedsLayout];
}

- (IBAction)didClickArticleDescriptionShowMore:(id)sender {
    CGFloat fixedWidth = self.articleDescriptionTextView.frame.size.width;
    CGSize newSize = [self.articleDescriptionTextView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = self.articleDescriptionTextView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);

    if (self.descriptionExpanded) {
        self.descriptionExpanded = NO;
        CGRect newFrame = self.articleDescriptionTextView.frame;
        newFrame.size.height = kShortDescriptionFixedHeight;
        
        if (newSize.height <= kShortDescriptionFixedHeight) {
            self.articleDescriptionHeightConstraint.constant = newSize.height;
        } else {
            self.articleDescriptionHeightConstraint.constant = kShortDescriptionFixedHeight;
        }
    } else {
        self.descriptionExpanded =  YES;
        self.articleDescriptionTextView.frame = newFrame;
        
        self.articleDescriptionHeightConstraint.constant = newSize.height;
    }
    
    [self.articleDescriptionTextView setNeedsLayout];
}

- (CGFloat) getImageSize {
    CGFloat imageSize = floorf((self.imagesCollectionView.bounds.size.width - (kImageGridSpacing * (kNumberOfImagesPerRow - 1)) - (kImageGridMargin * 2))/kNumberOfImagesPerRow);
    return imageSize;
}

#pragma mark UICollectionView delegate and data source (image section)


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.collectionImageArray count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PGWikipediaImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"wikipediaCell" forIndexPath:indexPath];

    if (cell != nil) {
        cell.backgroundColor = [UIColor clearColor];
        PGMetarIcon *currentIcon = [self.collectionImageArray objectAtIndex:indexPath.row];
        [cell.imageView setImageWithURL:[NSURL URLWithString:currentIcon.thumb]];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat calcSize = [self getImageSize];

    return CGSizeMake(calcSize,calcSize);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, kImageGridMargin, 0, kImageGridMargin);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kImageGridLineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return kImageGridLineSpacing;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PGMetarIcon *currentImage = [self.collectionImageArray objectAtIndex:indexPath.row];
    
    NSString *originalUrl = currentImage.original;;
    
    if (originalUrl) {
        HPPRWikipediaMedia *media = [[HPPRWikipediaMedia alloc] init];
        media.thumbnailUrl = currentImage.thumb;
        media.standardUrl = currentImage.original;
        
        if (self.currentPage.location && CLLocationCoordinate2DIsValid(self.currentPage.location.geo)) {
            media.location = [[CLLocation alloc] initWithLatitude:self.currentPage.location.geo.latitude longitude:self.currentPage.location.geo.longitude];
        }
        
        [[PGPhotoSelection sharedInstance] selectMedia:media];
        self.tmpViewController = [[PGPayoffFullScreenTmpViewController alloc] init];
        self.tmpViewController.view.frame = self.view.bounds;
        [self.view addSubview:_tmpViewController.view];
        [PGPreviewViewController presentPreviewPhotoFrom:_tmpViewController andSource:@"wikipedia" animated:YES];
        self.tmpViewController.delegate = self;
    }
}

#pragma mark UITableView delegate and data source (block section)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section{
    return [self.blockArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PGWikipediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"blockCell"];
    
    PGMetarBlock *currentBlock = [self.blockArray objectAtIndex:indexPath.row];
    if (cell) {
        cell.backgroundColor = [UIColor clearColor];
        cell.textView.text = currentBlock.text;
        cell.blockTitleLabel.text = currentBlock.title;
        cell.blockTitleLabel.textColor = [UIColor whiteColor];
        
        NSLog(@"Title: %@ \n Text: %@\n",currentBlock.title, currentBlock.text);
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PGWikipediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"blockCell"];
    
    PGMetarBlock *currentBlock = [self.blockArray objectAtIndex:indexPath.row];
    
    UITextView *view=[[UITextView alloc] initWithFrame:CGRectMake(0, 0, cell.textView.frame.size.width, 10)];
    view.font = [UIFont systemFontOfSize:14.0];
    view.text=currentBlock.text;
    CGSize size=[view sizeThatFits:CGSizeMake([[UIScreen mainScreen]bounds].size.width - 16, CGFLOAT_MAX)];
    

    float calcSize = ceil(size.height + cell.textView.frame.origin.y + kTableViewMargin);
    
    return calcSize;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section{
    return 0;
}

#pragma mark Temp View Controller Delegate

//TODO: I don't like this, need to revisit - it's a hack because the preview controller is messing up with the current view controller frame

-(void)tmpViewIsBack {
    [self.tmpViewController dismissViewControllerAnimated:NO completion:^{
        self.tmpViewController = nil;
    }];
}

#pragma mark PGWikipediaDropdownViewControllerDelegate delegate

- (void)didSelectArticle:(NSUInteger)pos {
    [self renderPageAtIndex:pos];
}

@end
