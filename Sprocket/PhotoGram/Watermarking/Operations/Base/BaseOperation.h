//
//  LinkReaderSDK
//
//  Created by Live Paper Pairing on 10/12/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OperationQueue.h"

@interface BaseOperation : NSOperation

@property (nonatomic, weak) OperationQueue *operationQueue;
@property (nonatomic) NSError *operationError;
@property (nonatomic) id operationResult;
@property (nonatomic) int retryCount;
@property (nonatomic) int maxRetryCount;


- (instancetype)initWithQueue:(OperationQueue *)queue;

- (NSArray *)getDependencies;

- (void)addDependenciesToQueue:(OperationQueue *)queue;

- (NSError *)dependenciesError;

- (void)setupOperation;

- (void)executeOperation;

- (BOOL)retryOperation;

- (void)finishOperation:(NSError *)error;

@end
