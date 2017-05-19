//
//  PGPayoffViewWikipediaViewController.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/18/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGPayoffViewWikipediaViewController.h"
#import "PGMetarPage.h"
#import "UIImageView+AFNetworking.h"
#import "PGWikipediaImageCollectionViewCell.h"
#import "PGWikipediaTableViewCell.h"
#import "PGPhotoSelection.h"
#import "HPPRMedia.h"
#import "HPPRGoogleMedia.h"
#import "PGPayoffFullScreenTmpViewController.h"
#import "PGPreviewViewController.h"

@interface PGPayoffViewWikipediaViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PGPayoffFullScreenTmpViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *articleNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *articleDescriptionTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *articleDescriptionHeightConstraint;

@property (weak, nonatomic) IBOutlet UIButton *showMoreButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showMoreHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *imagesShowMorebutton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageShowMoreButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageCollectionViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UITableView *blocksTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *blocksTableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) PGPayoffFullScreenTmpViewController* tmpViewController;

- (IBAction)didClickShowMoreImagesButton:(id)sender;
- (IBAction)didClickArticleDescriptionShowMore:(id)sender;

@property (assign, nonatomic) BOOL descriptionExpanded;
@property (assign, nonatomic) BOOL imagesExpanded;
@property (assign, nonatomic) int currentIndex;
@property (strong, nonatomic) NSArray *collectionImageArray;
@property (strong, nonatomic) NSArray *blockArray;

@end

#define kLongPressDurationForAlternative 0.6f

#define kImageCollectionGridFixedHeight 100.0
#define kShortDescriptionFixedHeight 200.0
#define kShowMoreButtonFixedHeight 30.0
#define kFixedLanguage @"en"
#define kImageGridSpacing 10.0
#define kImageGridMargin 20.0
#define kImageGridLineSpacing 10.0
#define kNumberOfImagesPerRow 3
#define kTableViewMargin 15
#define kMinimumBlockSize 75

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

    if (self.tmpViewController) {
        [self.tmpViewController.view removeFromSuperview];
        self.tmpViewController = nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self getPagesForLang:kFixedLanguage]) {
            [self renderPageAtIndex:_currentIndex withLang:kFixedLanguage];
        }
         
         [self.activityIndicator stopAnimating];
         self.scrollView.hidden = NO;
    });

}

- (void)handleLongPressWikipedia:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.currentIndex++;
        if (![self renderPageAtIndex:_currentIndex withLang:kFixedLanguage]) {
            self.currentIndex = 0;
            [self renderPageAtIndex:self.currentIndex withLang:kFixedLanguage];
        }
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
    if ([self getPagesForLang:kFixedLanguage]) {
        return YES;
    }
    
    return NO;
}

- (NSArray *) getPagesForLang: (NSString *) lang {
    if (self.metadata.location.content.wikipedia.pages && [self.metadata.location.content.wikipedia.pages isKindOfClass:[NSDictionary class]]) {
        return [self.metadata.location.content.wikipedia.pages objectForKey:lang];
    }
    
    return nil;
}

- (BOOL) renderPageAtIndex: (int) index withLang:(NSString *) lang {
    if (self.metadata != nil) {
        NSArray *enPages = [self getPagesForLang:lang];
        
        if (enPages != nil) {
            
            if (index < [enPages count]) {
                PGMetarPage *page = [enPages objectAtIndex:index];
                self.descriptionExpanded = NO;
                self.articleNameLabel.text = page.title;
                self.articleDescriptionTextView.text = page.text;
                
                // Article Description
                [self.showMoreButton setTitle:NSLocalizedString(@"Show more",nil) forState:UIControlStateNormal];
                self.descriptionExpanded = NO;
                CGRect newFrame = self.articleDescriptionTextView.frame;
                newFrame.size.height = kShortDescriptionFixedHeight;
                
                CGFloat fixedWidth = self.articleDescriptionTextView.frame.size.width;
                CGSize newSize = [self.articleDescriptionTextView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
                
                if (newSize.height <= kShortDescriptionFixedHeight) {
                    self.showMoreButton.hidden = YES;
                    self.showMoreHeightConstraint.constant = 0;
                    self.articleDescriptionHeightConstraint.constant = newSize.height;
                } else {
                    self.showMoreButton.hidden = NO;
                    self.showMoreHeightConstraint.constant = kShowMoreButtonFixedHeight;
                    self.articleDescriptionHeightConstraint.constant = kShortDescriptionFixedHeight;
                }
                
                [self.articleDescriptionTextView setNeedsLayout];
                
                // Article Images
                self.imagesExpanded = NO;
                
                if (page.images && [page.images count] > 0) {
                    self.collectionImageArray = page.images;
                    self.imagesCollectionView.hidden = NO;
                    self.imageCollectionViewHeightConstraint.constant = kImageCollectionGridFixedHeight;
                    
                    int numberOfLines = ceil([self.collectionImageArray count] / kNumberOfImagesPerRow);
                    if (numberOfLines > 1) {
                        self.imagesShowMorebutton.hidden = NO;
                        self.imageShowMoreButtonHeightConstraint.constant = kShowMoreButtonFixedHeight;
                    } else {
                        self.imageShowMoreButtonHeightConstraint.constant = 0;
                        self.imagesShowMorebutton.hidden = YES;
                    }
                    
                    [self.imagesCollectionView reloadData];
                } else {
                    self.imagesCollectionView.hidden = YES;
                    self.imageCollectionViewHeightConstraint.constant = 0;
                    self.imagesShowMorebutton.hidden = YES;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect oldFrame = self.blocksTableView.frame;
    oldFrame.size.height = self.blocksTableView.contentSize.height;
    self.blocksTableView.frame = oldFrame;
    
    self.blocksTableViewHeightConstraint.constant = self.blocksTableView.contentSize.height;

    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.endLabel.frame.origin.y);
}

- (IBAction)didClickShowMoreImagesButton:(id)sender {
    CGRect newFrame = self.imagesCollectionView.frame;
    
    if (self.imagesExpanded) {
        self.imagesExpanded = NO;
        [self.imagesShowMorebutton setTitle:NSLocalizedString(@"Show More",nil) forState:UIControlStateNormal];
        newFrame.size.height = kImageCollectionGridFixedHeight;
        self.imagesCollectionView.frame = newFrame;
        self.imageCollectionViewHeightConstraint.constant = kImageCollectionGridFixedHeight;
    } else {
        [self.imagesShowMorebutton setTitle:NSLocalizedString(@"Show Less",nil) forState:UIControlStateNormal];
        self.imagesExpanded = YES;
        int numberOfLines = ceil([self.collectionImageArray count] / kNumberOfImagesPerRow);
        float height = [self getImageSize] * numberOfLines + (kImageGridLineSpacing * (numberOfLines - 1));
        newFrame.size.height = height;
        self.imagesCollectionView.frame = newFrame;
        self.imageCollectionViewHeightConstraint.constant = height;
    }
    
    [self.imagesCollectionView setNeedsLayout];
}

- (IBAction)didClickArticleDescriptionShowMore:(id)sender {
    CGFloat fixedWidth = self.articleDescriptionTextView.frame.size.width;
    CGSize newSize = [self.articleDescriptionTextView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = self.articleDescriptionTextView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);

    if (self.descriptionExpanded) {
        [self.showMoreButton setTitle:NSLocalizedString(@"Show more",nil) forState:UIControlStateNormal];
        self.descriptionExpanded = NO;
        CGRect newFrame = self.articleDescriptionTextView.frame;
        newFrame.size.height = kShortDescriptionFixedHeight;
        
        if (newSize.height <= kShortDescriptionFixedHeight) {
            self.articleDescriptionHeightConstraint.constant = newSize.height;
        } else {
            self.articleDescriptionHeightConstraint.constant = kShortDescriptionFixedHeight;
        }
    } else {
        [self.showMoreButton setTitle:NSLocalizedString(@"Show less",nil) forState:UIControlStateNormal];
        self.descriptionExpanded =  YES;
        self.articleDescriptionTextView.frame = newFrame;
        
        self.articleDescriptionHeightConstraint.constant = newSize.height;
    }
    [self.articleDescriptionTextView setNeedsLayout];
}

- (int) getImageSize {
    return (self.view.bounds.size.width / kNumberOfImagesPerRow) - kImageGridSpacing * (kNumberOfImagesPerRow - 1) - kImageGridMargin * 2;
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
        NSDictionary *currentUrl = [self.collectionImageArray objectAtIndex:indexPath.row];
        [cell.imageView setImageWithURL:[NSURL URLWithString:[currentUrl objectForKey:@"thumb"]]];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int calcSize = [self getImageSize];
    
    return CGSizeMake(calcSize,calcSize);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, kImageGridMargin, 0, kImageGridMargin);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kImageGridLineSpacing;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *currentUrl = [self.collectionImageArray objectAtIndex:indexPath.row];
    
    NSString *originalUrl = [currentUrl objectForKey:@"original"];
    
    if (originalUrl) {
        HPPRMedia *media = [[HPPRMedia alloc] init];
        media.thumbnailUrl = [currentUrl objectForKey:@"thumb"];
        media.standardUrl = [currentUrl objectForKey:@"original"];
        
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
    
    /*NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0]};

    CGRect newSize = [currentBlock.text boundingRectWithSize:CGSizeMake(cell.textView.frame.size.width
                                                                        , CGFLOAT_MAX)
                                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                           attributes:attributes
                                              context:nil];*/
    
    UITextView *view=[[UITextView alloc] initWithFrame:CGRectMake(0, 0, cell.textView.frame.size.width, 10)];
    view.font = [UIFont systemFontOfSize:14.0];
    view.text=currentBlock.text;
    CGSize size=[view sizeThatFits:CGSizeMake([[UIScreen mainScreen]bounds].size.width - 16, CGFLOAT_MAX)];
    

    float calcSize = ceil(size.height + cell.textView.frame.origin.y + kTableViewMargin);

    //return calcSize > kMinimumBlockSize? calcSize : kMinimumBlockSize;
    
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
    [self.tmpViewController.view removeFromSuperview];
    self.tmpViewController = nil;
}

@end
