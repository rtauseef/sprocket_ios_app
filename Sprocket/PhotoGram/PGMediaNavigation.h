//
//  PGMediaNavigation.h
//  Sprocket
//
//  Created by Susy Snowflake on 6/30/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGView.h"

@interface PGMediaNavigation : PGView

-(void)setScrollProgress:(UIScrollView *)scrollView progress:(CGFloat)progress forPage:(NSInteger)page;
-(void)selectButton:(NSString *)title animated:(BOOL)animated;

@end
