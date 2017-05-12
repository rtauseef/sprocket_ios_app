//
//  HPLinkBaseCompletionOperation.m
//  LinkReaderSDK
//
//  Created by Alejandro Mendez on 10/14/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import <HPLinkUtils/HPLinkBaseCompletionOperation+Private.h>

@implementation HPLinkBaseCompletionOperation

+ (instancetype)executeWithData:(id)operationData completion:(HPLinkBaseOperationCompletion)completion {
    
    HPLinkBaseCompletionOperation *operation = [[[self class] alloc] initWithData:operationData completion:completion];
    [[HPLinkOperationQueue sharedQueue] addOperation:operation];
    return operation;
}

- (instancetype)initWithData:(id)operationData completion:(HPLinkBaseOperationCompletion)completion {
    if (self = [super init]) {
        self.baseCompletion = completion;
        self.baseOperationData = operationData;
    }
    return self;
}

-(void)finishOperationWithData:(id)data error:(NSError *)error{
    if (error) {
        if ([super retryOperation]) {
            return;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.baseCompletion) {
            self.baseCompletion(data, error);
        }
        self.baseCompletion = nil;
    });
    [super finishOperation:error];
}

-(void)handleDependenciesError {
    [self finishOperationWithData:nil error:[[self dependenciesErrors] firstObject]];
}

@end
