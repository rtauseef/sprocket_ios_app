//
//  PGWatemarkImageOperation.m
//  Sprocket
//
//  Created by Live Paper Pairing on 12/6/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import "PGWatemarkImageOperation.h"

#import <LivePaperSDK/LivePaperSDK.h>

static int const PGPaperWidthInches = 2;
static int const PGPaperHeightInches = 3;
static int const PGImageDpi = 400;
static int const PGDefaultWpi = 100;
static int const PGDefaultStrength = 10;
static int const PGWatemarkTimeoutSeconds = 20;
static NSString *const LPPTriggerId = @"X6pPJD05STylmDKJq0bLLg";
static NSString *const LPPClientId = @"zw8lqipzac58kuaoj0kr6t50an0jbwxl"; //hpreveal+sprocket@gmail.com
static NSString *const LPPClientSecret = @"DllRm10LCt87IDOGCKYBxnwYltFcSNJ6";
static NSString *const PGWatermarkEmbedderErrorDomain = @"com.hp.sprocket.watermarkembedder";

@interface PGWatemarkImageOperation ()

@property (strong, nonatomic) LPSession *lpSession;
@property (nonatomic) BOOL watermarkingCancelled;
@property (nonatomic) BOOL watermarkingComplete;

@end


@implementation PGWatemarkImageOperation


+ (nullable instancetype)executeWithImage:(nonnull UIImage *)image completion:(nullable PGWatermarkEmbedderCompletionBlock)completion {
    return [super executeWithData:image completion:^(id data, NSError *error) {
        if(completion){
            completion(data, error);
        }
    }];
}

- (nullable instancetype)initWithImage:(nonnull UIImage *)image queue:(nonnull OperationQueue *)queue completion:(nullable PGWatermarkEmbedderCompletionBlock)completion {
    return [super initWithData:image queue:queue completion:^(id data, NSError *error) {
        if (completion) {
            completion(data, error);
        }
    }];
}

- (UIImage *)originalImage {
    return (UIImage *)[super baseOperationData];
}

-(void)executeOperation {
    if(self.finished){
        return;
    }
    
    int desiredImageWidth = PGImageDpi * PGPaperWidthInches;
    int desiredImageHeight = PGImageDpi * PGPaperHeightInches;
    UIImage *resizedImage = [self imageWithImage:[self originalImage] scaledToSize:CGSizeMake(desiredImageWidth, desiredImageHeight)];
    
    __weak PGWatemarkImageOperation *weakSelf = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, PGWatemarkTimeoutSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (weakSelf && !weakSelf.watermarkingComplete) {
            [self cancel];
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Watermarking took too long."};
            NSError * error = [NSError errorWithDomain:PGWatermarkEmbedderErrorDomain code:PGWatermarkEmbedderWatermarkingTimeout userInfo:userInfo];
            [self finishOperationWithData:nil error:error retry:NO];
        }
    });
    
    [LPTrigger get:[[self class] sharedSession] triggerId:LPPTriggerId completionHandler:^(LPTrigger *trigger, NSError *error) {
        NSData *imageData = UIImageJPEGRepresentation(resizedImage, 1.0);
        [trigger getWatermarkForImageData:imageData strength:PGDefaultStrength watermarkResolution:PGDefaultWpi imageResolution:PGImageDpi completionHandler:^(UIImage *image, NSError *error) {
            if(self.cancelled){
                return;
            }
            self.watermarkingComplete = YES;
            if (error) {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Error while watemarking image"};
                NSError * error = [NSError errorWithDomain:PGWatermarkEmbedderErrorDomain code:PGWatermarkEmbedderErrorWatermarkingImage userInfo:userInfo];
                [self finishOperationWithData:nil error:error];
            }else{
                [self finishOperationWithData:image error:nil];
            }
        }];
    }];
}

#pragma mark Helper methods

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *linkIcon = [UIImage imageNamed:@"link-icon"];
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
        sharedSession = [LPSession createSessionWithClientID:LPPClientId secret:LPPClientSecret];
    });
    return sharedSession;
}

@end
