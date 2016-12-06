//
//  GroupOperation.m
//  LinkReaderSDK
//
//  Created by Live Paper Pairing on 10/12/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import "GroupOperation.h"
#import "OperationQueue.h"

@interface GroupOperation() <OperationQueueDelegate>

@property OperationQueue *internalQueue;
@property (nonatomic) NSMutableArray *innerOperations;
/*
@property NSBlockOperation *startOperation;
@property NSBlockOperation *finishOperation;
*/
@end

@implementation GroupOperation


- (instancetype)initWithData:(id)operationData queue:(OperationQueue *)queue completion:(BaseOperationCompletion)completion {
    if(self = [super initWithData:operationData queue:queue completion:completion]){
        _internalQueue = [OperationQueue new];
        _internalQueue.suspended = true;
        _internalQueue.delegate = self;
        
        for(NSOperation * operation in [self operationsToBeAddedToGroupInQueue:_internalQueue]){
            [_internalQueue addOperation:operation];
        }
    }
    return self;
}

- (NSArray *)operationsToBeAddedToGroupInQueue:(OperationQueue *)queue {
    return @[];
}

- (void)groupOperationFailureHandler:(NSError *)error {
    if ([self innerOperationsPending]) {
        return;
    }
    [self finishOperationWithData:nil error:error];
}

- (void)groupOperationSuccessHandler:(id) result {
    if ([self innerOperationsPending]) {
        return;
    }
    
    NSError *error = [self innerOperationsError];
    if (error) {
        [self groupOperationFailureHandler:error];
    }
    
    
    [self finishOperationWithData:result error:nil];
}

- (void)addOperation:(NSOperation * )operation {
    [self.internalQueue addOperation:operation];
}


#pragma mark private


- (void)executeOperation {
    self.internalQueue.suspended = false;
}


- (BOOL)innerOperationsPending {
    BOOL pending = NO;
    NSArray *innerOperations = [self innerOperations];
    for (NSOperation * operation in innerOperations) {
        if (![operation isFinished]) {
            pending = YES;
            break;
        }
    }
    return pending;
}

- (NSError *)innerOperationsError {
    NSError *error = nil;
    NSArray *innerOperations = [self innerOperations];
    for (NSOperation * operation in innerOperations) {
        if ([operation isKindOfClass:[BaseOperation class]] && [(BaseOperation *)operation operationError]) {
            error = [(BaseOperation *)operation operationError];
            break;
        }
    }
    return error;
}


- (void)addInnerOperation:(NSOperation *)operation {
    @synchronized(self) {
        if (!self.innerOperations) {
            self.innerOperations = @[].mutableCopy;
        }
        [self.innerOperations addObject:operation];
    }
}

- (NSArray *)getOperations{
    @synchronized(self) {
        return self.innerOperations.copy;
    }
}

#pragma mark <OperationQueueDelegate>

- (void)willAddOperation:(NSOperation *)operation {
    /*
    if (operation != self.startOperation) {
        [operation addDependency:self.startOperation];
    }
     */
    [self addInnerOperation:operation];
}

- (void)didFinishOperation:(NSOperation *)operation {
    /*
    if (operation == self.finishOperation) {
        self.internalQueue.suspended = true;
        [self finishOperation];
    }
     */
}

@end
