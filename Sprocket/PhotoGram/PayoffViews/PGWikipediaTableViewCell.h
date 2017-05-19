//
//  PGWikipediaTableViewCell.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/19/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGWikipediaTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *blockTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end
