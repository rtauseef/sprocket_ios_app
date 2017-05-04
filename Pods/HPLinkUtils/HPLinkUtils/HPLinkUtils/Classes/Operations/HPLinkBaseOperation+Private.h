//
//  HPLinkBaseOperation+Private.h
//  HPLinkUtils
//
//  Created by Alejandro Mendez on 3/10/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <HPLinkUtils/HPLinkBaseOperation.h>

@interface HPLinkBaseOperation (Private)

@property (nonatomic, readonly, nullable) NSError *operationError;
@property (nonatomic, readonly) int retryCount;
@property (nonatomic, readonly, weak, nullable) NSOperationQueue *operationQueue;

@end

@interface HPLinkBaseOperation ()

@property (nonatomic) int maxRetryCount;

- (nonnull NSArray *)dependenciesErrors;

- (BOOL)retryOperation;

- (BOOL)canRetry;

- (void)finishOperation:(nullable NSError *)error;

// To be overriden by subclasses

- (nonnull NSArray *)determineOperationDependencies;

- (void)setupOperation;

- (void)executeOperation;

- (void)handleDependenciesError;

@end
