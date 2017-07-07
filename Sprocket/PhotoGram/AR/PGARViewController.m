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

#import "PGARViewController.h"
#import <GLKit/GLKit.h>
#import "PGARLiveProcessor.h"
#import "PGCameraManager.h"
#import "PGARVideoProcessor.h"
#import "PGLinkSettings.h"
#import "PGMetarPayoffViewController.h"

@interface PGARViewController ()

@property (weak, nonatomic) IBOutlet GLKView *targetView;
@property NSDate * firstFrame;
@property CIContext * ciContext;
@property SCNRenderer * renderer;
@property SCNNode * node;
@property SCNCamera * camera;
@property NSDate * lastFrame;
@property CALayer * layer;
@property AVPlayerItemVideoOutput * videoOutput;
@property AVPlayer *player;

- (IBAction)tapDismissButton:(id)sender;

@end

@implementation PGARViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    self.targetView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    self.ciContext = [CIContext contextWithEAGLContext:self.targetView.context];
    [self prepare];
}

- (void)prepare {
    // start scene kit stuff
    SCNRenderer * renderer = [SCNRenderer rendererWithContext:self.targetView.context options:nil];
    SCNScene * scene = [SCNScene sceneNamed:@"myscene.scn"];
    renderer.scene = scene;
    
    self.node = [scene.rootNode childNodeWithName:@"boxh" recursively:YES];
    SCNNode * node = [scene.rootNode childNodeWithName:@"camera" recursively:YES];
    self.camera = node.camera;
    self.renderer = renderer;
    SCNParticleSystem * particles = [SCNParticleSystem particleSystemNamed:@"particles.scnp" inDirectory:nil];
    SCNNode * pgeo = [self.node childNodeWithName:@"emission_geo" recursively:YES];
    SCNNode * plane = [self.node childNodeWithName:@"plane" recursively:YES];
    plane.hidden = NO;
    
    CGSize sceneSize = CGSizeMake(1280,720);
    self.layer = [CALayer new];
    self.layer.frame = CGRectMake(0, 0, sceneSize.width, sceneSize.height);
    
    plane.geometry.firstMaterial.diffuse.contents = self.layer;
    particles.emitterShape = pgeo.geometry;

    [self loadVideoIfAvailable:^(BOOL hasVideo) {
        if ((hasVideo && [PGLinkSettings videoARParticlesEnabled]) || !hasVideo) {
            [[self.node childNodeWithName:@"geo_holder" recursively:YES] addParticleSystem:particles];
        }
    }];
}

- (void) setVideoWithAsset: (PHAsset *) asset {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * avasset, AVAudioMix * audioMix, NSDictionary * info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:avasset];
            
            if (item) {
                self.videoOutput = [[AVPlayerItemVideoOutput alloc]
                                                    initWithOutputSettings:@{
                                                                             (NSString*)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32ARGB),
                                                                             (NSString*)kCVPixelBufferCGImageCompatibilityKey : @(YES),
                                                                             (NSString*)kCVPixelBufferOpenGLESCompatibilityKey : @(YES)
                                                                             }];
                
                self.player = [AVPlayer playerWithPlayerItem:item];
                [item addOutput:self.videoOutput];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
                
                [self.player play];
            }
        });
    }];
}

- (void) loadVideoIfAvailable: (void(^)(BOOL hasVideo)) completion {
    if (self.media.mediaType == PGMetarMediaTypeVideo) {
       if (self.media.source.from == PGMetarSourceFromLocal) {
            NSString *localId = self.media.source.identifier;
            
            PHFetchResult * assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:nil];
            if( assets.count ) {
                PHAsset * firstAsset = assets[0];
                [self setVideoWithAsset:firstAsset];
                completion(YES);
            } else {
                completion(NO);
            }
       } else {
           completion(NO);
       }
    } else {
        completion(NO);
    }
}

-(CVPixelBufferRef) currentVideoFrame {
    if( self.player.currentItem.status == AVPlayerItemStatusReadyToPlay ) {
        return [self.videoOutput copyPixelBufferForItemTime:self.player.currentItem.currentTime itemTimeForDisplay:nil];
    } else {
        return nil;
    }
}

-(void) renderVideoFrame {
    CVPixelBufferRef pixelBuffer = [self currentVideoFrame];
    if( pixelBuffer != nil ) {
        
        
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        
        size_t width = CVPixelBufferGetWidth(pixelBuffer);
        size_t height = CVPixelBufferGetHeight(pixelBuffer);
        void * pixels = CVPixelBufferGetBaseAddress(pixelBuffer);
        
        CGDataProviderRef pixelWrapper = CGDataProviderCreateWithData(nil, pixels, CVPixelBufferGetDataSize(pixelBuffer), nil);
        
        // Get a color-space ref... can't this be done only once?
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        
        // Get a CGImage from the data (the CGImage is used in the drawLayer: delegate method above)
        int bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipFirst;
        
        //        CGBitmapInfo(rawValue: CGImageAlphaInfo.NoneSkipFirst.rawValue)
        CGImageRef currentCGImage = CGImageCreate(width,
                                                  height,
                                                  8,
                                                  32,
                                                  4 * width,
                                                  colorSpaceRef, bitmapInfo,
                                                  pixelWrapper,
                                                  nil,
                                                  false,
                                                  kCGRenderingIntentDefault);
        if( currentCGImage ) {
            self.layer.contents = (__bridge id _Nullable)(currentCGImage);
            CGImageRelease(currentCGImage);
        }
        
        // Clean up
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        CVPixelBufferRelease(pixelBuffer);
    }
    
}

-(void) render:(PGARVideoProcessorResult *) result {
    if (!self.ciContext) {
        return;
    }
    
    CIImage * image = result.videoFrame;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.targetView.context != [EAGLContext currentContext] ) {
            [EAGLContext setCurrentContext:self.targetView.context];
        }
        [self.targetView bindDrawable];
        
        [self renderVideoFrame];
        
        CGRect calc = [PGARVideoProcessor calcTargetVideoRect:image.extent.size inView:CGSizeMake(self.targetView.drawableWidth,self.targetView.drawableHeight)];
        [self.ciContext drawImage:image inRect:calc fromRect:image.extent];
    
        [SCNTransaction begin];
        [SCNTransaction setDisableActions:YES];
        
        if( result.detected ) {
            self.node.hidden = NO;
            if( result.transAvailable ) {
                self.node.transform = result.trans;
                // [SCNTransaction setDisableActions:YES];
            }
        } else {
            self.node.hidden = YES;
        }
        
        [SCNTransaction commit];
        
        self.camera.projectionTransform = self.projection;
        
        if(self.firstFrame == nil ) {
            self.firstFrame = [NSDate new];
            self.lastFrame = self.firstFrame;
        }
        
        [self.renderer renderAtTime:[NSDate timeIntervalSinceReferenceDate]];
        [self.targetView display];
        
        //[self.delegate didUpdateFps: -1.0f/self.lastFrame.timeIntervalSinceNow];
        self.lastFrame = [NSDate new];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark PGARLiveProcessorDelegate

- (void)displayImage:(PGARVideoProcessorResult *)res {
    [self render:res];
}

#pragma mark Video Player Observer

-(void) playerItemDidPlayToEndTime:(NSNotification*) not {
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

- (IBAction)tapDismissButton:(id)sender {
    [[PGCameraManager sharedInstance] stopARExp];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)tapSeeMoreButton:(id)sender {
    PGMetarPayoffViewController *metarViewController = [[PGMetarPayoffViewController alloc] initWithNibName:@"PGMetarPayoffViewController" bundle:nil];
    [metarViewController setMetarMedia:self.media];
    [self presentViewController:metarViewController animated:YES completion:nil];
}

@end
