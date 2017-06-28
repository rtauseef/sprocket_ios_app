//
//  PGWikipediaDropdownViewController.h
//  Sprocket
//
//  Created by Fernando Caprio on 6/28/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGMetarPayoffViewController.h"


@protocol PGWikipediaDropdownViewControllerDelegate <NSObject>

- (void) didSelectArticle: (NSUInteger) pos;

@end

@interface PGWikipediaDropdownViewController : UIViewController

@property (strong, nonatomic) NSArray<NSString *> *articles;
@property (weak, nonatomic) id<PGWikipediaDropdownViewControllerDelegate> delegate;
@property (strong, nonatomic) PGMetarPayoffViewController* metarVc;

@end
