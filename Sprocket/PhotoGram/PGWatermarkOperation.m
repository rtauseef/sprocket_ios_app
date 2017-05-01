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

#import "PGWatermarkOperation.h"
#import "PGLinkCredentialsManager.h"

// Used with alejandro.mendez@hp.com -- staging
#define REUSE_TRIGGER false

static int const PGPaperWidthInches = 2;
static int const PGPaperHeightInches = 3;
static int const PGImageDpi = 400;
static int const PGDefaultWpi = 100;
static int const PGDefaultStrength = 10;
static double const PGWatemarkTimeoutSeconds = 30.0;

NSString * const PGWatermarkEmbedderDomain = @"com.hp.sprocket.watermarkembedder";

@implementation PGWatermarkOperationData
@end

@interface PGWatermarkOperation ()

@property (nonatomic) BOOL watermarkingComplete;
@property (nonatomic) NSString *projectId;
@property (nonatomic) LPTrigger *trigger;
@property (nonatomic) LPPayoff *payoff;
@property (nonatomic) LPLink *link;
@property (nonatomic) UIImage *watermarkedImage;
@property (nonatomic) dispatch_queue_t serialWatermarkingQueue;
@property (nonatomic, copy, nullable) void (^progressCallback)(double progress);
@property (nonatomic) double resourceCreationProgress;
@property (nonatomic) double watermarkProgress;

@end


@implementation PGWatermarkOperation


+ (nullable instancetype)executeWithOperationData:(nonnull PGWatermarkOperationData *)operationData progress:(nullable void (^)(double progress))progress completion:(nullable PGWatermarkEmbedderCompletionBlock)completion {
    PGWatermarkOperation *operation = [super executeWithData:operationData completion:completion];
    operation.progressCallback = progress;
    return operation;
}

- (nullable instancetype)initWithOperationData:(nonnull PGWatermarkOperationData *)operationData progress:(nullable void (^)(double progress))progress completion:(nullable PGWatermarkEmbedderCompletionBlock)completion {
    if(self = [self initWithData:operationData completion:completion]){
        _progressCallback = progress;
    };
    return self;
}

- (instancetype)initWithData:(id)operationData completion:(HPLinkBaseOperationCompletion)completion {
    if ([[self class] invalidInputsErrorWithOperatonData:(PGWatermarkOperationData *)operationData completion:completion]) {
        return nil;
    }
    if(self = [super initWithData:operationData completion:completion]){
        dispatch_queue_attr_t queueAttributes = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
        _serialWatermarkingQueue = dispatch_queue_create([PGWatermarkEmbedderDomain UTF8String], queueAttributes);
        self.maxRetryCount = 0;
    }
    return self;
}

+ (BOOL)invalidInputsErrorWithOperatonData:(nonnull PGWatermarkOperationData *)operationData completion:(nullable PGWatermarkEmbedderCompletionBlock)completion {
    NSError *error;
    if (!operationData || ![operationData isKindOfClass:[PGWatermarkOperationData class]]) {
        error = [NSError errorWithDomain:PGWatermarkEmbedderDomain code:PGWatermarkEmbedderErrorInputsError userInfo:@{ NSLocalizedDescriptionKey: @"Invalid operation data."}];
    }
    if (!error && (!operationData.originalImage || ![operationData.originalImage isKindOfClass:[UIImage class]])) {
        error = [NSError errorWithDomain:PGWatermarkEmbedderDomain code:PGWatermarkEmbedderErrorInputsError userInfo:@{ NSLocalizedDescriptionKey: @"Invalid image argument."}];
    }
    if (!error && (!operationData.printerIdentifier || ![operationData.printerIdentifier isKindOfClass:[NSString class]] || operationData.printerIdentifier.length == 0)) {
        error = [NSError errorWithDomain:PGWatermarkEmbedderDomain code:PGWatermarkEmbedderErrorInputsError userInfo:@{ NSLocalizedDescriptionKey: @"Invalid printer identifier argument"}];
    }
    if (error) {
        if (completion) {
            completion(nil, error);
        }
        return YES;
    }
    return NO;
}

- (PGWatermarkOperationData *)operationData {
    return (PGWatermarkOperationData *)[super baseOperationData];
}

-(void)executeOperation {
    if(self.finished){
        return;
    }
#ifdef DEBUG
    NSLog(@"Will start watermarking image for device: %@", [[self baseOperationData] printerIdentifier]);
#endif
    [self setupTimeout];
    NSString *projectId = [self savedProjectIdentifierForSprocket];
#if REUSE_TRIGGER
    projectId = @"MVcZVTa";
#endif
    if (!projectId) {
#ifdef DEBUG
        NSLog(@"Will create project");
#endif
        __weak PGWatermarkOperation *weakSelf = self;
        [LPProject createWithName:[[self baseOperationData] printerIdentifier] session:[[self class] sharedSession] completion:^(LPProject * _Nullable project, NSError * _Nullable error) {
            if (error) {
                [weakSelf handleOperationError:error];
                return;
            }
            [weakSelf setSavedProjectIdentifierForSprocket:project.identifier];
            weakSelf.projectId = project.identifier;
            [weakSelf createLinkObjects];
        }];
    }else{
#ifdef DEBUG
        NSLog(@"Will use existing project: %@", self.projectId);
#endif
        self.projectId = projectId;
        [self createLinkObjects];
    }
}

- (double)timeoutSeconds {
    return PGWatemarkTimeoutSeconds;
}

- (void)setupTimeout {
    __weak PGWatermarkOperation *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, [self timeoutSeconds] * NSEC_PER_SEC), self.serialWatermarkingQueue, ^{
        if (weakSelf && !weakSelf.watermarkingComplete && !weakSelf.finished) {
            [self cancel];
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Watermarking took too long."};
            NSError * error = [NSError errorWithDomain:PGWatermarkEmbedderDomain code:PGWatermarkEmbedderWatermarkingTimeout userInfo:userInfo];
            [self finishOperationWithData:nil error:error];
        }
    });
}

- (void)updateProgress {
    if (self.progressCallback && !self.finished) {
        NSLog(@"resource %f watermark %f",self.resourceCreationProgress, self.watermarkProgress);
        self.progressCallback(self.resourceCreationProgress * 0.3 + self.watermarkProgress * 0.7);
    }
}

- (void)createLinkObjects {
    if(self.finished){
        return;
    }
#ifdef DEBUG
    NSLog(@"Watermarking image using project: %@", self.projectId);
#endif
    __weak PGWatermarkOperation *weakSelf = self;
    
#if REUSE_TRIGGER
    [LPTrigger get:@"GhFeMQlkQImcvqEIpLB_Nw" projectId:self.projectId session:[[self class] sharedSession] completion:^(LPTrigger *trigger, NSError *error) {
#else
        [LPTrigger createWatermarkWithName:[[self baseOperationData] printerIdentifier] projectId:self.projectId session:[[self class] sharedSession] completion:^(LPTrigger *trigger, NSError *error) {
#endif
            if (error) {
                [weakSelf handleOperationError:error];
                return;
            }
            self.resourceCreationProgress += 0.33;
            [self updateProgress];
#ifdef DEBUG
            NSLog(@"Watermarking image using trigger: %@", trigger.identifier);
#endif
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
                [weakSelf watermarkImageWithTrigger:trigger];
            });
            [weakSelf dispatchInSerial:^{
                weakSelf.trigger = trigger;
                [weakSelf createLink];
            }];
        }];
        [LPPayoff createWebPayoffWithName:[[self baseOperationData] printerIdentifier] url:[[self baseOperationData] payoffURL] projectId:self.projectId session:[[self class] sharedSession] completion:^(LPPayoff *payoff, NSError *error) {
            if (error) {
                [weakSelf handleOperationError:error];
                return;
            }
            self.resourceCreationProgress += 0.33;
            [self updateProgress];
#ifdef DEBUG
            NSLog(@"Watermarking image using payoff: %@", payoff.identifier);
#endif
            [weakSelf dispatchInSerial:^{
                weakSelf.payoff = payoff;
                [weakSelf createLink];
            }];
        }];
        
    }
     
     - (void)createLink {
         if(self.finished || !self.trigger || !self.payoff){
             return;
         }
         __weak PGWatermarkOperation *weakSelf = self;
         [LPLink createWithName:[[self baseOperationData] printerIdentifier] triggerId:self.trigger.identifier payoffId:self.payoff.identifier projectId:self.projectId session:[[self class] sharedSession] completion:^(LPLink *link, NSError *error) {
             if (error) {
                 [weakSelf handleOperationError:error];
                 return;
             }
             self.resourceCreationProgress += 0.34;
             [self updateProgress];
#ifdef DEBUG
             NSLog(@"Watermarking image using link: %@", link.identifier);
#endif
             [weakSelf dispatchInSerial:^{
                 weakSelf.link = link;
                 [weakSelf finishOperationWhenWatermarkingDone];
             }];
         }];
     }
     
     - (void)watermarkImageWithTrigger:(LPTrigger *)trigger {
         if(self.finished){
             return;
         }
         int desiredImageWidth = PGImageDpi * PGPaperWidthInches;
         int desiredImageHeight = PGImageDpi * PGPaperHeightInches;
         UIImage *resizedImage = [self imageWithImage:[[self baseOperationData] originalImage] scaledToSize:CGSizeMake(desiredImageWidth, desiredImageHeight)];
         NSData *imageData = UIImageJPEGRepresentation(resizedImage, 1.0);
         __weak PGWatermarkOperation *weakSelf = self;
         [trigger getWatermarkForImageData:imageData strength:PGDefaultStrength watermarkResolution:PGDefaultWpi imageResolution:PGImageDpi adjustImageLevels:YES progress:^(double progress) {
             NSLog(@"wm progress: %f",progress);
             self.watermarkProgress = progress;
             [self updateProgress];
         } completion:^(UIImage *image, NSError *error) {
             if (error) {
                 [weakSelf handleOperationError:error];
                 return;
             }
             self.watermarkProgress = 1.0;
             [self updateProgress];
             [weakSelf dispatchInSerial:^{
                 weakSelf.watermarkedImage = image;
                 [weakSelf finishOperationWhenWatermarkingDone];
             }];
         }];
     }
     
     - (void)finishOperationWhenWatermarkingDone {
         if(self.finished || !self.link || !self.watermarkedImage){
             return;
         }
         self.watermarkingComplete = YES;
#ifdef DEBUG
         NSLog(@"Successfully watemarked image with trigger: %@", self.trigger.identifier);
#endif
         self.watermarkProgress = 1.0;
         self.resourceCreationProgress = 1.0;
         [self updateProgress];
         [self finishOperationWithData:self.watermarkedImage error:nil];
     }
     
#pragma mark Helper methods
     
     - (void)dispatchInSerial:(void (^)())block {
         if (block) {
             dispatch_async(self.serialWatermarkingQueue, ^{
                 block();
             });
         }
     }
     
     - (void)handleOperationError:(NSError *)error {
         NSString *errorMessage = @"Error while watemarking image";
         if (error.userInfo[NSLocalizedDescriptionKey]) {
             errorMessage = [errorMessage stringByAppendingFormat:@": %@", error.userInfo[NSLocalizedDescriptionKey]];
         }
#ifdef DEBUG
         NSLog(@"Error while watermarking: %@", errorMessage);
#endif
         NSInteger errorCode = error.code;
         if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorNotConnectedToInternet) {
             // TODO:jbt: set proper error message here
             errorCode = PGWatermarkEmbedderErrorWatermarkingImageNoInternet;
         }else{
             errorCode = PGWatermarkEmbedderErrorWatermarkingImage;
         }
         NSError * operationError = [NSError errorWithDomain:PGWatermarkEmbedderDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
         [self finishOperationWithData:nil error:operationError];
     }
     
     - (NSString *)savedProjectIdentifierForSprocket {
         return [[NSUserDefaults standardUserDefaults] objectForKey:[self savedProjectKey]];
     }
     
     - (void)setSavedProjectIdentifierForSprocket:(NSString *)projectIdentifier {
         [[NSUserDefaults standardUserDefaults] setObject:projectIdentifier forKey:[self savedProjectKey]];
         [[NSUserDefaults standardUserDefaults] synchronize];
     }
     
     - (NSString *)savedProjectKey {
         return [NSString stringWithFormat:@"%@:%@:%@:%@",PGWatermarkEmbedderDomain, [PGLinkCredentialsManager stackString], [PGLinkCredentialsManager clientId], [[self baseOperationData] printerIdentifier]];
     }
     
     - (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
         UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
         [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
         UIImage *linkIcon = [UIImage imageNamed:@"link-icon" inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil];
         int linkIconSize = 100;
         int linkIconMargin = 0;
         [linkIcon drawInRect:CGRectMake(newSize.width - linkIconSize - linkIconMargin, newSize.height - linkIconSize - linkIconMargin, linkIconSize, linkIconSize)];
         UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
         return newImage;
     }
     
     + (LPSession *)sharedSession {
         static LPSession *sharedSession = nil;
         static dispatch_once_t onceToken;
         dispatch_once(&onceToken, ^{
             sharedSession = [LPSession createSessionWithClientId:[PGLinkCredentialsManager clientId] secret:[PGLinkCredentialsManager clientSecret] stack:[PGLinkCredentialsManager stack]];
         });
         return sharedSession;
     }
     
     @end
