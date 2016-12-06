//
//  BaseCompletionOperation.m
//  LinkReaderSDK
//
//  Created by Live Paper Pairing on 10/14/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import "BaseCompletionOperation.h"

@implementation BaseCompletionOperation

+ (instancetype)executeWithData:(id)operationData completion:(BaseOperationCompletion)completion {
    
    BaseCompletionOperation *operation = [[[self class] alloc] initWithData:operationData queue:[OperationQueue sharedQueue] completion:completion];
    [operation addDependenciesToQueue:[OperationQueue sharedQueue]];
    [[OperationQueue sharedQueue] addOperation:operation];
    return operation;
}

- (instancetype)initWithData:(id)operationData queue:(OperationQueue *)queue completion:(BaseOperationCompletion)completion {
    if (self = [super initWithQueue:queue]) {
        self.baseCompletion = completion;
        self.baseOperationData = operationData;
    }
    return self;
}

-(void)finishOperationWithData:(id)data error:(NSError *)error{
    [self finishOperationWithData:data error:error retry:YES];
}

-(void)finishOperationWithData:(id)data error:(NSError *)error retry:(BOOL)retry{
    if (error) {
        if (retry && [super retryOperation]) {
            return;
        }
    }
    self.operationResult = data;
    if (self.baseCompletion) {
        self.baseCompletion(data, error);
    }
    [super finishOperation:error];
}


-(void)executeOperation {
    [super executeOperation];
    NSError *dependenciesError = [self dependenciesError];
    if(dependenciesError){
        [self finishOperationWithData:nil error:dependenciesError];
    }
}

@end
