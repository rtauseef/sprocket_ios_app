//
//  PGPayoffProcessor.m
//  Sprocket
//
//  Created by Bruno Dal Bo on 4/17/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGPayoffProcessor.h"
#import "PGWatermarkOperation.h"
#import "PGPayoffManager.h"
#import "PGOfflinePayoffDatabase.h"


@interface PGPayoffProcessor()
@property (assign, nonatomic) BOOL finishedWatermarking;
@end

@implementation PGPayoffProcessor



- (NSString *)name
{
    return NSLocalizedString(@"Watermark", @"payoff processor watermark title");
}

- (NSString *)progressText
{
    return NSLocalizedString(@"Watermarking image",@"payoff processor watermark description");
}

- (BOOL)completed
{
    return self.finishedWatermarking;
}


- (void)processImage:(UIImage *)image withOptions:(NSDictionary *)options {
    PGWatermarkOperationData *operationData = [PGWatermarkOperationData new];
    operationData.originalImage = image;
    operationData.printerIdentifier = options[kMPBTImageProcessorPrinterSerialNumberKey];
    operationData.payoffURL = [[PGPayoffManager sharedInstance] createURLWithPayoff:self.metadata];
    [PGWatermarkOperation executeWithOperationData:operationData progress:^(double progress) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateProgress:progress:)]) {
            [self.delegate didUpdateProgress:self progress:progress];
        }
    } completion:^(UIImage * _Nullable outputImage, NSError * _Nullable error) {
        self.finishedWatermarking = YES;
        // created trigger on backend, we can save the watermark to local database if no errors occurred.
        if( (!error) && outputImage ) {
            [[PGOfflinePayoffDatabase sharedInstance] saveMetadata:self.metadata];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(didCompleteProcessing:result:error:)]) {
            [self.delegate didCompleteProcessing:self result:outputImage error:error];
        }
    }];
}


- (instancetype)initWithMetadata:(PGPayoffMetadata *)metadata {
    self = [super init];
    if (self) {
        self.metadata = metadata;
    }

    return self;
}

+ (instancetype)processorWithMetadata:(PGPayoffMetadata *)metadata {
    return [[self alloc] initWithMetadata:metadata];
}


@end
