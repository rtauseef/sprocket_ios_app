//
//  HPLinkBaseCompletionOperation.h
//  HPLinkUtils
//
//  Created by Alejandro Mendez on 10/14/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import <HPLinkUtils/HPLinkBaseOperation.h>

typedef void (^HPLinkBaseOperationCompletion)(id _Nullable data, NSError * _Nullable error);

@interface HPLinkBaseCompletionOperation : HPLinkBaseOperation

@property (nonatomic, nullable) id baseOperationData;
@property (nonatomic, nullable) HPLinkBaseOperationCompletion baseCompletion;

+ (nullable instancetype)executeWithData:(nullable id)operationData completion:(nullable HPLinkBaseOperationCompletion)completion;

- (nullable instancetype)initWithData:(nullable id)operationData completion:(nullable HPLinkBaseOperationCompletion)completion;
- (nullable instancetype)init NS_UNAVAILABLE;

@end
