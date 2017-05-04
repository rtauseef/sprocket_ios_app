//
//  HPLinkBaseNetworkOperationPrivate.h
//  HPLinkUtils
//
//  Created by Alejandro Mendez on 2/23/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <HPLinkUtils/HPLinkBaseNetworkOperation.h>
#import <HPLinkUtils/HPLinkBaseOperation+Private.h>

@interface HPLinkBaseNetworkOperation ()

@property (nonatomic, nullable) HPLinkBaseNetworkOperationCompletion completion;
@property (nonatomic, nullable) NSURL *url;

- (nonnull NSURLRequest *)prepareRequest;
- (void)finishOperationWithData:(nullable id)data response:(nullable NSHTTPURLResponse *)response error:(nullable NSError *)error;
- (void)handleErrorWithData:(nullable NSData *)data response:(nullable NSHTTPURLResponse *)response error:(nullable NSError *)error;
- (void)populateError:(NSError * _Nullable * _Nullable)error withData:(nullable NSData *)data response:(nullable NSHTTPURLResponse *)httpResponse;

@end
