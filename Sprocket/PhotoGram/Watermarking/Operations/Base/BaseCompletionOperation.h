//
//  BaseCompletionOperation.h
//  LinkReaderSDK
//
//  Created by Live Paper Pairing on 10/14/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import "BaseOperation.h"

typedef void (^BaseOperationCompletion)(id data, NSError* error);

@interface BaseCompletionOperation : BaseOperation

@property (nonatomic) id baseOperationData;
@property (nonatomic) BaseOperationCompletion baseCompletion;

+ (instancetype)executeWithData:(id)operationData completion:(BaseOperationCompletion)completion;

- (instancetype)initWithData:(id)operationData queue:(OperationQueue *)queue completion:(BaseOperationCompletion)completion;
- (instancetype)initWithQueue:(OperationQueue *)queue NS_UNAVAILABLE;

- (void)finishOperationWithData:(id)data error:(NSError *)error;
- (void)finishOperationWithData:(id)data error:(NSError *)error retry:(BOOL)retry;
- (void)finishOperation:(NSError *)error NS_UNAVAILABLE;

- (BOOL)retryOperation NS_UNAVAILABLE;

@end
