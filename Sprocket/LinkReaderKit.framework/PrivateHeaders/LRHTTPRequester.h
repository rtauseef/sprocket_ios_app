//
//  LRHTTPRequester.h
//  LinkReaderSDK
//
//  Copyright (c) 2015 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#define HP_HTTP_REQUESTER_DEFAULT_MAX_ATTEMPTS 3

typedef void (^HPHTTPCompletionHandler)(NSInteger statusCode, NSData *responseData, NSError *error);

@interface LRHTTPRequester : NSObject
@property NSInteger numberOfAttempts;
- (id)initWithUrl:(NSString*)url
      maxAttempts:(NSInteger)maxAttempts
       completion:(HPHTTPCompletionHandler)completion;

- (id)initWithUrl:(NSString*)url
       completion:(HPHTTPCompletionHandler)completion;

- (id)initWithRequest:(NSURLRequest*)request
          maxAttempts:(NSInteger)maxAttempts
           completion:(HPHTTPCompletionHandler)completion;

- (id)initWithRequest:(NSURLRequest*)request
           completion:(HPHTTPCompletionHandler)completion;
@end
