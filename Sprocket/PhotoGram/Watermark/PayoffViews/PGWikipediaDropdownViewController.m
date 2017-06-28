//
//  PGWikipediaDropdownViewController.m
//  Sprocket
//
//  Created by Fernando Caprio on 6/28/17.
//  Copyright © 2017 HP. All rights reserved.
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
