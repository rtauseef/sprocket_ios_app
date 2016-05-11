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

#import <CoreImage/CoreImage.h>
#import <CoreLocation/CoreLocation.h>
#import <SVGKLayeredImageView.h>
#import <HPPRMedia.h>
#import "PGAppDelegate.h"
#import "PGSVGLoader.h"
#import "SVGTextElement.h"
#import "PGSVGText.h"
#import "PGSVGImage.h"
#import "PGHighQualityTextView.h"
#import "PGAnalyticsManager.h"
#import "PGGesturesView.h"
#import "PGSVGResourceManager.h"
#import "UIView+Background.h"
#import "UITextView+Additions.h"
#import "SVGKImage+Box.h"
#import "UIView+Transform.h"
#import "UIView+Style.h"
#import "UIColor+HexString.h"
#import "UIFont+Style.h"
#import "UIImage+imageResize.h"
#import <Crashlytics/Crashlytics.h>

#define DEGREES_TO_RADIANS(x) (x * M_PI/180.0)
#define LIGHT_ALPHA 0.3f
#define DARK_ALPHA  1.0f

@interface PGSVGLoader () <UITextViewDelegate, PGGesturesViewDelegate>

@property (strong, nonatomic) NSMutableArray *textViews;				// TextViews created after parsing the SVG file
@property (strong, nonatomic) NSMutableArray *textViewsDashedBorders;	// Dashed borders created on the TextViews
@property (strong, nonatomic) NSMutableDictionary *imageCache;

@property (strong, nonatomic) PGSVGMetadataLoader *svgMetadataLoader;
@property (strong, nonatomic) SVGKImage *loadedImage;
@property (strong, nonatomic) SVGKImageView *svgLayeredImageView; // ImageView got from the SVG file
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIImageView *warningIcon;

@property (assign, nonatomic) BOOL isTextWarningVisible;
@property (assign, nonatomic) BOOL isTextBorderVisible;
@property (strong, nonatomic) NSString *templateFilename;
@property (strong, nonatomic) UIImage *photoSelected;
@property (strong, nonatomic) UIImage *userPhoto;
@property (strong, nonatomic) PGGesturesView *gestureImageView;
@property (assign, nonatomic) CGSize originalSize;

@property (weak, nonatomic) HPPRMedia *selectedMedia;
@property (assign, nonatomic) CGRect picBox;
@property (assign, nonatomic) CGRect userImageBox;

@property (strong, nonatomic) UIView *locationIconView;
@property (strong, nonatomic) UIView *dateIconView;
@property (strong, nonatomic) UIView *likesIconView;
@property (strong, nonatomic) UIView *commentsIconView;

@property (strong, nonatomic) UIView *isoIconView;
@property (strong, nonatomic) UIView *shutterSpeedIconView;

@property (strong, nonatomic) NSDictionary *svgDictionary;
@property (assign, nonatomic) CGFloat yOffset;

@property (strong, nonatomic) CLGeocoder *geocoder;

@end

@implementation PGSVGLoader

#pragma mark - Init and load methods

- (void)setPhoto:(UIImage *)photo media:(HPPRMedia *)media containerView:(UIView *)containerView delegate:(id<PGSVGLoaderDelegate>)delegate
{
    self.customUserText = nil;
    self.locationName = nil;
    self.textViews = [NSMutableArray array];
    self.textViewsDashedBorders = [NSMutableArray array];
    self.svgMetadataLoader = [[PGSVGMetadataLoader alloc] init];
    
    self.delegate = delegate;
    
    self.photoSelected = photo;
    self.selectedMedia = media;
    self.containerView = containerView;
    self.userPhoto = nil;
    
    [PGAnalyticsManager sharedManager].imageURL = media.standardUrl;
    [PGAnalyticsManager sharedManager].templateTextEdited = NO;
    
    [Crashlytics setObjectValue:media.standardUrl forKey:@"Photo URL"];
}

- (void)loadFileForPaperSize:(MPPaperSize)paperSize reloadGestureImageView:(BOOL)reloadGestureImageView withCompletion:(void (^)(void))completion
{
    NSString *fileName = [self fileNameForPaperSize:paperSize];
    NSString *path = [PGSVGResourceManager getPathForSvgResource:fileName forceUnzip:FALSE];
    
    [self load:fileName path:path reloadGestureImageView:reloadGestureImageView withCompletion:^(void){
        if (completion){
            completion();
        }
    }];
}

- (void)loadFile:(NSString *)fileName path:(NSString *)path reloadGestureImageView:(BOOL)reloadGestureImageView withCompletion:(void (^)(void))completion
{
    self.templateFilename = fileName;
    path = [PGSVGResourceManager getPathForSvgResource:fileName forceUnzip:FALSE];
    
    // dump cached images since the file name is changing
    self.imageCache = nil;
    
    [self load:fileName path:path reloadGestureImageView:reloadGestureImageView withCompletion:^(){
        UIImage *shadowImage = [UIImage imageNamed:@"CardShadow"];
        UIImageView *cardShadowImageView = [[UIImageView alloc] initWithImage:shadowImage];
        cardShadowImageView.frame = CGRectMake(0.0f, self.svgImageView.frame.size.height, cardShadowImageView.frame.size.width, cardShadowImageView.frame.size.height);
        
        CGRect shadowedSvgImageViewFrame = self.svgImageView.frame;
        shadowedSvgImageViewFrame.size.height += cardShadowImageView.frame.size.height;
        
        self.shadowedSvgImageView = [[UIView alloc] initWithFrame:shadowedSvgImageViewFrame];
        [self.shadowedSvgImageView addSubview:self.svgImageView];
        [self.shadowedSvgImageView addSubview:cardShadowImageView];
        
        [self scaleCardInContainerView];
        
        [self positionCardInContainerView];
        
        [self.containerView addSubview:self.shadowedSvgImageView];
        
        if (completion) {
            completion();
        }
    }];
}

- (void)load:(NSString *)fileName path:(NSString *)path reloadGestureImageView:(BOOL)reloadGestureImageView withCompletion:(void (^)(void))completion
{
    path = [PGSVGResourceManager getPathForSvgResource:fileName forceUnzip:FALSE];

    self.pageIsActive = TRUE;
    [self.textViews removeAllObjects];
    [self.textViewsDashedBorders removeAllObjects];
    self.warningIcon = nil;
    
    NSArray *svgTextFieldsParsed = @[[[PGSVGText alloc] initWithName:@"description"],
                                 [[PGSVGText alloc] initWithName:@"username"],
                                 [[PGSVGText alloc] initWithName:@"likes"],
                                 [[PGSVGText alloc] initWithName:@"comments"],
                                 [[PGSVGText alloc] initWithName:@"location"],
                                 [[PGSVGText alloc] initWithName:@"date"],
                                 [[PGSVGText alloc] initWithName:@"ISO"],
                                 [[PGSVGText alloc] initWithName:@"shutter"]];
    
    self.svgDictionary = [self.svgMetadataLoader parseFile:fileName path:path fields:svgTextFieldsParsed];
    
    for (UIView *view in self.containerView.subviews) {
        [view removeFromSuperview];
    }
    
    [SVGKImage imageAsynchronouslyNamed:fileName onCompletion:^(SVGKImage *loadedImage, SVGKParseResult* parseResult) {
        self.loadedImage = loadedImage;
        
        [self parseTextHolderEntries:svgTextFieldsParsed];
        [self parsePicBox];
        [self parseUserImageBox];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.svgLayeredImageView = [[SVGKLayeredImageView alloc] initWithSVGKImage:self.loadedImage];
            
            self.svgImageView = [[UIView alloc] initWithFrame:self.svgLayeredImageView.frame];
            self.svgImageView.clipsToBounds = YES;
            [self.svgImageView addSubview:self.svgLayeredImageView];
            [self addBackgroundImage];

            if (reloadGestureImageView) {
                [self addPic];
            } else {
                CGFloat scaleFactor = self.picBox.size.width / self.originalSize.width;
                
                self.gestureImageView.transform = CGAffineTransformIdentity;
                
                if (scaleFactor != 1.0f) {
                    self.gestureImageView.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
                }
                
                self.gestureImageView.frame = self.picBox;
                
                [self.svgImageView addSubview:self.gestureImageView];
            }
            
            [self addUserImage];
            
            [self addLocationIcon];
            [self addDateIcon];
            [self addLikesIcon];
            [self addCommentsIcon];
            [self addIsoIcon];
            [self addShutterSpeedIcon];
            
            [self addTexts:svgTextFieldsParsed customUserText:self.customUserText];
            
            if ([self.delegate respondsToSelector:@selector(svgLoaderDidLoadSVGImageView:)]) {
                [self.delegate svgLoaderDidLoadSVGImageView:self];
            }
            
            if (completion) {
                completion();
            }
        });
    }];
}

#pragma mark - Parse methods

- (void)parseTextHolderEntries:(NSArray *)svgTextFieldsParsed
{
    for (PGSVGText *textField in svgTextFieldsParsed) {
        textField.frame = [self.loadedImage textBoxForField:textField.name];
        
        id field = [self valueForField:textField.name];
        
        if (field == nil) {
            [self hideIconForField:textField.name];
        } else {
            if ([field isKindOfClass:[NSString class]]) {
                NSString *value = field;
                if ([value length] == 0) {
                    [self hideIconForField:textField.name];
                }
            } else if ([field isKindOfClass:[NSNumber class]]) {
                NSNumber *value = field;
                
                if ([value integerValue] == 0) {
                    [self hideIconForField:textField.name];
                }
            }
        }
        
        //        NSLog(@"%@: %@=%@", textField, textField.name, field);
    }
}

- (void)parsePicBox
{
    self.picBox = [self.loadedImage picBox];
}

- (void)parseUserImageBox
{
    self.userImageBox = [self.loadedImage userImageBox];
}

#pragma mark - Add content methods

- (void)addPic
{
    if (self.photoSelected) {
        self.gestureImageView = [[PGGesturesView alloc] initWithFrame:self.picBox];
        
        self.gestureImageView.delegate = self;
        self.originalSize = self.picBox.size;
        if ([self.source isEqualToString:INSTAGRAM_DISPLAY_NAME]) {
            self.gestureImageView.allowGestures = NO;
        }
        [self.svgImageView addSubview:self.gestureImageView];
        
        [PGAnalyticsManager sharedManager].trackPhotoPosition = NO;
        [PGAnalyticsManager sharedManager].photoPanEdited = NO;
        [PGAnalyticsManager sharedManager].photoZoomEdited = NO;
        [PGAnalyticsManager sharedManager].photoRotationEdited = NO;
        
        self.gestureImageView.image = self.photoSelected;
        
        [PGAnalyticsManager sharedManager].trackPhotoPosition = YES;
    }
}

- (void)addKnownUserImage:(NSString *)userMaskImage
{
    UIImageView *userImageView = [[UIImageView alloc] initWithImage:self.userPhoto];
    userImageView.frame = self.userImageBox;
    
    [self.svgImageView addSubview:userImageView];
    
    if (userMaskImage != nil) {
        UIImageView *userMaskImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self.svgDictionary objectForKey:kUserMaskImage]]];
        userMaskImageView.frame = self.userImageBox;
        [self.svgImageView addSubview:userMaskImageView];
        self.svgImageView.accessibilityIdentifier = @"UserImageView";
    }
    
}

- (void)addLocationIcon
{
    NSString *imageName = [NSString stringWithFormat:@"%@Location", [self.svgDictionary objectForKey:kLocationIconColor]];
    UIImage *locationImage = [UIImage imageNamed:imageName];

    if( nil != locationImage ) {
        self.locationIconView = [[UIImageView alloc] initWithImage:locationImage];
        self.locationIconView.frame = [self.loadedImage locationIconBox];
        self.locationIconView.hidden = TRUE;
        self.locationIconView.accessibilityIdentifier = @"locationIcon";
        
        [self.svgImageView addSubview:self.locationIconView];
    }
}

- (void)addDateIcon
{
    NSString *imageName = [NSString stringWithFormat:@"%@Date", [self.svgDictionary objectForKey:kDateIconColor]];
    UIImage *dateImage = [UIImage imageNamed:imageName];
    self.dateIconView = [[UIImageView alloc] initWithImage:dateImage];
    self.dateIconView.frame = [self.loadedImage dateIconBox];
    
    if( 0 == self.dateIconView.frame.size.width ) {
        imageName = [NSString stringWithFormat:@"%@Calendar", [self.svgDictionary objectForKey:kDateIconColor]];
        dateImage = [UIImage imageNamed:imageName];
        self.dateIconView = [[UIImageView alloc] initWithImage:dateImage];
        self.dateIconView.frame = [self.loadedImage calendarIconBox];
    }
    
    if( nil != self.dateIconView ) {
        self.dateIconView.hidden = TRUE;
        self.locationIconView.accessibilityIdentifier = @"dateIcon";
        [self.svgImageView addSubview:self.dateIconView];
    }
}

- (void)addIsoIcon
{
    NSString *imageName = [NSString stringWithFormat:@"%@ISO", [self.svgDictionary objectForKey:kIsoIconColor]];
    UIImage *isoImage = [UIImage imageNamed:imageName];
    
    if( nil != isoImage ) {
        self.isoIconView = [[UIImageView alloc] initWithImage:isoImage];
        self.isoIconView.frame = [self.loadedImage isoIconBox];
        self.isoIconView.hidden = TRUE;
        self.locationIconView.accessibilityIdentifier = @"isoIcon";
        
        [self.svgImageView addSubview:self.isoIconView];
    }
}

- (void)addShutterSpeedIcon
{
    NSString *imageName = [NSString stringWithFormat:@"%@Shutter", [self.svgDictionary objectForKey:kShutterSpeedIconColor]];
    UIImage *shutterSpeedImage = [UIImage imageNamed:imageName];
    
    if( nil != shutterSpeedImage ) {
        self.shutterSpeedIconView = [[UIImageView alloc] initWithImage:shutterSpeedImage];
        self.shutterSpeedIconView.frame = [self.loadedImage shutterSpeedIconBox];
        self.shutterSpeedIconView.hidden = TRUE;
        self.locationIconView.accessibilityIdentifier = @"shutterSpeedIcon";
        
        [self.svgImageView addSubview:self.shutterSpeedIconView];
    }
}

- (void)addFacebookLikesIcon
{
    NSString *imageName = [NSString stringWithFormat:@"%@FacebookLikes", [self.svgDictionary objectForKey:kFacebookLikesIconColor]];
    UIImage *likesImage = [UIImage imageNamed:imageName];
    
    if( nil != likesImage ) {
        self.likesIconView = [[UIImageView alloc] initWithImage:likesImage];
        self.likesIconView.frame = [self.loadedImage facebookLikesIconBox];
        self.likesIconView.hidden = TRUE;
        self.locationIconView.accessibilityIdentifier = @"facebookLikesIcon";
        
        [self.svgImageView addSubview:self.likesIconView];
    }
}

- (void)addFlickrLikesIcon
{
    NSString *imageName = [NSString stringWithFormat:@"%@FlickrLikes", [self.svgDictionary objectForKey:kFlickrLikesIconColor]];
    UIImage *likesImage = [UIImage imageNamed:imageName];
    
    if( nil != likesImage ) {
        self.likesIconView = [[UIImageView alloc] initWithImage:likesImage];
        self.likesIconView.frame = [self.loadedImage flickrLikesIconBox];
        self.likesIconView.hidden = TRUE;
        self.locationIconView.accessibilityIdentifier = @"flickrLikesIcon";
        
        [self.svgImageView addSubview:self.likesIconView];
    }
}

- (void)addInstagramLikesIcon
{
    NSString *imageName = [NSString stringWithFormat:@"%@InstagramLikes", [self.svgDictionary objectForKey:kInstagramLikesIconColor]];
    UIImage *likesImage = [UIImage imageNamed:imageName];
    
    if( nil != likesImage ) {
        self.likesIconView = [[UIImageView alloc] initWithImage:likesImage];
        self.likesIconView.frame = [self.loadedImage instagramLikesIconBox];
        self.likesIconView.hidden = TRUE;
        self.locationIconView.accessibilityIdentifier = @"instagramLikesIcon";
        
        [self.svgImageView addSubview:self.likesIconView];
    }
}

- (void)addLikesIcon
{
    if( [self.source isEqualToString:FACEBOOK_DISPLAY_NAME] ) {
        
        [self addFacebookLikesIcon];
    }
    else if( [self.source isEqualToString:FLICKR_DISPLAY_NAME] ) {
        
        [self addFlickrLikesIcon];
    }
    else if( [self.source isEqualToString:INSTAGRAM_DISPLAY_NAME] ) {
        
        [self addInstagramLikesIcon];
    }
    else {
    }
}

- (void)addCommentsIcon
{
    NSString *imageName = [NSString stringWithFormat:@"%@Comments", [self.svgDictionary objectForKey:kCommentsIconColor]];
    UIImage *commentsImage = [UIImage imageNamed:imageName];

    if( nil != commentsImage ) {
        self.commentsIconView = [[UIImageView alloc] initWithImage:commentsImage];
        self.commentsIconView.frame = [self.loadedImage commentsIconBox];
        self.commentsIconView.hidden = TRUE;
        self.locationIconView.accessibilityIdentifier = @"commentsIcon";
        
        [self.svgImageView addSubview:self.commentsIconView];
    }
}

- (void)addUserImage
{
    if (!CGRectIsEmpty(self.userImageBox)) {
        if (nil == self.userPhoto) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.selectedMedia.userProfilePicture]];
                self.userPhoto = [UIImage imageWithData:data];
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [self addKnownUserImage:[self.svgDictionary objectForKey:kUserMaskImage]];
                });
            });
        } else {
            [self addKnownUserImage:[self.svgDictionary objectForKey:kUserMaskImage]];
        }
    }
}

- (void)addTexts:(NSArray *)textsEntries customUserText:customUserText
{
    for (PGSVGText *svgTextField in textsEntries) {
        if (!CGRectIsEmpty(svgTextField.frame)) {
            UITextView *textView = [[UITextView alloc] initWithFrame:svgTextField.frame];
            textView.delegate = self;
            textView.layoutManager.allowsNonContiguousLayout = NO; //avoid textview cursor jumping
            textView.contentInset = UIEdgeInsetsZero;
            textView.textContainerInset = UIEdgeInsetsZero;
            textView.font = svgTextField.font;
            textView.textColor = svgTextField.color;
            textView.textAlignment = svgTextField.textAlignment;
            textView.backgroundColor = [UIColor clearColor];
            textView.autocorrectionType = UITextAutocorrectionTypeNo;
            textView.accessibilityIdentifier = svgTextField.name;
            CGAffineTransform transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(svgTextField.inclinationAngleInDegrees));
            
            [self.textViews addObject:textView];
            
            if (svgTextField.editable) {
                [self createDashBorderForTextView:textView transform:transform];
            } else {
                textView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
                textView.textContainer.maximumNumberOfLines = 1;
                
                textView.userInteractionEnabled = NO;
            }
            
            if ([svgTextField.name isEqualToString: @"description"]) {
                self.descriptionTextView = textView;
                if (customUserText != nil) {
                    textView.text = customUserText;
                } else {
                    [self setTextToTextView:textView svgTextField:svgTextField];
                }
            } else if ([svgTextField.name isEqualToString:@"location"] && self.locationName != nil) {
                textView.text = self.locationName;
                [self updateLocationIcon];
            }
            else {
                [self setTextToTextView:textView svgTextField:svgTextField];
            }

            // now that the field is populated, analyze its contents
            if([svgTextField.name isEqualToString:@"description"]) {
                if( [self.delegate respondsToSelector:@selector(svgLoader:textViewDidChange:)] ) {
                    [self.delegate svgLoader:self textViewDidChange:textView];
                }
                
                if( 0 == textView.text.length ) {
                    [self showTextPrompt:YES];
                }
                else if (![textView isAllTextVisible]) {
                    [self showTextWarning:YES];
                }
            }
            
            textView.accessibilityValue = textView.text;
            
            textView.transform = transform;
            
            [self.svgImageView addSubview:textView];
        }
    }
    
}

- (void)setLocationName:(NSString *)locationName
{
    _locationName = locationName;
    [Crashlytics setObjectValue:locationName forKey:@"Location"];
    for (UITextView *textView in self.textViews) {
        if ([textView.accessibilityIdentifier isEqualToString:@"location"]) {
            textView.text = locationName;
        }
    }
    [self updateLocationIcon];
}

- (void)updateLocationIcon
{
    if (!self.locationIconView) {
        [self addLocationIcon];
    }
    if (nil == self.locationName || [self.locationName isEqualToString:@""]) {
        self.locationIconView.hidden = YES;
    } else {
        self.locationIconView.hidden = NO;
    }
}

- (void)addBackgroundImage
{
    NSString *backgroundImage = [self.svgDictionary objectForKey:kBackgroundImage];
    
    if (backgroundImage == nil) {
        self.svgImageView.backgroundColor = [UIColor whiteColor];
    } else {
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:backgroundImage]];
        
        backgroundImageView.frame = self.svgImageView.frame;
        [self.svgImageView addSubview:backgroundImageView];
        [self.svgImageView sendSubviewToBack:backgroundImageView];
    }
}

#pragma mark - Scale and position methods

- (void)scaleCardInContainerView
{
    self.transformScaleValue = [self.shadowedSvgImageView transformScaleValueForContainerView:self.containerView];
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, self.transformScaleValue, self.transformScaleValue);
    self.shadowedSvgImageView.transform = transform;
}

- (void)positionCardInContainerView
{
    CGRect shadowedSvgImageViewFrame = self.shadowedSvgImageView.frame;
    shadowedSvgImageViewFrame.origin.x = (self.containerView.frame.size.width / 2) - (shadowedSvgImageViewFrame.size.width / 2);
    shadowedSvgImageViewFrame.origin.y = (self.containerView.frame.size.height / 2) - (shadowedSvgImageViewFrame.size.height / 2);
    self.shadowedSvgImageView.frame = shadowedSvgImageViewFrame;
}

#pragma mark - Print methods

- (void)disableTextEdition
{
    for (UITextView *textView in self.textViews) {
        textView.userInteractionEnabled = NO;
    }
}

- (void)enableTextEdition
{
    for (UITextView *textView in self.textViews) {
        textView.userInteractionEnabled = YES;
    }
}

- (void)hideTools
{
    [self hideTextViewsWarnings];
    [self disableTextEdition];
    [self showTextPrompt:FALSE];
    [self hideTextViewsDashedBorders];
}

- (void)showTools
{
    [self showTextBorder:self.isTextBorderVisible];
    [self showTextWarning:self.isTextWarningVisible];
    [self enableTextEdition];
}

#pragma mark - Text field appearance methods

- (void)showTextWarning:(BOOL)show
{
    if (show) {
        [self showTextViewsWarnings];
    } else {
        [self hideTextViewsWarnings];
    }
    
    self.isTextWarningVisible = show;
}

- (void)showTextBorder:(BOOL)show
{
    if (show) {
        [self showTextViewsDashedBorders];
    } else {
        [self lightenTextViewsDashedBorders];
    }
    
    self.isTextBorderVisible = show;
}

- (void)showTextPrompt:(BOOL)show
{
    static NSTextAlignment savedAlignment = NSTextAlignmentCenter;
    
    if( show ) {
        self.descriptionTextView.text = self.textPrompt;

        // Save the old horizontal text alignment and set it to center alignment
        if( NSTextAlignmentCenter != self.descriptionTextView.textAlignment ) {
            savedAlignment = self.descriptionTextView.textAlignment;
        }
        self.descriptionTextView.textAlignment = NSTextAlignmentCenter;
        
        // Use an offset to center the text vertically
        self.yOffset = -(self.descriptionTextView.frame.size.height-self.descriptionTextView.font.lineHeight)/2.0f;
        self.descriptionTextView.contentOffset = (CGPoint){.x=0, .y=self.yOffset};
        
        // Lighten the text
        self.descriptionTextView.alpha = LIGHT_ALPHA;
    }
    else {
        // If we're displyaing the "Enter Text" prompt, remove it
        NSCharacterSet *trimCharacters = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString       *trimmedString  = [self.descriptionTextView.text stringByTrimmingCharactersInSet:trimCharacters];
        if( [self.textPrompt isEqualToString:trimmedString] ) {
            self.descriptionTextView.text = @"";
        }

        // Restore the original textbox formatting
        self.yOffset = 0.0f;
        if( savedAlignment != NSTextAlignmentCenter ) {
            self.descriptionTextView.textAlignment = savedAlignment;
        }
        self.descriptionTextView.contentOffset = (CGPoint){.x=0, .y=self.yOffset};
        self.descriptionTextView.alpha = DARK_ALPHA;
    }
}

#pragma mark - Text field appearance helper methods


- (void) setLightDashedBorder:(UIView *)dashedBorderView
{
    [dashedBorderView setAlpha:LIGHT_ALPHA];
}

- (void)setDarkDashedBorder:(UIView *)dashedBorderView
{
    [dashedBorderView setAlpha:DARK_ALPHA];
}

- (void)hideTextViewsDashedBorders
{
    for (UIView *dashedBorderView in self.textViewsDashedBorders) {
        [dashedBorderView setAlpha:0.0f];
    }
}

- (void)lightenTextViewsDashedBorders
{
    for (UIView *dashedBorderView in self.textViewsDashedBorders) {
        if( self.isTextWarningVisible ) {
            [self showTextWarning:YES];
        } else {
            [self setLightDashedBorder:dashedBorderView];
        }
    }
}

- (void)showTextViewsDashedBorders
{
    for (UIView *dashedBorderView in self.textViewsDashedBorders) {
        CAShapeLayer *layer = (CAShapeLayer *)dashedBorderView.layer.sublayers[0];
        layer.strokeColor = self.descriptionTextView.textColor.CGColor;
        
        [self setDarkDashedBorder:dashedBorderView];
    }
}

- (void)hideTextViewsWarnings
{
    for (UIView *dashedBorderView in self.textViewsDashedBorders) {
        
        if( self.isTextBorderVisible ) {
            [self showTextViewsDashedBorders];
        }
        else {
            [self setLightDashedBorder:dashedBorderView];
        }
        
        [self showWarningIcon:NO];
    }
}

- (void)showTextViewsWarnings
{
    for (UIView *dashedBorderView in self.textViewsDashedBorders) {
        CAShapeLayer *layer = (CAShapeLayer *)dashedBorderView.layer.sublayers[0];
        layer.strokeColor = [UIColor redColor].CGColor;
        
        [self setDarkDashedBorder:dashedBorderView];
        [self showWarningIcon:YES];
    }
}

- (void)addWarningIconToView:(UIView *)dashedBorderView {
    if( !self.warningIcon ) {
        CGAffineTransform transform = dashedBorderView.transform;
        dashedBorderView.transform = CGAffineTransformIdentity;
        
        UIImage *icon = [UIImage imageNamed:@"TextWarning"];
        CGRect frame = CGRectMake(dashedBorderView.frame.size.width - icon.size.width,
                                  dashedBorderView.frame.size.height - icon.size.height,
                                  icon.size.width,
                                  icon.size.height);
        
        UIImageView *warningIcon = [[UIImageView alloc] initWithFrame:frame];
        warningIcon = [[UIImageView alloc] initWithFrame:frame];
        warningIcon.image = icon;
        warningIcon.backgroundColor = [UIColor clearColor];
        warningIcon.hidden = YES;
        
        [dashedBorderView addSubview:warningIcon];
        dashedBorderView.transform = transform;
        
        self.warningIcon = warningIcon;
    }
}

- (void)showWarningIcon:(BOOL)show
{
    UIView *dashedBorderView = self.textViewsDashedBorders[0]; // We are going to support only one text per card.
    
    if( show ) {
        [self addWarningIconToView:dashedBorderView];
    }
    
    CAShapeLayer *layer = (CAShapeLayer *)dashedBorderView.layer.sublayers[0];
    if (show) {
        layer.strokeColor = [UIColor redColor].CGColor;
        self.warningIcon.hidden = NO;
    } else {
        layer.strokeColor = self.descriptionTextView.textColor.CGColor;
        self.warningIcon.hidden = YES;
    }
}

- (void)forceEditing:(NSRange)selectedRange {
    if (self.textViews.count > 0) {
        UITextView *textView = self.textViews[0];
        [textView becomeFirstResponder];
        textView.selectedRange = selectedRange;
    }
}

#pragma mark - Helper methods

- (NSString *)fileNameForPaperSize:(MPPaperSize)paperSize
{
    NSRange indexOfUnderscore = [self.templateFilename rangeOfString:@"_"];
    NSString *fileName = [self.templateFilename substringToIndex:indexOfUnderscore.location];
    
    if (paperSize == MPPaperSize4x5){
        fileName = [NSString stringWithFormat:@"%@_%@", fileName, @"4x5"];
        
    } else if (paperSize == MPPaperSize4x6) {
        fileName = [NSString stringWithFormat:@"%@_%@", fileName, @"4x6"];
        
    } else if (paperSize == MPPaperSize5x7) {
        fileName = [NSString stringWithFormat:@"%@_%@", fileName, @"5x7"];
        
    } else if (paperSize == MPPaperSizeLetter) {
        // PaperSizeLetter just places a 4x5 image in the center of the paper
        fileName = [NSString stringWithFormat:@"%@_%@", fileName, @"4x5"];
        
    } else {
        PGLogError(@"Unknown PaperSize: %d", paperSize);
    }
    
    return [NSString stringWithFormat:@"%@.svg", fileName];
}

- (id)valueForField:(NSString *)field
{
    if ([field isEqualToString:@"description"]) {
        return self.selectedMedia.text;
    }  else if ([field isEqualToString:@"username"]) {
        return self.selectedMedia.userName;
    } else if ([field isEqualToString:@"date"]) {
        return self.selectedMedia.createdTime;
    } else if ([field isEqualToString:@"location"]) {
        return self.selectedMedia.locationName;
    } else if ([field isEqualToString:@"likes"]) {
        return [NSNumber numberWithInteger:self.selectedMedia.likes];
    } else if ([field isEqualToString:@"comments"]) {
        return [NSNumber numberWithInteger:self.selectedMedia.comments];
    } else if ([field isEqualToString:@"ISO"]) {
        return self.selectedMedia.isoSpeed;
    } else if ([field isEqualToString:@"shutter"]) {
        return self.selectedMedia.shutterSpeed;
    } else {
        return nil;
    }
}

- (void)hideIconForField:(NSString *)field
{
    NSString *iconId = [NSString stringWithFormat:@"%@Icon", field];
    Element *element = [self.loadedImage.DOMTree getElementById:iconId];
    [self.loadedImage.DOMTree removeChild:element];
}

- (UITextView *)textViewAtIndex:(NSInteger)index
{
    UITextView *textView = nil;
    
    if (index >= 0 && index < self.textViews.count) {
        textView = [self.textViews objectAtIndex:index];
    }
    
    return textView;
}

- (UITextView *)descriptionTextView
{
    return _descriptionTextView;
}

- (void)createDashBorderForTextView:(UITextView *)textView transform:(CGAffineTransform)transform
{
    CGRect frame = textView.frame;
    frame.origin.y -= 2;
    frame.size.height += 2;
    
    UIView *dashedBorderView = [[UIView alloc] initWithFrame:frame];
    dashedBorderView.backgroundColor = [UIColor clearColor];
    CAShapeLayer *dashedBorder = [dashedBorderView dashedBorder];
    [dashedBorderView.layer addSublayer:dashedBorder];
    dashedBorder.strokeColor = self.descriptionTextView.textColor.CGColor;
    [self.textViewsDashedBorders addObject:dashedBorderView];
    [self.svgImageView addSubview:dashedBorderView];
    
    dashedBorderView.transform = transform;
    [self setLightDashedBorder:dashedBorderView];
    dashedBorderView.accessibilityIdentifier = @"WarningView";
}

- (void)setTextToTextView:(UITextView *)textView svgTextField:(PGSVGText *)svgTextField
{
    id field = [self valueForField:svgTextField.name];
    
    if ([field isKindOfClass:[NSString class]]) {
        NSString *value = field;
        if (![value isEqualToString:@""]) {
            value = [[value componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
            textView.text = value;
            
            [self showIcon:svgTextField.name];
        }
    } else if ([field isKindOfClass:[NSNumber class]]) {
        NSNumber *value = field;
        if ([value integerValue] != 0) {
            double resultInM = ([value doubleValue] / 1000000);
            if (resultInM >= 1) {
                textView.text = [NSString stringWithFormat:@"%.2fM", resultInM];
            }
            else {
                NSInteger resultInK = ([value integerValue] / 1000);
                if (resultInK > 0) {
                    textView.text = [NSString stringWithFormat:@"%ldk", (long)resultInK];
                } else {
                    textView.text = [value stringValue];
                }
            }
            
            [self showIcon:svgTextField.name];
        }
    } else if ([field isKindOfClass:[NSDate class]]) {
        textView.text = [svgTextField.dateFormatter stringFromDate:field];

        // special case of needing a carriage return
        if( [svgTextField.dateFormatValue rangeOfString:@"\\n"].length > 0 ) {

            // prepare for two centered lines
            textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
            textView.textContainer.maximumNumberOfLines = 2;
            textView.textAlignment = NSTextAlignmentCenter;

            // remove all unnecessary space
            textView.textContainer.lineFragmentPadding = 0;
            textView.textContainerInset = UIEdgeInsetsZero;

            // set the text
            NSArray *strings = [textView.text componentsSeparatedByString:@" "];
            textView.text = [NSString stringWithFormat:@"%@\n%@", strings[0], strings[1]];

            // Not crazy about adding a special case, but the line spacing with this font is too large for the only
            //  template that uses it in a multi-line date field.
            if( [textView.font.familyName rangeOfString:@"Covered By Your Grace"].length ) {

                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.maximumLineHeight = 8.0f;
                paragraphStyle.alignment = NSTextAlignmentCenter;
                
                NSString *string = textView.text;
                textView.text = nil;
                NSDictionary *ats = @{
                                      NSFontAttributeName : textView.font,
                                      NSParagraphStyleAttributeName : paragraphStyle,
                                      };
                
                textView.attributedText = [[NSAttributedString alloc] initWithString:string attributes:ats];
            }
        }
        [self showIcon:svgTextField.name];
    }
}

- (void)showIcon:(NSString *)fieldName
{
    if( [fieldName isEqualToString:@"date"] ) {
        self.dateIconView.hidden = FALSE;
    }
    else if( [fieldName isEqualToString:@"location"] ) {
        self.locationIconView.hidden = FALSE;
    }
    else if( [fieldName isEqualToString:@"likes"] ) {
        self.likesIconView.hidden = FALSE;
    }
    else if( [fieldName isEqualToString:@"comments"] ) {
        self.commentsIconView.hidden = FALSE;
    }
    else if( [fieldName isEqualToString:@"ISO"] ) {
        self.isoIconView.hidden = FALSE;
    }
    else if( [fieldName isEqualToString:@"shutter"] ) {
        self.shutterSpeedIconView.hidden = FALSE;
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(svgLoader:textViewDidBeginEditing:)]) {
        [self.delegate svgLoader:self textViewDidBeginEditing:textView];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(svgLoader:textViewDidChange:)]) {
        [self.delegate svgLoader:self textViewDidChange:textView];
    }
    
    textView.accessibilityValue = textView.text;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Something keeps undoing our nicely centered "Edit Text" prompt... thwart it!
    if( self.pageIsActive  &&  [scrollView isMemberOfClass:[UITextView class]] ) {
        if( (int)self.yOffset != 0  &&  fabs(self.yOffset - scrollView.contentOffset.y) > CGFLOAT_MIN ) {
            scrollView.contentOffset = (CGPoint){.x=scrollView.contentOffset.x, .y=self.yOffset};
        }
    }
}

- (UIImage *)screenshotImage
{
    [self hideTools];
    
    CGAffineTransform transform = self.shadowedSvgImageView.transform;
    self.shadowedSvgImageView.transform = CGAffineTransformIdentity;
    
    UIImage *image = [self.svgImageView screenshotImage];
    
    self.shadowedSvgImageView.transform = transform;
    
    [self showTools];
    
    return image;
}

#pragma mark - PGGesturesViewDelegate

- (void)handleLongPress:(PGGesturesView *)gesturesView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(svgLoaderDidLongPress:)]) {
        [self.delegate svgLoaderDidLongPress:self];
    }
}

#pragma mark - Photo position

- (CGPoint)offset
{
    return self.gestureImageView.offset;
}

- (CGFloat)zoom
{
    return self.gestureImageView.zoom;
}

- (CGFloat)angle
{
    return self.gestureImageView.angle;
}

- (void)showcaseZoomAndRotate:(CGFloat)animationDuration rotationRadians:(CGFloat)rotationRadians zoomScale:(CGFloat)zoomScale
{
    [self.gestureImageView showcaseZoomAndRotate:animationDuration rotationRadians:rotationRadians zoomScale:zoomScale];
}

@end
