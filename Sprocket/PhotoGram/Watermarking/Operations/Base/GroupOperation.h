//
//  GroupOperation.h
//  LinkReaderSDK
//
//  Created by Live Paper Pairing on 10/12/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import "BaseCompletionOperation.h"

@interface GroupOperation : BaseCompletionOperation

- (void)groupOperationSuccessHandler:(id) result;
- (void)groupOperationFailureHandler:(NSError *)error;

- (NSArray *)operationsToBeAddedToGroupInQueue:(OperationQueue *)queue;

- (void)addOperation:(NSOperation * )operation;
- (void)didFinishOperation:(NSOperation *)operation;

@end
