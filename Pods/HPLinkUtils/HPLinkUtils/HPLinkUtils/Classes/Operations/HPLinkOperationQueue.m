//
//  OperationQueue.m
//  LinkReaderSDK
//
//  Created by Alejandro Mendez on 10/12/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import "HPLinkOperationQueue.h"
#import "HPLinkBaseOperation+Private.h"

@implementation HPLinkOperationQueue


+(instancetype)sharedQueue {
    static HPLinkOperationQueue *sharedQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedQueue = [[self alloc] init];
    });
    return sharedQueue;
}

-(void)addOperation:(NSOperation *)op {
    
    if ([op isKindOfClass:[HPLinkBaseOperation class]]) {
        HPLinkBaseOperation *baseOperation = (HPLinkBaseOperation *)op;
        NSArray *dependencies = [baseOperation determineOperationDependencies];
        for (NSOperation *dependency in dependencies) {
            [baseOperation addDependency:dependency];
            [self addOperation:dependency];
        }        
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
