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

#import "PGTemplateSelectorView.h"
#import "PGTemplateSelectorCollectionViewCell.h"
#import "NSString+Utils.h"

@interface PGTemplateSelectorView () <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *templates;

@end


@implementation PGTemplateSelectorView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self.collectionView registerNib:[UINib nibWithNibName:@"PGTemplateSelectorCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"TemplateCell"];

        self.collectionView.accessibilityIdentifier = @"TemplateCollectionView";
        
        #ifndef APP_STORE_BUILD
            [self configureLongPress];
        #endif
    }
    
    return self;
}

- (void)setSelectedTemplate:(NSInteger)selectedTemplate
{
    _selectedTemplate = selectedTemplate;
    [self.collectionView reloadData];
}

- (void)setSource:(NSString *)source
{
    _source = source;
    self.templates = [self templatesFromPlist];
    [self.collectionView reloadData];
}

#pragma mark - Collection View Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.templates.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PGTemplateSelectorCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TemplateCell" forIndexPath:indexPath];
    
    PGTemplate *template = self.templates[indexPath.row];
    
    cell.templateTitle.text = template.name;
    cell.templateImageView.image = [UIImage imageNamed:[template pngFileName]];
    
    if (cell.photoSelectedImageView.image == nil) {
        cell.photoSelectedImageView.image = self.selectedPhoto;
    }
    
    if (self.selectedTemplate == indexPath.row) {
        cell.selectedView.layer.borderWidth = 3.0f;
        cell.templateTitle.textColor = [UIColor colorWithRed:0.0f green:150.0f/255.0f blue:214.0f/255.0f alpha:1.0f];
        self.collectionView.accessibilityValue = template.name;
    } else {
        cell.selectedView.layer.borderWidth = 0.0f;
        cell.templateTitle.textColor = [UIColor whiteColor];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    
    if (self.selectedTemplate != indexPath.row) {
        self.selectedTemplate = indexPath.row;
        [collectionView reloadData];
        
        if ([self.delegate respondsToSelector:@selector(templateSelectorView:didSelectTemplate:)]) {
            [self.delegate templateSelectorView:self didSelectTemplate:self.templates[self.selectedTemplate]];
        }
    }
}

#pragma mark - Long press

- (void)configureLongPress
{
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0f;
    lpgr.delaysTouchesBegan = YES;
    lpgr.delegate = self;
    [self.collectionView addGestureRecognizer:lpgr];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(templateSelectorViewDidLongTap:)]) {
            [self.delegate templateSelectorViewDidLongTap:self];
        }
    }
}

#pragma mark - Plist

- (NSArray *)templatesFromPlist {	
	NSArray *templatesPlist = [self.source templatesForSource];
	NSMutableArray *templates = [NSMutableArray arrayWithCapacity:templatesPlist.count];
    
    NSUInteger templatePosition = 0;
	for (NSDictionary *templateDict in templatesPlist) {
        PGTemplate *template = [[PGTemplate alloc] initWithPlistDictionary:templateDict position:templatePosition];
		[templates addObject:template];
        templatePosition++;
	}
	
	return [templates copy];
}

- (void)selectTemplateWithName:(NSString *)name
{
    NSInteger templateIndex = -1;
    for (int idx = 0; idx < self.templates.count; idx++) {
        PGTemplate *template = self.templates[idx];
        if ([template.name isEqualToString:name]) {
            templateIndex = idx;
        }
    }
    if (templateIndex >= 0) {
        self.selectedTemplate = templateIndex;
        [self layoutIfNeeded];
        NSIndexPath *templateIndexPath = [NSIndexPath indexPathForItem:templateIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:templateIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
}

@end
