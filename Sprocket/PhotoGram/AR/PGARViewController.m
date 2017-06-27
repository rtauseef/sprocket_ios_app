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
    
    [self loadVideoIfAvailable];
    
    CGSize sceneSize = CGSizeMake(1280,720);
    self.layer = [CALayer new];
    self.layer.frame = CGRectMake(0, 0, sceneSize.width, sceneSize.height);
    
    plane.geometry.firstMaterial.diffuse.contents = self.layer;
    particles.emitterShape = pgeo.geometry;

    [[self.node childNodeWithName:@"geo_holder" recursively:YES] addParticleSystem:particles];
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

- (void) loadVideoIfAvailable {
    if (self.media.mediaType == PGMetarMediaTypeVideo) {
       if (self.media.source.from == PGMetarSourceFromLocal) {
            NSString *localId = self.media.source.identifier;
            
            PHFetchResult * assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:nil];
            if( assets.count ) {
                PHAsset * firstAsset = assets[0];
                [self setVideoWithAsset:firstAsset];
            }
        }
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
    
    CGRect bounds = self.targetView.bounds;
    CIImage * image = result.videoFrame;
    CGRect extent = image.extent;
    CGRect rect = AVMakeRectWithAspectRatioInsideRect(bounds.size, extent);
    CIImage * f = [image imageByCroppingToRect:rect];
    f = [f imageByApplyingTransform:CGAffineTransformMakeTranslation(0, -f.extent.origin.y)];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.targetView.context != [EAGLContext currentContext] ) {
            [EAGLContext setCurrentContext:self.targetView.context];
        }
        [self.targetView bindDrawable];
        
        [self renderVideoFrame];
        
        glClearColor(0.5, 0.5, 0.5, 1.0);
        glClear(0x00004000);
        glEnable(0x0BE2);
        
        glBlendFunc(1, 0x0303);
        
        CGRect b = CGRectMake(0,0,self.targetView.drawableWidth,self.targetView.drawableHeight);
        
        [self.ciContext drawImage:f inRect:b fromRect:f.extent];
    
        if( result.transAvailable ) {
            self.node.transform = result.trans;
        }
        
        self.camera.projectionTransform = self.projection;
        
        if(self.firstFrame == nil ) {
            self.firstFrame = [NSDate new];
            self.lastFrame = self.firstFrame;
        }
        
        [self.renderer renderAtTime:-1*self.firstFrame.timeIntervalSinceNow];
        
        
        
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

@end
