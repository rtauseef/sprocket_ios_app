//
//  BaseOperation.m
//  LinkReaderSDK
//
//  Created by Live Paper Pairing on 10/12/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import "BaseOperation.h"
#import "OperationQueue.h"


NSString * const KVOPropertyIsFinished = @"isFinished";
NSString * const KVOPropertyIsExecuting = @"isExecuting";

@interface BaseOperation () {
    BOOL executing;
    BOOL finished;
}

@end

@implementation BaseOperation

-(instancetype)initWithQueue:(OperationQueue *)queue
{
    if (self = [super init])
    {
        _operationQueue = queue;
        executing = NO;
        finished = NO;
        _maxRetryCount = 3;        
    }
    return self;
}

- (void)setupOperation {
    
}

- (NSArray *)getDependencies{
    return @[];    
}

- (void)addDependenciesToQueue:(OperationQueue *)queue {
    NSArray *dependencies = [self getDependencies];
    for (NSOperation *dependency in dependencies) {
        [self addDependency:dependency];
        [queue addOperation:dependency];
    }
}

-(void)start
{
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

-(void)main
{
    //This is the method that will do the work
    @try {
        NSLog(@"Custom Operation - Main Method isMainThread?? ANS = %@",[NSThread isMainThread]? @"YES":@"NO");
        NSLog(@"Custom Operation - Main Method [NSThread currentThread] %@",[NSThread currentThread]);
        NSLog(@"Custom Operation - Main Method Try Block - Do Some work here");
        [self setupOperation];
        [self performOrRetryOperation];
        
    }
    @catch (NSException *exception) {
        NSLog(@"Catch the exception %@",[exception description]);
    }
    @finally {
        NSLog(@"Custom Operation - Main Method - Finally block");
    }
}

- (NSError *)dependenciesError {
    NSError *error = nil;
    for (NSOperation *operation in self.dependencies) {
        if ([operation isKindOfClass:[BaseOperation class]]) {
            error = [(BaseOperation*)operation operationError];
            if (error) {
                break;
            }
        }
    }
    return error;
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

- (void)executeOperation {
    
}

- (BOOL)retryOperation {
    return [self performOrRetryOperation];
}

- (BOOL)performOrRetryOperation {
    if(self.retryCount <= self.maxRetryCount) {
        self.retryCount++;
        [self executeOperation];
        return YES;
    }
    return NO;
}

-(BOOL)isConcurrent
{
    return YES;    //Default is NO so overriding it to return YES;
}

-(BOOL)isExecuting{
    return executing;
}

-(BOOL)isFinished{
    return finished;
}
@end
