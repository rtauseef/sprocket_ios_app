//
//  HPLinkNetworkingHelper.m
//  HPLinkUtils
//
//  Created by Alejandro Mendez on 1/12/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import "HPLinkNetworkingHelper.h"
#import "HPLinkJsonSerializer.h"

@implementation HPLinkNetworkingHelper


+ (NSMutableURLRequest *)jsonRequestWithMethod:(HPHttpMethod)method url:(NSURL*)url data:(id)data headers:(NSDictionary *)headers {
    if (data) {
        data = [[HPLinkJsonSerializer new] serializeObject:data error:nil];
        if (!data) {
            return nil;
        }
    }
    return [self requestWithMethod:method url:url data:data headers:headers];
}

+ (NSMutableURLRequest *)requestWithMethod:(HPHttpMethod)method url:(NSURL*)url data:(id)data headers:(NSDictionary *)headers {
    
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    switch (method) {
        case HPHttpMethodGet: [request setHTTPMethod:@"GET"]; break;
        case HPHttpMethodPost: [request setHTTPMethod:@"POST"]; break;
        case HPHttpMethodDelete: [request setHTTPMethod:@"DELETE"]; break;
        case HPHttpMethodPut: [request setHTTPMethod:@"PUT"]; break;
        default:break;
    }
    for (NSString *key in headers) {
        [request setValue:headers[key] forHTTPHeaderField:key];
    }
    if (data) {
        [request setHTTPBody:data];
    }
    [request setURL:url];
    return request;
}

@end
