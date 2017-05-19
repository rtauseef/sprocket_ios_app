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

@interface PGPayoffViewWikipediaViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

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

- (IBAction)didClickShowMoreImagesButton:(id)sender;
- (IBAction)didClickArticleDescriptionShowMore:(id)sender;

@property (assign, nonatomic) BOOL descriptionExpanded;
@property (assign, nonatomic) BOOL imagesExpanded;
@property (assign, nonatomic) int currentIndex;
@property (strong, nonatomic) NSArray *collectionImageArray;

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

@implementation PGPayoffViewWikipediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewTitle = NSLocalizedString(@"Wikipedia", nil);
    self.currentIndex = 0;
    self.collectionImageArray = [NSArray array];
    
    // page description (check and render)
    // TODO: other languages
    
    if ([self getPagesForLang:kFixedLanguage]) {
        [self renderPageAtIndex:_currentIndex withLang:kFixedLanguage];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    UILongPressGestureRecognizer *longPressWikipedia = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressWikipedia:)];
    longPressWikipedia.minimumPressDuration = kLongPressDurationForAlternative;
    [self.view addGestureRecognizer:longPressWikipedia];
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

@end
