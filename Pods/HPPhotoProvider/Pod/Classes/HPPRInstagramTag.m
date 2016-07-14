//
// Hewlett-Packard Company
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import "HPPRInstagramTag.h"
#import "HPPRInstagram.h"

@implementation HPPRInstagramTag

+ (void)tagSearch:(NSString *)searchString completion:(void (^)(NSArray *results, NSError *error))completion
{
    HPPRInstagram *client = [HPPRInstagram sharedClient];
    
    if ([client getAccessToken] == nil) {
        
        NSLog(@"Missing access token: Unable to search for tags");
        
        if (completion) {
            completion(nil, nil);
        }
        
    } else {
        
        NSLog(@"Retrieving search results for tag '%@'", searchString);
        
        NSArray *objects = @[searchString, [client getAccessToken]];
        NSArray *keys    = @[@"q", @"access_token"];
        NSDictionary *params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        NSString *path = kUserTagSearchEndpoint;
        
        [client GET:path parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSArray *tags = [responseObject objectForKey:@"data"];
            if (completion) {
                completion(tags, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error: %@", error.localizedDescription);
            if (completion) {
                completion(nil, error);
            }
        }];
        
    }
}


@end
