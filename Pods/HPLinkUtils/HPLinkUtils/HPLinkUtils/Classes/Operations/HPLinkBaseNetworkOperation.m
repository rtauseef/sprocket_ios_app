//
//  HPLinkBaseNetworkOperation.m
//  HPLinkUtils
//
//  Created by Alejandro Mendez on 2/23/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import "HPLinkBaseNetworkOperation+Private.h"
#import "HPLinkJsonSerializer.h"

NSString *const HPLinkBaseNetworkOperationDomain = @"HPLinkBaseNetworkOperationDomain";

@interface HPLinkBaseNetworkOperation() <NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>
@property (nonatomic) float downloadSize;
@property (nonatomic) NSMutableData *downloadData;
@property (nonatomic) NSURLSession *session;
@end


@implementation HPLinkBaseNetworkOperation

+ (instancetype)executeWithRequest:(NSURLRequest *)request completion:(HPLinkBaseNetworkOperationCompletion)completion{
    
    HPLinkBaseNetworkOperation *operation = [[[self class] alloc] initWithRequest:request completion:completion];
    [[HPLinkOperationQueue sharedQueue] addOperation:operation];
    return operation;
    
}

- (instancetype)initWithRequest:(NSURLRequest *)request completion:(HPLinkBaseNetworkOperationCompletion)completion{
    if (self = [super init]) {
        _request = request;
        _completion = completion;
        _requestDeserializer = [HPLinkJsonSerializer new];
    }
    return self;
}

- (NSURLRequest *)prepareRequest {
    return self.request ? self.request : [NSURLRequest new];
}

- (void)executeNetworkTask {
    
    NSURLRequest *request = [self prepareRequest];
    
    if (!self.session) {
        self.session = [NSURLSession sessionWithConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration] delegate: self delegateQueue: [NSOperationQueue mainQueue]];
    }
    NSURLSessionDataTask * dataTask = [self.session dataTaskWithRequest:request];
    dispatch_async(dispatch_get_main_queue(), ^{
        [dataTask resume];
    });
}

- (void)populateError:(NSError **)error withData:(NSData *)data response:(NSHTTPURLResponse *)httpResponse {
    // Implement in subclass
}

- (void)handleCompletedTask:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    
    if (!error) {
        if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
            [self populateError:&error withData:data response:httpResponse];
            if (!error) {
                error = [NSError errorWithDomain:HPLinkBaseNetworkOperationDomain code:100 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Error with status: %zd", httpResponse.statusCode]  }];
            }
        }
    }
    
    if (self.requestDeserializer && data.length > 0) {
        NSError *deserializeError;
        id deserializedData = [self.requestDeserializer deserializeData:data error:&deserializeError];
        if (!deserializeError) {
            data = deserializedData;
        }
    }
    
    if (!error) {
        [self finishOperationWithData:data response:httpResponse error:nil];
    }else{
        [self handleErrorWithData:data response:httpResponse error:error];
    }
}

- (void)handleErrorWithData:(NSData *)data response:(NSHTTPURLResponse *)response error:(NSError *)error{
    [self finishOperationWithData:data response:response error:error];
}


-(void)finishOperationWithData:(id)data response:(NSHTTPURLResponse *)response error:(NSError *)error{
    if (error) {
        if ([self canRetry]) {
            [super retryOperation];
            return;
        }
    }
    if (self.completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completion(data, response, error);
        });
    }
    [self.session finishTasksAndInvalidate];
    self.session = nil;
    self.downloadData = nil;
    [super finishOperation:error];
}

-(void)executeOperation {
    [super executeOperation];
    [self executeNetworkTask];
}

#pragma mark NSURLSessionDataDelegate

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    
    self.downloadSize = [response expectedContentLength];
    self.downloadData = [[NSMutableData alloc] init];
    completionHandler(NSURLSessionResponseAllow);
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    [self.downloadData appendData:data];
    double progress = [self.downloadData length ]/self.downloadSize;
    if (self.progressCallback) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressCallback(progress);
        });
    }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    
    double progress = 1.0 * totalBytesSent/totalBytesExpectedToSend;
    if (self.progressCallback) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressCallback(progress);
        });
    }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    [self handleCompletedTask:self.downloadData response:task.response error:task.error];
}

@end
