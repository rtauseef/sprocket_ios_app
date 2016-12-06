//
//  OperationQueue.h
//  LinkReaderSDK
//
//  Created by Live Paper Pairing on 10/12/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OperationQueueDelegate <NSObject>

- (void)didFinishOperation:(NSOperation *)operation;
- (void)willAddOperation:(NSOperation *)operation;

@end

@interface OperationQueue : NSOperationQueue

+(instancetype)sharedQueue;

@property (nonatomic, weak) id<OperationQueueDelegate> delegate;

@end
