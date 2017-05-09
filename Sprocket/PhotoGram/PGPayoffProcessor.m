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

#import "PGPayoffProcessor.h"
#import "PGWatermarkOperationHPLink.h"
#import "PGWatermarkOperationHPMetar.h"
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
    
    // TODO: this should be according to the selected printer
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(640, 960), NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, 640, 960)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    operationData.originalImage = newImage;
    
    operationData.localOperationIdentifier = options[kMPBTImageProcessorPrinterSerialNumberKey];
    operationData.printerIdentifier = options[kMPBTImageProcessorPrinterSerialNumberKey];

    
    if( ! operationData.localOperationIdentifier ) { // printer Serial  may not be available when processor runs
        operationData.localOperationIdentifier = [NSString stringWithFormat:@"L-Payoff-%@",options[kMPBTImageProcessorLocalIdentifierKey]];
        operationData.printerIdentifier =  operationData.localOperationIdentifier;
    }
    
    operationData.metadata = self.metadata;
    //operationData.payoffURL = [[PGPayoffManager sharedInstance] createURLWithPayoff:self.metadata];
    
    // changed from Link to Metar
    [PGWatermarkOperationHPMetar executeWithOperationData:operationData progress:^(double progress) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateProgress:progress:)]) {
            [self.delegate didUpdateProgress:self progress:progress];
        }
    } completion:^(UIImage * _Nullable outputImage, NSError * _Nullable error) {
        self.finishedWatermarking = YES;
        // created trigger on backend, we can save the watermark to local database if no errors occurred.
        if( (!error) && outputImage ) {
            //[[PGOfflinePayoffDatabase sharedInstance] saveMetadata:self.metadata];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(didCompleteProcessing:result:error:)]) {
            [self.delegate didCompleteProcessing:self result:outputImage error:error];
        }
    }];
}


- (instancetype)initWithMetadata:(PGMetarMedia *)metadata {
    self = [super init];
    if (self) {
        self.metadata = metadata;
    }

    return self;
}

+ (instancetype)processorWithMetadata:(PGMetarMedia *)metadata {
    return [[self alloc] initWithMetadata:metadata];
}


@end
