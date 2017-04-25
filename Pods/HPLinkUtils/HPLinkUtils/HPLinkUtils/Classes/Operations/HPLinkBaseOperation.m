//
//  HPLinkBaseOperation.m
//  LinkReaderSDK
//
//  Created by Alejandro Mendez on 10/12/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import "HPLinkBaseOperation+Private.h"
#import "HPLinkOperationQueue.h"

@interface HPLinkBaseOperation () {
    BOOL executing;
    BOOL finished;
}
@property (nonatomic) NSError *operationError;
@property (nonatomic) int retryCount;
@property (nonatomic, weak) NSOperationQueue *operationQueue;

@end

@implementation HPLinkBaseOperation

-(instancetype)init
{
    if (self = [super init])
    {
        _maxRetryCount = 3;
        executing = NO;
        finished = NO;
    }
    return self;
}

- (void)setupOperation {
    
}

- (NSArray *)determineOperationDependencies{
    return @[];    
}

-(void)start
{
    if ([self isCancelled])
    {
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

-(void)main
{
    @try {
        [self setupOperation];
        [self performOrRetryOperation];
    }
    @catch (NSException *exception) {
        NSLog(@"HPLinkBaseOperation exception: %@",[exception description]);
    }
}

- (NSArray *)dependenciesErrors {
    NSMutableArray *errors = @[].mutableCopy;
    NSError *error = nil;
    for (NSOperation *operation in self.dependencies) {
        if ([operation isKindOfClass:[HPLinkBaseOperation class]]) {
            error = [(HPLinkBaseOperation*)operation operationError];
            if (error) {
                [errors addObject:error];
            }
        }
    }
    return errors;
}

-(void)finishOperation:(NSError *)error {
    
    self.operationError = error;
    
    [self willChangeValueForKey:@"isExecuting"];
    executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    finished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

-(void)finishOperation {
    [self finishOperation:nil];
}

- (void)handleDependenciesError {
    [self finishOperation:[[self dependenciesErrors] firstObject]];
}

- (BOOL)retryOperation {
    return [self performOrRetryOperation];
}

- (void)executeOperation {
    
}

- (BOOL)canRetry {
    return self.retryCount <= self.maxRetryCount;
}

- (BOOL)performOrRetryOperation {
    if([self canRetry]) {
        self.retryCount++;
        NSError *dependenciesError = [[self dependenciesErrors] firstObject];
        if(dependenciesError){
            [self handleDependenciesError];
        }else{
            [self executeOperation];
        }
        return YES;
    }
    return NO;
}

-(BOOL)isConcurrent {
    return YES;
}

-(BOOL)isExecuting {
    return executing;
}

-(BOOL)isFinished {
    return finished;
}
@end
