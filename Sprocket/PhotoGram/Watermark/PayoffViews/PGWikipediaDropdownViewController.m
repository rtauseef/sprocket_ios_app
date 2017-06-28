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

#import "PGWikipediaDropdownViewController.h"
#import "PGWikipediaDropdownTableViewCell.h"
#import "UIFont+HPPRStyle.h"
#import "PGMetarPayoffViewController.h"

@interface PGWikipediaDropdownViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PGWikipediaDropdownViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.articles = [NSArray array];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.articles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PGWikipediaDropdownTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"wikipediaCell"];

    if (cell) {
        cell.backgroundColor = [UIColor clearColor];
        cell.articleNameLabel.text = [self.articles objectAtIndex:indexPath.row];
        cell.articleNameLabel.font = [UIFont HPPRSimplifiedLightFontWithSize:22.0];
        cell.articleNameLabel.textColor = [UIColor whiteColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(didSelectArticle:)]) {
        [self.delegate didSelectArticle:indexPath.row];
    }
    
    if (self.metarVc) {
        [self.metarVc tapDropDownButton:self];
    }
}

@end
