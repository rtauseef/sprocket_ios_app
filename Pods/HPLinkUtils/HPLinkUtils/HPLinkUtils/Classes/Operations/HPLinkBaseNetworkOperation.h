//
//  HPLinkBaseNetworkOperation.h
//  HPLinkUtils
//
//  Created by Alejandro Mendez on 2/23/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <HPLinkUtils/HPLinkBaseOperation.h>
#import <HPLinkUtils/HPLinkRequestDeserializer.h>
#import <HPLinkUtils/HPLinkNetworkingHelper.h>

FOUNDATION_EXPORT NSString * _Nonnull const HPLinkBaseNetworkOperationDomain;

typedef void (^HPLinkBaseNetworkOperationCompletion)(id _Nullable data, NSHTTPURLResponse * _Nullable response, NSError* _Nullable error);

@interface HPLinkBaseNetworkOperation : HPLinkBaseOperation

@property (nonatomic, nullable) id<HPLinkRequestDeserializer> requestDeserializer;
@property (nonatomic, nullable) NSURLRequest *request;
@property (nonatomic, copy, nullable) void (^progressCallback)(double progress);

+ (nullable instancetype)executeWithRequest:(nullable NSURLRequest *)request completion:(nullable HPLinkBaseNetworkOperationCompletion)completion;

- (nullable instancetype)initWithRequest:(nullable NSURLRequest *)request completion:(nullable HPLinkBaseNetworkOperationCompletion)completion;
- (nullable instancetype)init NS_UNAVAILABLE;

@end
