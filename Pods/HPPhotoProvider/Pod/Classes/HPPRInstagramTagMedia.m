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

#import "HPPRInstagramTagMedia.h"
#import "HPPRInstagram.h"
#import "HPPRInstagramMedia.h"

@implementation HPPRInstagramTagMedia

+ (void)tagMediaRecent:(NSString *)tagName nextMaxId:(NSString *)nextMaxId completion:(void (^)(NSDictionary *instagramPage, NSError *error))completion {
    
    HPPRInstagram *client = [HPPRInstagram sharedClient];
    if ([client getAccessToken] == nil) {
        NSLog(@"Missing access token: Unable to retrieve tag media");
        if (completion) {
            completion(nil, nil);
        }
    } else {
        
        NSLog(@"Retrieving media for tag '%@'", tagName);
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[client getAccessToken], @"access_token", nextMaxId, @"max_id",nil];
        NSString *path = [NSString stringWithFormat:kUserTagMediaSearchEndpoint, tagName];
        
        [client GET:path parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSMutableArray *mutableRecords = [NSMutableArray array];
            NSArray *data = [responseObject objectForKey:@"data"];
            NSDictionary *pagination = [responseObject objectForKey:@"pagination"];
            
            for (NSDictionary *obj in data) {
                if ([HPPRInstagramMedia isImage:obj]) {
                    HPPRInstagramMedia *media = [[HPPRInstagramMedia alloc] initWithAttributes:obj];
                    [mutableRecords addObject:media];
                }
            }
            if (completion) {
                NSDictionary *instagramPage = [NSDictionary dictionaryWithObjectsAndKeys:mutableRecords.copy, @"records", pagination, @"pagination", nil];
                completion(instagramPage, nil);
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
