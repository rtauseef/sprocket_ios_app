//
//  PGMediaNavigation.h
//  Sprocket
//
//  Created by Susy Snowflake on 6/30/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGView.h"

@protocol PGMediaNavigationDelegate;

@interface PGMediaNavigation : PGView

@property (weak, nonatomic) id<PGMediaNavigationDelegate> delegate;

-(void)setScrollProgress:(UIScrollView *)scrollView progress:(CGFloat)progress forPage:(NSInteger)page;
-(void)selectButton:(NSString *)title animated:(BOOL)animated;

@end

@protocol PGMediaNavigationDelegate <NSObject>

- (void)mediaNavigationDidPressMenuButton:(PGMediaNavigation *)mediaNav;
- (void)mediaNavigationDidPressFolderButton:(PGMediaNavigation *)mediaNav;

@end