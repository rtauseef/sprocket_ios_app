//
//  OperationQueue.m
//  LinkReaderSDK
//
//  Created by Live Paper Pairing on 10/12/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import "OperationQueue.h"
#import "BaseOperation.h"

@implementation OperationQueue


+(instancetype)sharedQueue {
    static OperationQueue *sharedQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedQueue = [[self alloc] init];
    });
    return sharedQueue;
}

-(void)addOperation:(NSOperation *)op {
    
    if ([op isKindOfClass:[BaseOperation class]]) {
        BaseOperation *baseOperation = (BaseOperation *)op;
        baseOperation.operationQueue = self;
    }
    
    if([self.delegate respondsToSelector:@selector(willAddOperation:)]){
        [self.delegate willAddOperation:op];
    }
    
    if([self.delegate respondsToSelector:@selector(didFinishOperation:)]){
        __weak NSOperation *weakOperation = op;
        op.completionBlock = ^void(void){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didFinishOperation:weakOperation];
            });
            
        };
    }
    
    [super addOperation:op];
}

@end
