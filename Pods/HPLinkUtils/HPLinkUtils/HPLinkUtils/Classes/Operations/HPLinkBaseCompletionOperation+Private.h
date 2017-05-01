//
//  HPLinkBaseCompletionOperation+Private.h
//  HPLinkUtils
//
//  Created by Alejandro Mendez on 3/10/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <HPLinkUtils/HPLinkBaseCompletionOperation.h>
#import <HPLinkUtils/HPLinkBaseOperation+Private.h>

@interface HPLinkBaseCompletionOperation ()

- (void)finishOperationWithData:(nullable id)data error:(nullable NSError *)error;
- (void)finishOperation:(nullable NSError *)error NS_UNAVAILABLE;
- (BOOL)retryOperation NS_UNAVAILABLE;

@end

