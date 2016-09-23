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

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MP.h>
#import "PGGesturesView.h"
#import "UIView+Background.h"

@interface ActionViewController ()

@property (strong, nonatomic) PGGesturesView *imageView;
@property (weak, nonatomic) IBOutlet UIView *imageContainer;
@property (weak, nonatomic) IBOutlet UIButton *printButton;

@property (strong, nonatomic) CAGradientLayer *gradient;


@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MP sharedInstance].extensionController = self;
    
    self.printButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.printButton.layer.borderWidth = 1.0f;
    self.printButton.layer.cornerRadius = 2.5f;
    
    [self addGradientBackgroundToView:self.view];
    
    BOOL imageFound = NO;
    
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                __weak ActionViewController *weakSelf = self;
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
                    if (image) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [weakSelf renderPhoto:image];
                        }];
                    }
                }];
                
                imageFound = YES;
                break;
            }
        }
        
        if (imageFound) {
            break;
        }
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.imageView.frame = self.imageContainer.bounds;
        self.imageView.scrollView.frame = self.imageContainer.bounds;
        [self.imageView adjustScrollAndImageView];
        self.gradient.frame = self.view.bounds;
        
        [self.view layoutIfNeeded];
    } completion:nil];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)addGradientBackgroundToView:(UIView *)view {
    self.gradient = [CAGradientLayer layer];
    self.gradient.frame = view.frame;
    self.gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0x1f/255.0F green:0x1f/255.0F blue:0x1f/255.0F alpha:1] CGColor], (id)[[UIColor colorWithRed:0x38/255.0F green:0x38/255.0F blue:0x38/255.0F alpha:1] CGColor], nil];
    self.gradient.startPoint = CGPointMake(0, 1);
    self.gradient.endPoint = CGPointMake(1, 0);
    [view.layer insertSublayer:self.gradient atIndex:0];
}

- (void)renderPhoto:(UIImage *)photo {
    self.imageView = [[PGGesturesView alloc] initWithFrame:self.imageContainer.bounds];
    self.imageView.image = photo;
    self.imageView.doubleTapBehavior = PGGesturesDoubleTapReset;
    
    [self.imageContainer addSubview:self.imageView];
}

- (IBAction)printTapped:(id)sender {
    [[MP sharedInstance] headlessBluetoothPrintFromController:self image:[self.imageContainer screenshotImage] animated:YES printCompletion:nil];
}

- (IBAction)done {
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

@end
