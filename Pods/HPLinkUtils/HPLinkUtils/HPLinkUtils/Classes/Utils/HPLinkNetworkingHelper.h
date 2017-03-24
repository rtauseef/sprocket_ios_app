//
//  HPLinkNetworkingHelper.h
//  HPLinkUtils
//
//  Created by Alejandro Mendez on 1/12/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HPHttpMethod) {
    HPHttpMethodGet,
    HPHttpMethodPost,
    HPHttpMethodDelete,
    HPHttpMethodPut
};

@interface HPLinkNetworkingHelper : NSObject

+ (nonnull NSMutableURLRequest *)jsonRequestWithMethod:(HPHttpMethod)method url:(nonnull NSURL*)url data:(nullable id)data headers:(nullable NSDictionary *)headers;
+ (nonnull NSMutableURLRequest *)requestWithMethod:(HPHttpMethod)method url:(nonnull NSURL*)url data:(nullable id)data headers:(nullable NSDictionary *)headers;

@end
