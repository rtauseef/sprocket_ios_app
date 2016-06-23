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

#import <HPPRCacheService.h>
#import <DBChooser/DBChooser.h>
#import <ZipArchive.h>
#import <Crashlytics/Crashlytics.h>
#import <MP.h>
#import <MPPrintActivity.h>
#import <HPPRReachability.h>
#import "PGSelectTemplateViewController.h"
#import "PGTemplateSelectorView.h"
#import "PGSaveToCameraRollActivity.h"
#import "PGSVGLoader.h"
#import "PGAnalyticsManager.h"
#import "UIColor+Style.h"
#import "UIFont+Style.h"
#import "UIView+Animations.h"
#import "UIView+Background.h"
#import "UITextView+Additions.h"
#import "NSString+Utils.h"
#import "UIViewController+Trackable.h"
#import "PGLogger.h"
#import "MPPrintItemFactory.h"
#import "MPLayoutFactory.h"
#import "PGSVGResourceManager.h"
#import "PGExperimentManager.h"
#import "PGAppAppearance.h"

#define STATUS_BAR_HEIGHT 22.0f

#define IPHONE_PORTRAIT_KEYBOARD_HEIGHT 216.0f
#define IPHONE_KEYBOARD_HEIGHT IPHONE_PORTRAIT_KEYBOARD_HEIGHT

#define MIN_DISTANCE_TEMPLATE_KEYBOARD 25.0f // total spitball
#define ZOOMED_TEXTFIELD_POSITION .75f       // total spitball

#define IPAD_PORTRAIT_KEYBOARD_HEIGHT 264.0f
#define IPAD_LANDSCAPE_KEYBOARD_HEIGHT 352.0f
#define IPAD_KEYBOARD_HEIGHT ((IS_PORTRAIT) ? IPAD_PORTRAIT_KEYBOARD_HEIGHT : IPAD_LANDSCAPE_KEYBOARD_HEIGHT)

#define KEYBOARD_HEIGHT (IS_IPHONE ? IPHONE_KEYBOARD_HEIGHT : IPAD_KEYBOARD_HEIGHT)

#define kCustomLocationButtonLabel NSLocalizedString(@"Custom...", @"Option to customize the location")
#define kScreenshotErrorTitle NSLocalizedString(@"Oops!", nil)
#define kScreenshotErrorMessage NSLocalizedString(@"An error occurred when sharing the item.", nil)
#define kRetryButtonTitle NSLocalizedString(@"Retry", nil)


NSString * const kSettingShowEditingCoachMarks     = @"SettingShowEditingCoachMarks";
NSString * const kSettingShowPrintQCoachMarks      = @"SettingShowPrintQCoachMarks";
float      const kCoachMarkAnimationDuration       = COACH_MARK_ANIMATION_DURATION;
float      const kEditingCoachMarkHorizontalOffset = 26.0f;
NSString * const kCoordinateDisplayFormat = @"%.3f, %.3f";
NSString * const kCoordinateStorageFormat = @"%.6f";
NSString * const kLocationBusyLabel = @"...";

NSString * const kMetricsPhotoLocationEditedKey = @"photo_location_edited";
NSString * const kMetricsPhotoLatitudeKey = @"photo_latitude";
NSString * const kMetricsPhotoLongitudeKey = @"photo_longitude";
NSString * const kMetricsNoLocation = @"No Location";
NSString * const kMetricsYesValue = @"Yes";
NSString * const kMetricsNoValue = @"No";

NSInteger const screenshotErrorAlertViewTag = 100;

NSString * const kTemplateNameKey = @"kTemplateNameKey";
NSString * const kTemplateTextKey = @"kTemplateTextKey";
NSString * const kTemplateMediaKey = @"kTemplateMediaKey";

CGFloat const kMCPrintQCoachArrowVerticalOffset = 2.0f;
CGFloat const kMCPrintQCoachArrowHorizontalOffset = 8.0f;
CGFloat const kMCPrintQCoachArrowIconSpacing = 50.0f;

BOOL firstTimeViewedSinceAppStarted = TRUE;

@interface PGSelectTemplateViewController () <PGTemplateSelectorViewDelegate, PGSVGLoaderDelegate, MPPrintDelegate, MPPrintDataSource, MPAddPrintLaterDelegate, UIPopoverPresentationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet PGTemplateSelectorView *templateSelectorView;
@property (weak, nonatomic) IBOutlet UIScrollView *containerView;
@property (strong, nonatomic) PGSVGLoader *svgLoader;
@property (strong, nonatomic, readonly) UIBarButtonItem *doneButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareButtonItem;
@property (strong, nonatomic) UIBarButtonItem *printBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *printLaterBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *cancelBarButtonItem;
@property (strong, nonatomic) UITextView *currentTextViewInEdition;
@property (strong, nonatomic) PGTemplate *currentTemplate;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) UIPopoverController *popover;
@property (assign, nonatomic) BOOL isZooming;
@property (weak, nonatomic) IBOutlet UIImageView *editingCoachView;
@property (weak, nonatomic) IBOutlet UILabel *editingCoachLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sharingCoachView;
@property (weak, nonatomic) IBOutlet UILabel *sharingCoachLabel;
@property (weak, nonatomic) IBOutlet UIImageView *printQCoachView;
@property (weak, nonatomic) IBOutlet UILabel *printQCoachLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editingHorizontalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editingVerticalConstraint;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (nonatomic) CGAffineTransform originalTransform;
@property (assign, nonatomic) NSRange selectedTextRange;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (assign, nonatomic) BOOL photoLocationEdited;
@property (strong, nonatomic) NSString *locationName;
@property (assign, nonatomic) BOOL returningFromShareActivity;
@property (strong, nonatomic) HPPRReachability *wifiReachability;
@property (strong, nonatomic) MPPrintItem *printItem;
@property (strong, nonatomic) MPPrintLaterJob *printLaterJob;
@property (strong, nonatomic) UIView *falseFront;

@end

@implementation PGSelectTemplateViewController

@synthesize doneButtonItem = _doneButtonItem;

#pragma mark - Init methods

- (void)initSvgLoaderWithPhoto:(UIImage *)photo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastTemplateName = [defaults stringForKey:kTemplateNameKey];
    
    NSArray *templatesPlist = [self.source templatesForSource];
    NSDictionary *defaultTemplateDict = templatesPlist[0];
    NSUInteger templatePosition = 0;
    NSUInteger positionIndex = 0;
    for (NSDictionary *templateDict in templatesPlist) {
        if ([[templateDict objectForKey:@"Name"] isEqualToString:lastTemplateName] || lastTemplateName == nil) {
            defaultTemplateDict = templateDict;
            lastTemplateName = [templateDict objectForKey:@"Name"];
            templatePosition = positionIndex;
        }
        positionIndex++;
    }
    
    self.currentTemplate = [[PGTemplate alloc] initWithPlistDictionary:defaultTemplateDict position:templatePosition];
    
    [PGAnalyticsManager sharedManager].templateName = self.currentTemplate.name;
    [PGAnalyticsManager sharedManager].templatePosition = [NSString stringWithFormat:@"%ld", (long)self.currentTemplate.position];
    
    self.svgLoader = [[PGSVGLoader alloc] init];
    self.svgLoader.textPrompt = NSLocalizedString(@"Enter Text", nil);
    
    [self.svgLoader setPhoto:photo media:self.media containerView:self.containerView delegate:self];
    self.svgLoader.source = self.source;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackableScreenName = @"Select Template Screen";
    
    self.isZooming = FALSE;
    
    [self initSvgLoaderWithPhoto:self.selectedPhoto];
    
    self.templateSelectorView.source = self.source;
    self.templateSelectorView.selectedPhoto = self.selectedPhoto;
    self.templateSelectorView.delegate = self;

    [self restoreTemplateState];

    self.editingCoachLabel.font = [UIFont HPCoachMarkLabelFont];
    self.editingCoachLabel.accessibilityIdentifier = @"EditingCoachLabel";
    
    self.editingCoachView.image = [[UIImage imageNamed:@"CoachMarkDown"] resizableImageWithCapInsets:UIEdgeInsetsMake(25.0f, 20.0f, 40.0f, 40.0f)];
    self.editingCoachView.accessibilityIdentifier = @"EditingCoachView";
    
    self.sharingCoachLabel.font = [UIFont HPCoachMarkLabelFont];
    self.sharingCoachLabel.accessibilityIdentifier = @"SharingCoachLabel";
    
    self.sharingCoachView.image = [[UIImage imageNamed:@"CoachMarkUp"] resizableImageWithCapInsets:UIEdgeInsetsMake(25.0f, 20.0f, 40.0f, 40.0f)];
    self.sharingCoachView.accessibilityIdentifier = @"SharingCoachView";
    
    self.printQCoachLabel.font = [UIFont HPCoachMarkLabelFont];
    self.printQCoachLabel.accessibilityIdentifier = @"PrintQCoachLabel";
    self.printQCoachView.accessibilityIdentifier = @"PrintQCoachView";
    self.printQCoachView.image = [[UIImage imageNamed:@"CoachMarkNone"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0f, 50.0f, 10.0f, 50.0f)];
    UIImageView *arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CoachMarkArrow"]];
    CGFloat xLocation = self.printQCoachView.frame.size.width - arrowView.frame.size.width - kMCPrintQCoachArrowHorizontalOffset;
    xLocation -= kMCPrintQCoachArrowIconSpacing;

    arrowView.frame = CGRectMake(xLocation, kMCPrintQCoachArrowVerticalOffset, arrowView.frame.size.width, arrowView.frame.size.height);
    [self.printQCoachView addSubview:arrowView];
    
    self.overlayView.accessibilityIdentifier = @"OverlayView";
    
    [PGAnalyticsManager sharedManager].photoSource = self.source;
    
    self.path = [[NSBundle mainBundle]resourcePath];
    [self.svgLoader loadFile:[NSString stringWithFormat:@"%@.svg", [self.currentTemplate fileNameForPaperSize:MPPaperSize4x5]] path:self.path reloadGestureImageView:YES withCompletion:nil];
    
    self.returningFromShareActivity = FALSE;

    [self preparePrintBarButtonItems];
    
    self.wifiReachability = [HPPRReachability reachabilityForLocalWiFi];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // don't show coach marks when returning from a share activity
    if( !self.returningFromShareActivity ) {
        if (![self editingCoachMarksHaveBeenShown]) {
            [self setCoachMarksVisible:YES withDuration:kCoachMarkAnimationDuration];
        } else if([self printQCoachMarksShouldBeShown]) {
            [self setPrintQCoachMarksVisible:YES withDuration:kCoachMarkAnimationDuration];
        }
    }
    
    [self retrievePlaceInfo];
    
    if( firstTimeViewedSinceAppStarted ) {
        [self.svgLoader showcaseZoomAndRotate:0.6f rotationRadians:-0.5f zoomScale:1.3f];
        firstTimeViewedSinceAppStarted = FALSE;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifiConnectionStatusChanged:) name:kHPPRReachabilityChangedNotification object:nil];
    [self.wifiReachability startNotifier];

}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        // Back button was pressed.  We know this is true because self is no longer in the navigation stack.
        [[NSNotificationCenter defaultCenter] postNotificationName:ENABLE_PAGE_CONTROLLER_FUNCTIONALITY_NOTIFICATION object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHPPRReachabilityChangedNotification object:nil];
    [self.wifiReachability stopNotifier];

    [super viewWillDisappear:animated];
    self.svgLoader.pageIsActive = FALSE;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (![self editingCoachMarksHaveBeenShown]) {
        [self setCoachMarksVisible:NO withDuration:0.0f];
    }
    
    if( self.isZooming ) {
        [self.view endEditing:YES];
        self.selectedTextRange = self.currentTextViewInEdition.selectedRange;
    }
    
    [self.svgLoader loadFile:[NSString stringWithFormat:@"%@.svg", [self.currentTemplate fileNameForPaperSize:MPPaperSize4x5]] path:self.path reloadGestureImageView:NO withCompletion:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (![self editingCoachMarksHaveBeenShown]) {
        [self setCoachMarksVisible:YES withDuration:kCoachMarkAnimationDuration];
    }
    
    if( self.isZooming ) {
        [self.svgLoader forceEditing:self.selectedTextRange];
    }
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (self.navigationController.view.frame.origin.y != 0) {
        CGRect rectSelf = self.view.frame;
        rectSelf.origin.y = STATUS_BAR_HEIGHT + self.navigationController.navigationBar.frame.size.height;
        rectSelf.size.height = self.navigationController.view.frame.size.height - rectSelf.origin.y;
        self.view.frame = rectSelf;
        
        
        CGRect rectNav = self.navigationController.view.frame;
        rectNav.origin.y = 0;
        self.navigationController.view.frame = rectNav;
    }
}

- (void)setSelectedPhoto:(UIImage *)selectedPhoto
{
    _selectedPhoto = selectedPhoto;
    self.photoLocationEdited = NO;
}

#pragma mark - Button actions

- (void)printLaterItemForIndex:(NSInteger)index partialResult:(NSMutableDictionary *)partialResult withCompletion:(void (^)(NSDictionary *result))completion
{
    NSArray *papers = [MP sharedInstance].supportedPapers;

    if (index < papers.count) {
        MPPaper *paper = papers[index];
        [self.svgLoader loadFileForPaperSize:(MPPaperSize)paper.paperSize reloadGestureImageView:NO withCompletion:^(void){
            UIImage *image = [self.svgLoader screenshotImage];
            MPPrintItem *printItem = [MPPrintItemFactory printItemWithAsset:image];
            printItem.layout = [self layoutForPaper:paper];
            
            if( ![partialResult objectForKey:paper.sizeTitle] ) {
                [partialResult setValue:printItem forKey:paper.sizeTitle];
            }
            
            [self printLaterItemForIndex:(index + 1) partialResult:partialResult withCompletion:^(NSDictionary *result) {
                if (completion) {
                    completion(partialResult);
                }
            }];
        }];
    } else {
        if (completion) {
            completion(partialResult);
        }
    }
}

- (void)printLaterItemsWithCompletion:(void (^)(NSDictionary *result))completion
{
    NSArray *paperSizes = [MP sharedInstance].supportedPapers;
    
    NSMutableDictionary *partialResult = [NSMutableDictionary dictionaryWithCapacity:paperSizes.count];
    
    [self printLaterItemForIndex:0 partialResult:partialResult withCompletion:^(NSDictionary *result) {
        if (completion) {
            completion(result);
        }
    }];
}

- (void)presentActivityViewControllerWithActivities:(NSArray *)applicationActivities
{
    [self preparePrintItem];
    
    if (nil == self.printItem) {
        // NOTE. We couldn't recreate this situation, but there is a crash reported in crashlytics indicating that this has happened: Crash 1.3(995) #81
        if (NSClassFromString(@"UIAlertController") != nil) {
            UIAlertController *errorScreenshotController = [UIAlertController alertControllerWithTitle:kScreenshotErrorTitle message:kScreenshotErrorMessage preferredStyle:UIAlertControllerStyleAlert];
            [errorScreenshotController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
            [errorScreenshotController addAction:[UIAlertAction actionWithTitle:kRetryButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self shareItem];
            }]];
            
            [self presentViewController:errorScreenshotController animated:YES completion:nil];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kScreenshotErrorTitle message:kScreenshotErrorMessage delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:kRetryButtonTitle, nil];
            alertView.tag = screenshotErrorAlertViewTag;
            [alertView show];
        }
    } else {
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:self.printItem.activityItems applicationActivities:applicationActivities];
        
        [activityViewController setValue:NSLocalizedString(@"My HP Snapshot", nil) forKey:@"subject"];
        
        activityViewController.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard,
                                                         UIActivityTypeSaveToCameraRoll,
                                                         UIActivityTypePostToWeibo,
                                                         UIActivityTypePostToTencentWeibo,
                                                         UIActivityTypeAddToReadingList,
                                                         UIActivityTypePrint,
                                                         UIActivityTypeAssignToContact,
                                                         UIActivityTypePostToVimeo];
        
        __weak __typeof(self) weakSelf = self;
        activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {

            BOOL printActivity = [activityType isEqualToString: NSStringFromClass([MPPrintActivity class])];
            BOOL printLaterActivity = [activityType isEqualToString: NSStringFromClass([MPPrintLaterActivity class])];
            
            NSString *offramp = activityType;
            NSDictionary *extendedMetrics = [weakSelf extendedMetrics];
            if (printActivity) {
                offramp = [weakSelf.printItem.extra objectForKey:kMetricsOfframpKey];
            } else if (printLaterActivity) {
                offramp = [weakSelf.printLaterJob.extra objectForKey:kMetricsOfframpKey];
                extendedMetrics = self.printLaterJob.extra;
            }
        
            if (!offramp) {
                PGLogError(@"Missing offramp key for share activity");
            }
            
            if (completed) {
                [[PGAnalyticsManager sharedManager] postMetricsWithOfframp:offramp printItem:weakSelf.printItem exendedInfo:extendedMetrics];
                if (printLaterActivity) {
                    [[MP sharedInstance] presentPrintQueueFromController:weakSelf animated:YES completion:nil];
                    // The user is using the print queue... suppress intro-to-print-queue coach marks
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setBool:NO forKey:kSettingShowPrintQCoachMarks];
                    [defaults synchronize];
                }
            } else {
                if (activityType) {
                    [[PGAnalyticsManager sharedManager] trackShareActivity:offramp withResult:kEventResultCancel];
                }
            }
            
            // if the user has seen the PrintLater offering, don't give them a coach mark for it in the future
            if (printLaterActivity) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setBool:NO forKey:kSettingShowPrintQCoachMarks];
                [defaults synchronize];
            }
            
            [self removeFalseFront];
            
            self.returningFromShareActivity = FALSE;
        };
        
        self.returningFromShareActivity = TRUE;
        if (IS_IPAD && !IS_OS_8_OR_LATER) {
            self.popover = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
            [self.popover presentPopoverFromBarButtonItem:self.shareButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else {
            if (IS_OS_8_OR_LATER) {
                activityViewController.popoverPresentationController.barButtonItem = self.shareButtonItem;
                activityViewController.popoverPresentationController.delegate = self;
            }
            
            [self presentViewController:activityViewController animated:YES completion:nil];
        }
    }
}

- (void)shareItem
{
    [self dismissCoachMarks];
    
    // We're about to start cycling image sizes through our svg view.
    //  Place a screenshot of the 4x5 svg view over the existing svg view.
   [self createFalseFront];

    PGSaveToCameraRollActivity *saveToCameraRollActivity = [[PGSaveToCameraRollActivity alloc] init];
    
    MPPrintActivity *printActivity = [[MPPrintActivity alloc] init];
    printActivity.dataSource = self;
    
    if (IS_OS_8_OR_LATER && ![[MP sharedInstance] isWifiConnected]) {
        MPPrintLaterActivity *printLaterActivity = [[MPPrintLaterActivity alloc] init];
        [self preparePrintJobWithCompletion:^{
            printLaterActivity.printLaterJob = self.printLaterJob;
            [self presentActivityViewControllerWithActivities:@[printLaterActivity, saveToCameraRollActivity]];
        }];
    } else {
        MPPrintActivity *printActivity = [[MPPrintActivity alloc] init];
        printActivity.dataSource = self;
        [self presentActivityViewControllerWithActivities:@[printActivity, saveToCameraRollActivity]];
    }
}


- (IBAction)shareButtonTapped:(id)sender
{
    [self shareItem];
}

- (void)doneBarButtonItemTapped:(id)sender
{
    [self setNavigationBarEditing:NO];
    [self.view endEditing:YES];
    [self unzoomTextViewInContainer];
    [self checkIfTextFitsBox:FALSE];
}

- (IBAction)overlayButtonTapped:(id)sender
{
    [self dismissCoachMarks];
}

- (void)dismissViewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ENABLE_PAGE_CONTROLLER_FUNCTIONALITY_NOTIFICATION object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSDictionary *)extendedMetrics
{
    return @{
             kMetricsTypeLocationKey:[self locationMetrics],
             kMetricsTypePhotoSourceKey:[[PGAnalyticsManager sharedManager] photoSourceMetrics],
             kMetricsTypePhotoPositionKey:[[PGAnalyticsManager sharedManager] photoPositionMetricsWithOffset:self.svgLoader.offset zoom:self.svgLoader.zoom angle:self.svgLoader.angle]
             };
}

#pragma mark - Getter/setter

- (UIBarButtonItem *)doneButtonItem
{
    if (!_doneButtonItem) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 73, 34)];
        [button setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
        UIImage *buttonImage = [[UIImage imageNamed:@"DefaultButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0f, 4.0f, 4.0f, 4.0f)];
        [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont HPSimplifiedRegularFontWithSize:14.0f];
        
        [button addTarget:self action:@selector(doneBarButtonItemTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        _doneButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    
    return _doneButtonItem;
}

#pragma mark - Text zooming

- (void)applyOffset:(UITextView *)textView
{
    // we want the horizontal center of the text view to be in the center of the screen
    //  ... the scrollView contains the shadowImageView which contains the imageView which contains the textView
    //  ... ignore the view hierarchies and just deal in screen coordinates
    CGRect textViewFrameInWindow = [textView convertRect:textView.bounds toView:self.navigationController.view];
    CGFloat screenWidth = self.navigationController.view.frame.size.width;
    CGFloat xOffset = (textViewFrameInWindow.origin.x + textViewFrameInWindow.size.width/2) - screenWidth/2;
    
    // the vertical position shouldn't be in the center of anything.  It should be visually pleasing when the keyboard displayed.
    //  ... just spitballing based on the bottom of the container view and the top of the keyboard.
    //  ... so, roughly 75% of the way down the screen, unless that takes the bottom of the textbox too close to the keyboard
    CGFloat screenHeight = self.navigationController.view.frame.size.height;
    CGFloat keyboardOriginY = screenHeight - KEYBOARD_HEIGHT;
    CGFloat desiredY = ZOOMED_TEXTFIELD_POSITION * (keyboardOriginY) - textViewFrameInWindow.size.height/2;
    
    // special case: what if the desired y position causes the text box to display partially underneath the keyboard?
    if( keyboardOriginY <= (desiredY + textViewFrameInWindow.size.height + MIN_DISTANCE_TEMPLATE_KEYBOARD) ) {
        desiredY = keyboardOriginY - (textViewFrameInWindow.size.height + MIN_DISTANCE_TEMPLATE_KEYBOARD);
    }
    
    CGFloat yOffset = textViewFrameInWindow.origin.y - desiredY;
    
    [UIView textEditionTabBarAnimateWithAnimations:^{
        self.containerView.contentOffset = CGPointMake(xOffset, yOffset);
    }
                                        completion:nil];
}

- (void)zoomTextViewInContainer:(UITextView *)textView
{
    self.isZooming = true;
    
    // we want the text view to take up the entire container view... with a little buffer on the left and right
    CGFloat zoomValue = self.containerView.bounds.size.width / (textView.bounds.size.width + 10);
    
    // animate the text view into its zoomed size... and center it in the window
    [UIView textEditionTabBarAnimateWithAnimations:^{
        self.originalTransform = self.svgLoader.shadowedSvgImageView.transform;
        self.svgLoader.shadowedSvgImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, zoomValue, zoomValue);
        [self applyOffset:textView];
    }
                                        completion: nil];
}

- (void)unzoomTextViewInContainer
{
    [UIView textEditionTabBarAnimateWithAnimations:^{
        [self.svgLoader showTextBorder:FALSE];
        self.svgLoader.shadowedSvgImageView.transform = self.originalTransform;
        self.containerView.contentOffset = CGPointMake(0, 0);
    } completion: ^(BOOL arg){
        
    }];
    
    self.isZooming = false;
}

#pragma mark - Helper methods

- (void)checkIfTextFitsBox:(BOOL)editing
{
    if( !editing ) {
        // Are there any "real" characters in the string?
        NSCharacterSet *trimCharacters = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString       *trimmedString  = [self.currentTextViewInEdition.text stringByTrimmingCharactersInSet:trimCharacters];
        if( 0 == trimmedString.length ) {
            self.currentTextViewInEdition.text = @"";
            self.svgLoader.customUserText = @"";
        }
        
        BOOL showTextPrompt = ![self.currentTextViewInEdition.text length] || [self.svgLoader.textPrompt isEqualToString:trimmedString];
        [self.svgLoader showTextPrompt:showTextPrompt];
    }
    
    BOOL showWarningIcon = ![self.currentTextViewInEdition isAllTextVisible];
    
    if( self.isZooming ) {
        [self.svgLoader showTextBorder:self.isZooming];
    }
    
    [self.svgLoader showTextWarning:showWarningIcon];
}

- (void)wifiConnectionStatusChanged:(NSNotification *)notification
{
    if ([[MP sharedInstance] isWifiConnected]) {
        [self setPrintQCoachMarksVisible:NO withDuration:kCoachMarkAnimationDuration];
    } else if ([self printQCoachMarksShouldBeShown]) {
        [self setPrintQCoachMarksVisible:YES withDuration:kCoachMarkAnimationDuration];
    }
}

#pragma mark - Coach Marks

-(BOOL)editingCoachMarksHaveBeenShown
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (nil == [defaults objectForKey:kSettingShowEditingCoachMarks]) {
        [defaults setBool:YES forKey:kSettingShowEditingCoachMarks];
        [defaults synchronize];
    }
    return ![defaults boolForKey:kSettingShowEditingCoachMarks];
}

-(BOOL)printQCoachMarksShouldBeShown
{
    BOOL shouldShow = NO;
    
    // don't show the printQ coach mark while the sharing coach mark is visible
    if( [self editingCoachMarksHaveBeenShown] && ![self.navigationItem.rightBarButtonItems containsObject:self.doneButtonItem] ) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        //No matter what, if not iOS8 or later, we don't show the coach marks
        if (!IS_OS_8_OR_LATER) {
            [defaults setBool:NO forKey:kSettingShowPrintQCoachMarks];
        } else {
            //If the flag isn't set to show the marks, we set it.
            if (nil == [defaults objectForKey:kSettingShowPrintQCoachMarks]) {
                [defaults setBool:YES forKey:kSettingShowPrintQCoachMarks];
            }
        }
        [defaults synchronize];
        
        // If not, check for wifi and a default printer
        if( [defaults boolForKey:kSettingShowPrintQCoachMarks] ) {
            if( ![[MP sharedInstance] isWifiConnected] ) {
                shouldShow = YES;
            }
        }
    }
    
    return shouldShow;
}

- (void)setEditingCoachMarkLocation
{
    UITextView *textView = [self.svgLoader descriptionTextView];
    
    CGPoint coachPoint = [textView convertPoint:CGPointMake(0,0) toView:self.containerView];
    
    self.editingHorizontalConstraint.constant = coachPoint.x + kEditingCoachMarkHorizontalOffset;
    self.editingVerticalConstraint.constant = coachPoint.y - self.editingCoachView.frame.size.height;
}

- (void)dismissCoachMarks
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // We know if the coachmarks are showing by their alpha values
    if( fabs(self.sharingCoachView.alpha) > CGFLOAT_MIN ) {
        [self setCoachMarksVisible:NO withDuration:kCoachMarkAnimationDuration];
        
        [defaults setBool:NO forKey:kSettingShowEditingCoachMarks];
        [defaults synchronize];
    }
    else if( fabs(self.printQCoachView.alpha) > CGFLOAT_MIN ) {
        [self setPrintQCoachMarksVisible:NO withDuration:kCoachMarkAnimationDuration];
        
        [defaults setBool:NO forKey:kSettingShowPrintQCoachMarks];
        [defaults synchronize];
    }
}

- (void)setCoachMarksVisible:(BOOL)visible withDuration:(float)duration
{
    if (visible) {
        [self setEditingCoachMarkLocation];
        self.overlayView.hidden = NO;
    }
    
    CGFloat alpha = visible ? 1.0f : 0.0f;
    [UIView animateWithDuration:duration animations:^{
        [self.editingCoachView setAlpha:alpha];
        [self.sharingCoachView setAlpha:alpha];
    } completion:^(BOOL finished) {
        if (!visible) {
            self.overlayView.hidden = YES;

            if( [self printQCoachMarksShouldBeShown] ) {
                [self setPrintQCoachMarksVisible:YES withDuration:kCoachMarkAnimationDuration];
            }
        }
    }];
}

- (void)setPrintQCoachMarksVisible:(BOOL)visible withDuration:(float)duration
{
    self.overlayView.hidden = !visible;
    
    CGFloat alpha = visible ? 1.0f : 0.0f;
    [UIView animateWithDuration:duration animations:^{
        [self.printQCoachView setAlpha:alpha];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - UIPopoverPresentationControllerDelegate

// NOTE: The implementation of this delegate with the default value is a workaround to compensate an error in the new popover presentation controller of the SDK 8. This fix correct the case where if the user keep tapping repeatedly the share button in an iPad iOS 8, the app goes back to the first screen.
- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    return YES;
}

#pragma mark - PGSVGLoaderDelegate

- (void)svgLoader:(PGSVGLoader *)svgLoader textViewDidBeginEditing:(UITextView *)textView
{
    self.currentTextViewInEdition = textView;
    [textView selectAll:self];
    [self zoomTextViewInContainer:textView];
    [self setNavigationBarEditing:YES];
    [self checkIfTextFitsBox:TRUE];
    [self.svgLoader showTextPrompt:FALSE];
    [PGAnalyticsManager sharedManager].templateTextEdited = YES;
}

- (void)svgLoader:(PGSVGLoader *)svgLoader textViewDidChange:(UITextView *)textView
{
    self.currentTextViewInEdition = textView;
    self.svgLoader.customUserText = textView.text;
    [PGAnalyticsManager sharedManager].templateText = textView.text;
    [Crashlytics setObjectValue:textView.text forKey:@"Text"];
    [self checkIfTextFitsBox:TRUE];
    [self saveTemplateState];
}

- (void)svgLoaderDidLongPress:(PGSVGLoader *)svgLoader
{
    if ([self.svgLoader.locationName isEqualToString:kLocationBusyLabel]) {
        return;
    }
    
    if (self.media.place) {
        [self selectLocation:self.media.place];
    } else {
        [self showCustomLocationAlert];
    }
}

#pragma mark - PGTemplateSelectorViewDelegate

- (void)templateSelectorView:(PGTemplateSelectorView *)templateSelectorView didSelectTemplate:(PGTemplate *)template
{
    self.currentTemplate = template;
    [PGAnalyticsManager sharedManager].templateName = template.name;
    [PGAnalyticsManager sharedManager].templatePosition = [NSString stringWithFormat:@"%ld", (long)self.currentTemplate.position];
    [[PGAnalyticsManager sharedManager] trackSelectTemplate:template.name];
    NSString *currentTemplateFilename = [self.currentTemplate fileNameForPaperSize:MPPaperSize4x5];
    self.path = [[NSBundle mainBundle]resourcePath];
    [self.svgLoader loadFile:[NSString stringWithFormat:@"%@.svg", currentTemplateFilename] path:self.path reloadGestureImageView:NO withCompletion:nil];
    [self saveTemplateState];
}

- (void)templateSelectorViewDidLongTap:(PGTemplateSelectorView *)templateSelectorView
{
    [[DBChooser defaultChooser] openChooserForLinkType:DBChooserLinkTypeDirect fromViewController:self completion:^(NSArray *results) {
        if ([results count] > 0) {
            DBChooserResult *result = results[0];
            NSURL *url = result.link;
            NSData *urlData = [NSData dataWithContentsOfURL:url];
            if (urlData) {
                NSString  *path = [NSString stringWithFormat:@"%@/%@", [PGSVGResourceManager hpcDirectory], result.name];
                [urlData writeToFile:path atomically:YES];
                path = [PGSVGResourceManager getPathForSvgResource:result.name forceUnzip:TRUE];
                NSString *filename = [PGSVGResourceManager getFilenameForSvgResource:result.name];
                [self.svgLoader loadFile:filename path:path reloadGestureImageView:NO withCompletion:nil];
                
            } else {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                            message:NSLocalizedString(@"Error loading file from DropBox", nil)
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                  otherButtonTitles:nil] show];
            }
        }
    }];
}

#pragma mark - MPPrintDelegate

- (void)didFinishPrintFlow:(UIViewController *)printViewController
{
    NSString *offramp = [self.printItem.extra objectForKey:kMetricsOfframpKey];
    if (offramp) {
        [[PGAnalyticsManager sharedManager] postMetricsWithOfframp:offramp printItem:self.printItem exendedInfo:[self extendedMetrics]];
    } else {
        PGLogError(@"Print from client UI missing offramp key in print item");
    }
    [self removeFalseFront];
    [printViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelPrintFlow:(UIViewController *)printViewController
{
    [self removeFalseFront];
    [printViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MPPrintDataSource
- (void)imageForPaper:(MPPaper *)paper withCompletion:(void (^)(UIImage *))completion
{
    [self.svgLoader loadFileForPaperSize:paper.paperSize reloadGestureImageView:NO withCompletion:^(void){
        UIImage *image = [self.svgLoader screenshotImage];
        if (completion) {
            completion(image);
        }
    }];
}

- (void)printingItemForPaper:(MPPaper *)paper withCompletion:(void (^)(MPPrintItem *))completion
{
    [self imageForPaper:paper withCompletion:^(UIImage *image) {
        self.printItem = [MPPrintItemFactory printItemWithAsset:image];
        self.printItem.layout = [self layoutForPaper:paper];
        if (completion) {
            completion(self.printItem);
        }
    }];
}

- (void)previewImageForPaper:(MPPaper *)paper withCompletion:(void (^)(UIImage *))completion
{
    [self imageForPaper:paper withCompletion:completion];
}

#pragma mark - MPAddPrintLaterDelegate

- (void)didFinishAddPrintLaterFlow:(UIViewController *)addPrintLaterJobTableViewController
{
    NSDictionary *values = @{
                             kMPPrintQueueActionKey:[self.printLaterJob.extra objectForKey:kMetricsOfframpKey],
                             kMPPrintQueueJobKey:self.printLaterJob,
                             kMPPrintQueuePrintItemKey:[self.printLaterJob.printItems objectForKey:[MP sharedInstance].defaultPaper.sizeTitle] };
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPPrintQueueNotification object:values];
    [self removeFalseFront];
    [self dismissViewControllerAnimated:YES completion:^{
        [[MP sharedInstance] presentPrintQueueFromController:self animated:YES completion:nil];
    }];
}

- (void)didCancelAddPrintLaterFlow:(UIViewController *)addPrintLaterJobTableViewController
{
    [self removeFalseFront];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Location selection

- (void)selectLocation:(CLPlacemark *)place
{
    NSMutableArray *locationValues = [NSMutableArray arrayWithArray:[self locationsForPlace:place]];
    for (NSString *location in self.media.additionalLocations) {
        [self addPlaceValue:location toValues:locationValues];
    }
    if ([locationValues count] > 0) {
        [self showLocationAlert:locationValues];
    } else {
        [self showCustomLocationAlert];
    }
}

- (void)showLocationAlert:(NSArray *)locations
{
    NSString *title = NSLocalizedString(@"Choose Location", nil);
    NSString *cancelButtonLabel = NSLocalizedString(@"Cancel", nil);
    
    if (NSClassFromString(@"UIAlertController") != nil) {
        UIAlertControllerStyle style = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:NSLocalizedString(@"Please select a location for this photo.", nil) preferredStyle:style];
        
        for (NSString *location in locations) {
            [alertController addAction:[UIAlertAction actionWithTitle:location style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                self.locationName = location;
                self.photoLocationEdited = YES;
            }]];
        }
        
        [alertController addAction:[UIAlertAction actionWithTitle:kCustomLocationButtonLabel style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self showCustomLocationAlert];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:cancelButtonLabel style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
        actionSheet.title = title;
        actionSheet.delegate = self;
        for (NSString *location in locations) {
            [actionSheet addButtonWithTitle:location];
        }
        [actionSheet addButtonWithTitle:kCustomLocationButtonLabel];
        actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:cancelButtonLabel];
        [actionSheet showInView:self.svgLoader.svgImageView];
    }
}

- (void)showCustomLocationAlert
{
    NSString *title = NSLocalizedString(@"Custom Location", nil);
    NSString *message = NSLocalizedString(@"Please enter a location for this photo.", nil);
    NSString *cancelButtonLabel = NSLocalizedString(@"Cancel", nil);
    NSString *setLocationButtonLabel = NSLocalizedString(@"Set Location", nil);
    
    if (NSClassFromString(@"UIAlertController") != nil) {
        UIAlertController *customLinkController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [customLinkController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.text = self.svgLoader.locationName;
        }];
        [customLinkController addAction:[UIAlertAction actionWithTitle:setLocationButtonLabel style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UITextField *field = customLinkController.textFields[0];
            NSString *customLocation = field.text;
            self.locationName = customLocation;
            self.photoLocationEdited = YES;
        }]];
        [customLinkController addAction:[UIAlertAction actionWithTitle:cancelButtonLabel style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:customLinkController animated:YES completion:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonLabel otherButtonTitles:setLocationButtonLabel, nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView textFieldAtIndex:0].text = self.svgLoader.locationName;
        [alertView show];
    }
}

- (void)addPlaceValue:(NSString *)value toValues:(NSMutableArray *)values
{
    // Note, we can't use 'containsString' and 'containsObject' here because they are iOS 8 only
    if (nil != value && [value rangeOfString:@"(null)"].location == NSNotFound && [values indexOfObject:value] == NSNotFound) {
        [values addObject:value];
    }
}

- (NSArray *)locationsForPlace:(CLPlacemark *)place
{
    if (!place) {
        return @[];
    }
    
    NSMutableArray *values = [NSMutableArray array];
    
    NSString *coordinates = [NSString stringWithFormat:kCoordinateDisplayFormat, place.location.coordinate.latitude, place.location.coordinate.longitude];
    NSString *zipCode = place.postalCode;
    NSString *cityState = [NSString stringWithFormat:@"%@, %@", place.locality, place.administrativeArea];
    NSString *neighborhood = place.subLocality;
    NSString *streetAddress = [NSString stringWithFormat:@"%@ %@", place.subThoroughfare, place.thoroughfare];
    
    [self addPlaceValue:coordinates toValues:values];
    [self addPlaceValue:zipCode toValues:values];
    [self addPlaceValue:cityState toValues:values];
    [self addPlaceValue:neighborhood toValues:values];
    [self addPlaceValue:streetAddress toValues:values];
    
    for (NSString *poi in place.areasOfInterest) {
        [self addPlaceValue:poi toValues:values];
    }
    
    return [NSArray arrayWithArray:values];
}

- (void)retrievePlaceInfo
{
    if (self.media.place) {
        [self setInitialPlace];
    } else if (self.media.location) {
        self.locationName = kLocationBusyLabel;
        self.geocoder = [[CLGeocoder alloc] init];
        [self.geocoder reverseGeocodeLocation:self.media.location completionHandler:^(NSArray *placemarks, NSError *error) {
            self.locationName = nil;
            for (CLPlacemark *place in placemarks) {
                if (nil == self.media.place) {
                    self.media.place = place; // pick first placemark
                }
            }
            [self setInitialPlace];
        }];
    }
}

- (void)setInitialPlace
{
    if (self.locationName) {
        self.svgLoader.locationName = self.locationName;
    }
    else if (self.media.place) {
        NSString *locality = self.media.place.locality ? self.media.place.locality : self.media.place.subLocality;
        NSString *address = nil;
        if (locality && self.media.place.administrativeArea) {
            address = [NSString stringWithFormat:@"%@, %@", locality, self.media.place.administrativeArea];
        }
        if ([self.media.additionalLocations count] > 0) {
            self.locationName = self.media.additionalLocations[0];
        } else if ([self.media.place.areasOfInterest count] > 0) {
            self.locationName = self.media.place.areasOfInterest[0];
        } else if (address) {
            self.locationName = address;
        } else {
            self.locationName = [NSString stringWithFormat:kCoordinateDisplayFormat, self.media.place.location.coordinate.latitude, self.media.place.location.coordinate.longitude];;
        }
    } else if (self.media.location) {
        self.locationName = [NSString stringWithFormat:kCoordinateDisplayFormat, self.media.location.coordinate.latitude, self.media.location.coordinate.longitude];
    }
}

- (NSDictionary *)locationMetrics
{
    NSString *locationName = self.locationName == nil ? kMetricsNoLocation : self.svgLoader.locationName;
    NSString *locationEdited = self.photoLocationEdited ? kMetricsYesValue : kMetricsNoValue;
    NSString *latitude = kMetricsNoLocation;
    NSString *longitude = kMetricsNoLocation;
    if (self.media.place) {
        latitude = [NSString stringWithFormat:kCoordinateStorageFormat, self.media.place.location.coordinate.latitude];
        longitude = [NSString stringWithFormat:kCoordinateStorageFormat, self.media.place.location.coordinate.longitude];
    } else if (self.media.location) {
        latitude = [NSString stringWithFormat:kCoordinateStorageFormat, self.media.location.coordinate.latitude];
        longitude = [NSString stringWithFormat:kCoordinateStorageFormat, self.media.location.coordinate.longitude];
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:
            locationEdited, kMetricsPhotoLocationEditedKey,
            latitude, kMetricsPhotoLatitudeKey,
            longitude, kMetricsPhotoLongitudeKey,
            nil];
}

- (void)setLocationName:(NSString *)locationName
{
    _locationName = locationName;
    self.svgLoader.locationName = locationName;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonText = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonText isEqualToString:kCustomLocationButtonLabel]) {
        [self showCustomLocationAlert];
    } else if (actionSheet.cancelButtonIndex != buttonIndex) {
        self.locationName = buttonText;
        self.photoLocationEdited = YES;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == screenshotErrorAlertViewTag) {
        if (alertView.cancelButtonIndex != buttonIndex) {
            [self shareItem];
        }
    } else {
        if (alertView.cancelButtonIndex != buttonIndex) {
            self.locationName = [alertView textFieldAtIndex:0].text;
            self.photoLocationEdited = YES;
        }
    }
}

#pragma mark - Template persistence

- (void)saveTemplateState
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.currentTemplate.name forKey:kTemplateNameKey];
    [defaults setObject:self.svgLoader.customUserText forKey:kTemplateTextKey];
    [defaults setObject:self.media.objectID forKey:kTemplateMediaKey];
    [defaults synchronize];
    PGLogInfo(@"SAVED TEMPLATE:\n  NAME: %@\n  MEDIA: %@\n  TEXT: %@", self.currentTemplate.name, self.media.objectID, self.svgLoader.customUserText);
}

- (void)restoreTemplateState
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastTemplateName = [defaults stringForKey:kTemplateNameKey];
    NSString *lastMediaID = [defaults stringForKey:kTemplateMediaKey];
    NSString *lastText = [defaults stringForKey:kTemplateTextKey];
    [self.templateSelectorView selectTemplateWithName:lastTemplateName];
    if ([self.media.objectID isEqualToString:lastMediaID]) {
        self.svgLoader.customUserText = lastText;
    }
    PGLogInfo(@"RESTORED TEMPLATE:\n  NAME: %@\n  MEDIA: %@\n  TEXT: %@", lastTemplateName, lastMediaID, lastText);
}

#pragma mark - Layout

- (MPLayout *)layoutForPaper:(MPPaper *)paper
{
    MPLayout *layout;
    
    if (MPPaperSizeLetter == paper.paperSize) {
        MPPaper *letterPaper = [[MPPaper alloc] initWithPaperSize:MPPaperSizeLetter paperType:MPPaperTypePlain];
        MPPaper *defaultPaper = [MP sharedInstance].defaultPaper;
        CGFloat maxDimension = fmaxf(defaultPaper.width, defaultPaper.height);
        CGFloat width = maxDimension / letterPaper.width * 100.0f;
        CGFloat height = maxDimension / letterPaper.height * 100.0f;
        CGFloat x = (100.0f - width) / 2.0f;
        CGFloat y = (100.0f - height) / 2.0f;
        layout = [MPLayoutFactory layoutWithType:[MPLayoutFit layoutType]
                                       orientation:MPLayoutOrientationPortrait
                                     assetPosition:CGRectMake(x, y, width, height)
                                     shouldRotate:NO];
    } else if (MPPaperSize4x5 == paper.paperSize) {
        NSDictionary *options = @{kMPLayoutVerticalPositionKey:[NSNumber numberWithInt:MPLayoutVerticalPositionTop]};

        // The following uses our new MPFactoryDelegate to extend MP's layout capabilities into the 3rd party app
        layout = [MPLayoutFactory layoutWithType:[MPLayoutFit layoutType]
                                       orientation:MPLayoutOrientationPortrait
                                     layoutOptions:options];
        
 
    } else {
        layout = [MPLayoutFactory layoutWithType:[MPLayoutFit layoutType]];
    }
    
    return layout;
}

#pragma mark - Print preparation

- (void)preparePrintItem
{
    UIImage *image = [self.svgLoader screenshotImage];
    self.printItem = [MPPrintItemFactory printItemWithAsset:image];
    self.printItem.layout = [self layoutForPaper:[MP sharedInstance].defaultPaper];
}

- (void)preparePrintJobWithCompletion:(void(^)(void))completion
{
    NSString *printLaterJobNextAvailableId = [[MP sharedInstance] nextPrintJobId];
    self.printLaterJob = [[MPPrintLaterJob alloc] init];
    self.printLaterJob.id = printLaterJobNextAvailableId;
    self.printLaterJob.name = self.currentTemplate.name;
    self.printLaterJob.date = [NSDate date];
    self.printLaterJob.extra = [self extendedMetrics];
    [self printLaterItemsWithCompletion:^(NSDictionary *result) {
        self.printLaterJob.printItems = result;
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - Bar button items

- (void)setNavigationBarEditing:(BOOL)editing
{
    NSString *title = NSLocalizedString(@"Select Template", @"Title of the select template screen");
    UIColor *barTintColor = [PGAppAppearance navBarColor];
;
    BOOL hidesBackButton = NO;

    NSMutableArray *icons = [NSMutableArray arrayWithArray:@[ self.shareButtonItem]];
    if ([[MP sharedInstance] isWifiConnected]) {
        [icons addObjectsFromArray:@[ self.printBarButtonItem ]];
    } else if (IS_OS_8_OR_LATER) {
        [icons addObjectsFromArray:@[ self.printLaterBarButtonItem ]];
    }
    [self.navigationItem setLeftBarButtonItem:self.cancelBarButtonItem];

    if (editing) {
        title = nil;
        barTintColor = [UIColor HPTabBarSelectedColor];
        icons = [NSMutableArray arrayWithArray:@[ self.doneButtonItem ]];
        hidesBackButton = YES;
        [self.navigationItem.leftBarButtonItem setTintColor:[UIColor clearColor]];
        [self.navigationItem.leftBarButtonItem setEnabled:NO];
    } else {
        [self.navigationItem.leftBarButtonItem setTintColor:self.printBarButtonItem.tintColor];
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
    }
    
    [self.navigationItem setRightBarButtonItems:icons animated:YES];
    //[self.navigationItem setHidesBackButton:hidesBackButton	animated:YES];
    [self.navigationItem setLeftBarButtonItem:self.cancelBarButtonItem animated:YES];
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.navigationItem.title = title;
                         self.navigationController.navigationBar.barTintColor = barTintColor;
                     }
                     completion:^(BOOL finished) {
                         // display print queue coach mark if necessary
                         [self wifiConnectionStatusChanged:nil];
                     }];    
}

- (void)preparePrintBarButtonItems
{
    self.printBarButtonItem = [[UIBarButtonItem alloc]
                               initWithImage:[UIImage imageNamed:@"printIcon"]
                               style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(printTapped:)];
    
    self.printLaterBarButtonItem = [[UIBarButtonItem alloc]
                                    initWithImage:[UIImage imageNamed:@"printLaterIcon"]
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(printLaterTapped:)];
    
    self.cancelBarButtonItem = [[UIBarButtonItem alloc ] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTapped:)];
    
    self.printBarButtonItem.accessibilityIdentifier = @"printBarButtonItem";
    self.printLaterBarButtonItem.accessibilityIdentifier = @"printLaterBarButtonItem";
    self.cancelBarButtonItem.accessibilityIdentifier = @"cancelBarButtonItem";
    
    [self setNavigationBarEditing:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:@"kMPWiFiConnectionEstablished" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:@"kMPWiFiConnectionLost" object:nil];
}

- (void)connectionChanged:(NSNotification *)notification
{
    if (![self.navigationItem.rightBarButtonItems containsObject:self.doneButtonItem]) {
        [self setNavigationBarEditing:NO];
    }
}

- (void)printTapped:(id)sender
{
    [self createFalseFront];
    [self dismissCoachMarks];

    [self preparePrintItem];
    UIViewController *vc = [[MP sharedInstance] printViewControllerWithDelegate:self dataSource:self printItem:self.printItem fromQueue:NO settingsOnly:NO];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)printLaterTapped:(id)sender
{
    [self createFalseFront];
    [self dismissCoachMarks];

    [self preparePrintJobWithCompletion:^{
        UIViewController *vc = [[MP sharedInstance] printLaterViewControllerWithDelegate:self printLaterJob:self.printLaterJob];
        [self presentViewController:vc animated:YES completion:nil];
    }];
}

- (void)cancelTapped:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - False front

- (void)createFalseFront
{
    CGFloat originalScale = self.containerView.layer.contentsScale;
    UIGraphicsBeginImageContextWithOptions(self.containerView.bounds.size, NO, 0);
    self.containerView.layer.contentsScale = [UIScreen mainScreen].scale;
    [self.containerView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.containerView.layer.contentsScale = originalScale;
    
    UIImageView *falseFront = [[UIImageView alloc] initWithImage:image];
    falseFront.frame = self.containerView.frame;
    
    [self.view addSubview:falseFront];
    
    self.falseFront = falseFront;
    
    [self.view bringSubviewToFront:self.editingCoachView];
    [self.view bringSubviewToFront:self.sharingCoachView];
    [self.view bringSubviewToFront:self.printQCoachView];
    [self.view bringSubviewToFront:self.overlayView];
}

- (void)removeFalseFront
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *currentTemplateFilename = [self.currentTemplate fileNameForPaperSize:MPPaperSize4x5];
        [self.svgLoader loadFile:[NSString stringWithFormat:@"%@.svg", currentTemplateFilename] path:self.path reloadGestureImageView:NO withCompletion:^(void){
            if( self.falseFront ) {
                [self.falseFront removeFromSuperview];
                self.falseFront = nil;
            }
        }];
    });
}

@end
