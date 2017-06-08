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

#import "PGCustomStickerViewController.h"
#import "PGCustomStickerManager.h"
#import "UIImage+Fixup.h"
#import "UIColor+Style.h"
#import "PGImglyManager.h"
#import "UIFont+Style.h"
#import "PGTermsAttributedLabel.h"
#import "UIViewController+Trackable.h"

#import <GPUImage/GPUImage.h>
#import <AVFoundation/AVFoundation.h>

@interface PGCustomStickerViewController () <TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButtonItem;

@property (strong, nonatomic) GPUImageStillCamera *camera;
@property (strong, nonatomic) GPUImageLuminanceThresholdFilter *thresholdFilter;

@property (strong, nonatomic) NSArray<GPUImageOutput *> *filters;
@property (strong, nonatomic) GPUImageCropFilter *cropFilter;
@property (strong, nonatomic) GPUImageChromaKeyFilter *chromaKeyFilter;
@property (strong, nonatomic) GPUImageClosingFilter *closingFilter;
@property (strong, nonatomic) NSArray<GPUImageErosionFilter *> *erosionFilters;
@property (strong, nonatomic) GPUImageColorInvertFilter *invertFilter;
@property (strong, nonatomic) GPUImageRGBFilter *rgbFilter;
@property (strong, nonatomic) GPUImageMonochromeFilter *monochromeFilter;

@property (weak, nonatomic) IBOutlet GPUImageView *gpuCleanImageView;
@property (weak, nonatomic) IBOutlet UIImageView *resultImageView;

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (strong, nonatomic) NSData *resultData;

@property (strong, nonatomic) CAShapeLayer *cornerLayer;

@property (strong, nonatomic) UIImage *stickerImage;
@property (strong, nonatomic) UIImage *thumbnailImage;

@property (assign, nonatomic) BOOL saveMode;
@property (assign, nonatomic) BOOL isCapturing;

@property (weak, nonatomic) IBOutlet UILabel *captureLabel;
@property (weak, nonatomic) IBOutlet PGTermsAttributedLabel *legalLabel;
@property (weak, nonatomic) IBOutlet UILabel *saveLabel;
@property (weak, nonatomic) IBOutlet UIButton *noButton;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;

@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (strong, nonatomic) AVPlayer *player;

@property (weak, nonatomic) IBOutlet UIImageView *infoButton;
@property (weak, nonatomic) IBOutlet UIImageView *closeButton;

@end

@implementation PGCustomStickerViewController

float const kPGCustomStickerVerticalOffset = 50;
float const kPGCustomerStickerThreshold = 0.42;
int const kPGCustomStickerClosingRadius = 1;
int const kPGCustomStickerErosionRadius = 4;
int const kPGCustomStickerErosionCount = 1;
float const kPGCustomStickerCameraInset = 60.0;
float const kPGCustomStickerCameraOpacity = 0.61803398875;
float const kPGCustomStickerCameraCornerLength = 30.0;
float const kPGCustomStickerCameraCornerInset = 52.0;
int const kPGCustomStickerCameraCornerWidth = 3;
float const kPGCustomStickerAnimationDuration = 0.61803398875;
NSString *kPGCustomStickerVideoPlayedKey = @"kPGCustomStickerVideoPlayedKey";

CGSize const kStickerSize = { 750, 750 };
CGSize const kThumbnailSize = { 100, 100 };

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setupPlayer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setupCamera];
    [self setupPlayerUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)hasCamera
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}


#pragma mark - Events

- (IBAction)cancelButtonTapped:(id)sender {
    self.saveMode = NO;
}

- (IBAction)saveButtonTapped:(id)sender {
    [self saveSticker];
}

- (void)cameraTapped
{
    if (!self.saveMode) {
        [self captureSticker];
    }
}

- (void)videoTapped:(UIGestureRecognizer *)recognizer
{
    [self hideVideo];
}

- (IBAction)closeButtonTapped:(id)sender
{
    if (self.videoView.hidden) {
        [self.camera stopCameraCapture];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self hideVideo];
    }
}

- (IBAction)infoButtonTapped:(id)sender
{
    [self playVideo];
}


#pragma mark - Stickers

- (void)processResult:(UIImage *)image
{
    self.stickerImage = [image resize:kStickerSize];
    self.thumbnailImage = [image resize:kThumbnailSize];
}

- (void)captureSticker
{
    if (!self.isCapturing) {
        self.isCapturing = YES;

        if (![self hasCamera]) {
            GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:[[UIImage imageNamed:@"love"] normalize]];
            [self setupFilters];
            [self applyFilterChain:self.filters start:picture];
            [picture processImageUpToFilter:[self lastFilter] withCompletionHandler:^(UIImage *processedImage) {
                [self processResult:processedImage];
                self.saveMode = YES;
                self.isCapturing = NO;
            }];
            return;
        }
        
        [self.camera capturePhotoAsImageProcessedUpToFilter:[self lastFilter] withCompletionHandler:^(UIImage *processedImage, NSError *error) {
            self.resultData = nil;
            [self processResult:processedImage];
            self.saveMode = YES;
            self.isCapturing = NO;
        }];
    }
}

- (IBAction)touchedDownInButton:(id)sender {
    UIButton *button = sender;
    button.backgroundColor = [UIColor whiteColor];
}

- (IBAction)touchedUpButton:(id)sender {
    UIButton *button = sender;
    button.backgroundColor = [UIColor clearColor];
}

- (void)saveSticker
{
    [UIView animateWithDuration:kPGCustomStickerAnimationDuration animations:^{
        self.saveLabel.alpha = 0.0;
        self.yesButton.alpha = 0.0;
        self.noButton.alpha = 0.0;
        self.yesButton.enabled = NO;
        self.noButton.enabled = NO;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:YES completion:^{
            [[PGCustomStickerManager sharedInstance] saveSticker:self.stickerImage thumbnail:self.thumbnailImage];
            [[NSNotificationCenter defaultCenter] postNotificationName:kPGImglyManagerStickersChangedNotification object:nil];
        }];
    }];
    [self.camera stopCameraCapture];
}

#pragma mark - UI

- (void)setupSaveLabel
{
    NSArray *randomTextLines = @[
                                 NSLocalizedString(@"Check out your custom sticker!", nil),
                                 NSLocalizedString(@"Nice drawing!", nil),
                                 NSLocalizedString(@"Looks good.", nil),
                                 NSLocalizedString(@"You must be an artist.", nil),
                                 NSLocalizedString(@"Perfect!", nil)
                                 ];

    uint32_t rnd = arc4random_uniform((uint32_t)[randomTextLines count]);

    NSString *firstLine = [randomTextLines objectAtIndex:rnd];
    NSString *secondLine = NSLocalizedString(@"Add to your sticker collection?", nil);

    self.saveLabel.text = [NSString stringWithFormat:@"%@\n%@", firstLine, secondLine];
}

- (void)setSaveMode:(BOOL)saveMode
{
    _saveMode = saveMode;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.resultImageView.image = self.stickerImage;
        if (saveMode) {
            [self setupSaveLabel];
            [UIView animateWithDuration:kPGCustomStickerAnimationDuration animations:^{
                self.resultImageView.alpha = 1.0;
                self.captureLabel.alpha = 0.0;
                self.saveLabel.alpha = 1.0;
                self.cornerLayer.opacity = 0.0;
                self.closeButton.alpha = 0.0;
                self.closeButton.superview.userInteractionEnabled = NO;
                self.infoButton.alpha = 0.0;
                self.infoButton.superview.userInteractionEnabled = NO;
                self.noButton.alpha = 1.0;
                self.noButton.enabled = YES;
                self.yesButton.alpha = 1.0;
                self.yesButton.enabled = YES;
            }];
        } else {
            [UIView animateWithDuration:kPGCustomStickerAnimationDuration animations:^{
                self.resultImageView.alpha = 0.0;
                self.captureLabel.alpha = 1.0;
                self.saveLabel.alpha = 0.0;
                self.cornerLayer.opacity = 1.0;
                self.closeButton.alpha = 1.0;
                self.closeButton.superview.userInteractionEnabled = YES;
                self.infoButton.alpha = 1.0;
                self.infoButton.superview.userInteractionEnabled = YES;
                self.noButton.alpha = 0.0;
                self.noButton.enabled = NO;
                self.yesButton.alpha = 0.0;
                self.yesButton.enabled = NO;
            }];
        }
    });
}

// Adapted from http://stackoverflow.com/questions/24196784/uiview-with-transparent-in-middle
- (void)addMask:(UIView *)view color:(UIColor *)color
{
    UIBezierPath *overlayPath = [UIBezierPath bezierPathWithRect:view.bounds];
    float width = view.bounds.size.width - 2.0 * kPGCustomStickerCameraInset;
    float top = (view.bounds.size.height - width) / 2.0 - kPGCustomStickerVerticalOffset;
    UIBezierPath *transparentPath = [UIBezierPath bezierPathWithRect:CGRectMake(kPGCustomStickerCameraInset, top, width, width)];
    [overlayPath appendPath:transparentPath];
    [overlayPath setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = overlayPath.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = color.CGColor;
    
    [view.layer addSublayer:fillLayer];
}

- (void)addCorners:(UIView *)view
{
    float width = view.bounds.size.width - 2.0 * kPGCustomStickerCameraCornerInset;
    float top = (view.bounds.size.height - width) / 2.0 - kPGCustomStickerVerticalOffset;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // top left
    [path moveToPoint:CGPointMake(kPGCustomStickerCameraCornerInset + kPGCustomStickerCameraCornerLength, top)];
    [path addLineToPoint:CGPointMake(kPGCustomStickerCameraCornerInset, top)];
    [path addLineToPoint:CGPointMake(kPGCustomStickerCameraCornerInset, top + kPGCustomStickerCameraCornerLength)];
    
    // bottom left
    [path moveToPoint:CGPointMake(kPGCustomStickerCameraCornerInset, top + width - kPGCustomStickerCameraCornerLength)];
    [path addLineToPoint:CGPointMake(kPGCustomStickerCameraCornerInset, top + width)];
    [path addLineToPoint:CGPointMake(kPGCustomStickerCameraCornerInset + kPGCustomStickerCameraCornerLength, top + width)];
    
    // bottom right
    [path moveToPoint:CGPointMake(kPGCustomStickerCameraCornerInset + width - kPGCustomStickerCameraCornerLength, top + width)];
    [path addLineToPoint:CGPointMake(kPGCustomStickerCameraCornerInset + width, top + width)];
    [path addLineToPoint:CGPointMake(kPGCustomStickerCameraCornerInset + width, top + width - kPGCustomStickerCameraCornerLength)];
    
    // top right
    [path moveToPoint:CGPointMake(kPGCustomStickerCameraCornerInset + width, top + kPGCustomStickerCameraCornerLength)];
    [path addLineToPoint:CGPointMake(kPGCustomStickerCameraCornerInset + width, top)];
    [path addLineToPoint:CGPointMake(kPGCustomStickerCameraCornerInset + width - kPGCustomStickerCameraCornerLength, top)];
    
    self.cornerLayer = [CAShapeLayer layer];
    self.cornerLayer.path = path.CGPath;
    self.cornerLayer.lineWidth = kPGCustomStickerCameraCornerWidth;
    self.cornerLayer.lineCap = kCALineCapSquare;
    self.cornerLayer.fillColor = [UIColor clearColor].CGColor;
    self.cornerLayer.strokeColor = [UIColor whiteColor].CGColor;
    
    [view.layer addSublayer:self.cornerLayer];
}

- (void)setupUI
{
    self.legalLabel.delegate = self;

    self.yesButton.layer.cornerRadius = 3.0;
    self.yesButton.layer.borderColor  = [UIColor whiteColor].CGColor;
    self.yesButton.layer.borderWidth = 1.0;
    self.yesButton.layer.masksToBounds = YES;
    
    self.noButton.layer.cornerRadius = 3.0;
    self.noButton.layer.borderColor  = [UIColor whiteColor].CGColor;
    self.noButton.layer.borderWidth = 1.0;
    self.noButton.layer.masksToBounds = YES;
}


#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(__unused TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PGTermsNavigationController"];

    navigationController.topViewController.trackableScreenName = @"Terms of Service Screen";

    [self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - GPUImage

- (GPUImageFilter *)lastFilter
{
    return (GPUImageFilter *)[self.filters lastObject];
}

- (void)setupCamera
{
    self.gpuCleanImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self addMask:self.gpuCleanImageView color:[UIColor colorWithRed:0 green:0 blue:0 alpha:kPGCustomStickerCameraOpacity]];
    [self addCorners:self.gpuCleanImageView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraTapped)];
    [self.gpuCleanImageView addGestureRecognizer:tap];

    self.resultImageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:kPGCustomStickerCameraOpacity];

    if (![self hasCamera]) {
        self.gpuCleanImageView.backgroundColor = [UIColor magentaColor];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.camera = [[GPUImageStillCamera alloc] init];
        self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
        
        [self setupFilters];
        
        [self applyFilterChain:self.filters start:self.camera];
        
        [self.camera addTarget:self.gpuCleanImageView];
        
        [self.camera startCameraCapture];
    });
}

- (void)setupFilters
{
    NSMutableArray<GPUImageOutput *> *filters = [NSMutableArray array];

    self.thresholdFilter = [[GPUImageLuminanceThresholdFilter alloc] init];
    self.thresholdFilter.threshold = kPGCustomerStickerThreshold;
    [filters addObject:self.thresholdFilter];
    
    if (kPGCustomStickerClosingRadius > 0) {
        self.closingFilter = [[GPUImageClosingFilter alloc] initWithRadius:kPGCustomStickerClosingRadius];
        [filters addObject:self.closingFilter];
    }
    
    if (kPGCustomStickerErosionCount > 0) {
        NSMutableArray *erosionFilters = [NSMutableArray array];
        for (int idx = 0; idx < kPGCustomStickerErosionCount; idx++) {
            [erosionFilters addObject:[[GPUImageErosionFilter alloc] initWithRadius:kPGCustomStickerErosionRadius]];
        }
        self.erosionFilters = erosionFilters;
        [filters addObjectsFromArray:self.erosionFilters];
    }
    
    self.invertFilter = [[GPUImageColorInvertFilter alloc] init];
    [filters addObject:self.invertFilter];
    
    self.rgbFilter = [[GPUImageRGBFilter alloc] init];
    [self.rgbFilter setRed:0];
    [self.rgbFilter setBlue:0];
    [self.rgbFilter setGreen:1];
    [filters addObject:self.rgbFilter];

    self.chromaKeyFilter = [[GPUImageChromaKeyFilter alloc] init];
    [self.chromaKeyFilter setColorToReplaceRed:0 green:0 blue:0];
    [filters addObject:self.chromaKeyFilter];
    
    self.monochromeFilter = [[GPUImageMonochromeFilter alloc] init];
    self.monochromeFilter.color = (GPUVector4){ 1, 1, 1, 1 };
    [filters addObject:self.monochromeFilter];

    if ([self hasCamera]) {
        self.cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:[self croppingRect]];
        [filters insertObject:self.cropFilter atIndex:0];
    } else {
        for (GPUImageFilter *filter in self.filters) {
            [filter useNextFrameForImageCapture];
        }
    }

    self.filters = filters;
}

- (void)applyFilterChain:(NSArray<GPUImageOutput *> *)filters start:(GPUImageOutput *)start
{
    NSMutableArray *targets = [NSMutableArray arrayWithArray:filters];
    [targets insertObject:start atIndex:0];
    for (int idx = 0; idx < targets.count - 1; idx ++) {
        GPUImageOutput *output = [targets objectAtIndex:idx];
        id<GPUImageInput> input = [targets objectAtIndex:idx +1];
        [output addTarget:input];
    }
}

- (CGRect)croppingRect
{
    NSDictionary *settings = [[[self.camera.captureSession outputs] firstObject] videoSettings];
    NSNumber *cameraWidth = [settings objectForKey:@"Width"];
    NSNumber *cameraHeight = [settings objectForKey:@"Height"];
    float cameraAspectRatio = fminf([cameraWidth floatValue], [cameraHeight floatValue]) / fmax([cameraWidth floatValue], [cameraHeight floatValue]);

    float containerWidth = self.gpuCleanImageView.bounds.size.width;
    float containerHeight = self.gpuCleanImageView.bounds.size.height;
    float targetSize = containerWidth - 2.0 * kPGCustomStickerCameraInset;

    float viewAspectRatio = containerWidth / containerHeight;
    float x, y, width, height;
    
    if (cameraAspectRatio < viewAspectRatio) {
        float adjustedCameraHeight = containerWidth / cameraAspectRatio;
        x = kPGCustomStickerCameraInset / containerWidth;
        y = ((adjustedCameraHeight - targetSize) / 2.0 - kPGCustomStickerVerticalOffset) / adjustedCameraHeight;
        width = targetSize / containerWidth;
        height = targetSize / adjustedCameraHeight;
    } else {
        float adjustedCameraWidth = containerHeight * cameraAspectRatio;
        x = (adjustedCameraWidth - targetSize) / 2.0 / adjustedCameraWidth;
        y = ((containerHeight - targetSize) / 2.0 - kPGCustomStickerVerticalOffset) / containerHeight;
        width = targetSize / adjustedCameraWidth;
        height = targetSize / containerHeight;
    }
    
    return CGRectMake(x, y, width, height);
}

#pragma  mark - Video

// Adapted from http://stackoverflow.com/questions/35226532/how-to-play-video-inside-a-uiview-without-controls-like-a-background-wallpaper
- (void)setupPlayer
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"stickers" withExtension:@"mp4"];
    self.player = [AVPlayer playerWithURL:url];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.player.muted = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)setupPlayerUI
{
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    layer.frame = self.videoView.bounds;
    layer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self.videoView.layer addSublayer:layer];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoTapped:)];
    [self.videoView addGestureRecognizer:tap];
}

- (void)videoFinished:(NSNotification *)notification {
    [self.player seekToTime:kCMTimeZero];
}

- (void)playVideo
{
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
    self.videoView.alpha = 0.0;
    self.videoView.hidden = NO;
    self.infoButton.superview.userInteractionEnabled = NO;
    [UIView animateWithDuration:kPGCustomStickerAnimationDuration animations:^{
        self.videoView.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.infoButton.superview.userInteractionEnabled = YES;
    }];
}

- (void)hideVideo
{
    [self.player pause];
    
    [UIView animateWithDuration:kPGCustomStickerAnimationDuration animations:^{
        self.videoView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.videoView.hidden = YES;
    }];
}

@end
