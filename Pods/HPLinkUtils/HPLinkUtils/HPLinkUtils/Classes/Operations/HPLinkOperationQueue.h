//
//  HPLinkOperationQueue.h
//  HPLinkUtils
//
//  Created by Alejandro Mendez on 10/12/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HPLinkOperationQueueDelegate <NSObject>

- (void)didFinishOperation:(nonnull NSOperation *)operation;
- (void)willAddOperation:(nonnull NSOperation *)operation;

@end

@interface HPLinkOperationQueue : NSOperationQueue

+ (nullable instancetype)sharedQueue;

@property (nonatomic, weak, nullable) id<HPLinkOperationQueueDelegate> delegate;

@end
