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

#import "HPPRSegmentedControlView.h"
#import "HPPR.h"
#import "UIFont+HPPRStyle.h"
#import "UIColor+HPPRStyle.h"
#import "UIImage+HPPRMaskImage.h"

#define MASKED_IMAGE_SIZE 22.0f
#define MASKED_IMAGE_BORDER_WIDTH 1.0f

@interface HPPRSegmentedControlView ()

@property (weak, nonatomic) IBOutlet UIButton *segment1;
@property (weak, nonatomic) IBOutlet UIButton *segment2;
@property (strong, nonatomic) NSArray *segments;

@end

@implementation HPPRSegmentedControlView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.segments = @[self.segment1, self.segment2];
    
    UIImage *segment1Selected = [[UIImage imageNamed:@"HPPRFilterButtonLeftOn"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)];
    
    UIImage *segment1Unselected = [[UIImage imageNamed:@"HPPRFilterButtonLeftOff"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)];
    
    UIImage *segment2Selected = [[UIImage imageNamed:@"HPPRFilterButtonRightOn"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 6.0f)];
    
    UIImage *segment2Unselected = [[UIImage imageNamed:@"HPPRFilterButtonRightOff"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 6.0f)];
    
    self.segment1.selected = YES;
    
    [self.segment1 setBackgroundImage:segment1Selected forState:UIControlStateSelected];
    [self.segment1 setBackgroundImage:segment1Unselected forState:UIControlStateNormal];
    [self.segment1 setBackgroundImage:segment1Unselected forState:UIControlStateHighlighted];
    
    [self.segment2 setBackgroundImage:segment2Selected forState:UIControlStateSelected];
    [self.segment2 setBackgroundImage:segment2Unselected forState:UIControlStateNormal];
    [self.segment2 setBackgroundImage:segment2Unselected forState:UIControlStateHighlighted];
    
    for (UIButton *segmentButton in self.segments) {
        segmentButton.titleLabel.font = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRSecondaryLabelFont];
        [segmentButton setTintColor:[[HPPR sharedInstance].appearance.settings objectForKey:kHPPRButtonTitleColorSelected]];
        [segmentButton setTitleColor:[[HPPR sharedInstance].appearance.settings objectForKey:kHPPRButtonTitleColorSelected] forState:UIControlStateSelected];
        [segmentButton setTitleColor:[[HPPR sharedInstance].appearance.settings objectForKey:kHPPRButtonTitleColorNormal] forState:UIControlStateNormal];
    }
}

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment state:(UIControlState)state
{
    UIButton *segmentButton = self.segments[segment];
    [segmentButton setTitle:title forState:state];
    
    [self setInsetsForSegmentButton:segmentButton];
}

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment state:(UIControlState)state
{
    UIButton *segmentButton = self.segments[segment];
    [segmentButton setImage:image forState:state];
    
    [self setInsetsForSegmentButton:segmentButton];
}

- (void)setMaskedImageUrl:(NSString *)url forSegmentAtIndex:(NSUInteger)segment state:(UIControlState)state
{
    [UIImage HPPRMaskImageWithURL:url diameter:MASKED_IMAGE_SIZE borderWidth:MASKED_IMAGE_BORDER_WIDTH completion:^(UIImage *circleImage) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            UIButton *segmentButton = self.segments[segment];
            [segmentButton setImage:circleImage forState:state];
            [segmentButton setNeedsLayout];
            
            [self setInsetsForSegmentButton:segmentButton];
        });
    }];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size
{
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    //You may need to take some retina adjustments into consideration here
    CGFloat scaleFactor = (oldWidth > oldHeight) ? size.width / oldWidth : size.height / oldHeight;
    
    return [UIImage imageWithCGImage:image.CGImage scale:scaleFactor orientation:UIImageOrientationUp];
}

- (void)setInsetsForSegmentButton:(UIButton *)segmentButton
{
    if (segmentButton.titleLabel.text != nil && segmentButton.imageView.image != nil) {
        segmentButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 6.0, 0.0, 0.0);
        [segmentButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        segmentButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 6.0, 0.0, 0.0);
    }
}

# pragma mark - Button action

- (IBAction)segmentButtonTapped:(id)sender
{
    UIButton *selectedSegmentButton = sender;
    
    if (self.workAsToggleSwitch) {
        UIButton *previousSelectedButton = self.segments[self.selectedSegmentIndex];
        previousSelectedButton.selected = NO;
        
        self.selectedSegmentIndex++;
        if (self.selectedSegmentIndex >= self.segments.count) {
            self.selectedSegmentIndex = 0;
        }
        
        UIButton *currentSelectedButton = self.segments[self.selectedSegmentIndex];
        currentSelectedButton.selected = YES;
        
        if ([self.delegate respondsToSelector:@selector(segmentedControlViewDidChange:)]) {
            [self.delegate segmentedControlViewDidChange:self];
        }
    } else {
        if (self.selectedSegmentIndex != selectedSegmentButton.tag) {
            
            for (UIButton *segmentButton in self.segments) {
                segmentButton.selected = NO;
            }
            
            selectedSegmentButton.selected = YES;
            
            self.selectedSegmentIndex = selectedSegmentButton.tag;
            
            if ([self.delegate respondsToSelector:@selector(segmentedControlViewDidChange:)]) {
                [self.delegate segmentedControlViewDidChange:self];
            }
        }
    }
}

@end
