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
@property (strong, nonatomic) IBOutlet UIView *imageContainer;

@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MP sharedInstance].extensionController = self;
    
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
