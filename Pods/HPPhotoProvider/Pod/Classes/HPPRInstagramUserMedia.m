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

#import "HPPRInstagramUserMedia.h"
#import "HPPRInstagram.h"
#import "HPPRInstagramMedia.h"
#import "HPPRCacheService.h"

@implementation HPPRInstagramUserMedia

+ (void)userMediaRecentWithId:(NSString *)userId nextMaxId:(NSString *)nextMaxId completion:(void (^)(NSDictionary *records, NSError *error))completion
{
    [self userMediaWithId:userId endpoint:kUserMediaRecentEndpoint nextMaxId:nextMaxId completion:completion];
}

+ (void)userMediaFeedWithId:(NSString *)userId nextMaxId:(NSString *)nextMaxId completion:(void (^)(NSDictionary *records, NSError *error))completion
{
    [self userMediaWithId:userId endpoint:kUserMediaFeedEndpoint nextMaxId:nextMaxId completion:completion];
}

+ (void)userMediaWithId:(NSString *)userId endpoint:(NSString *)endpoint nextMaxId:(NSString *)nextMaxId completion:(void (^)(NSDictionary *instagramPage, NSError *error))completion
{
    HPPRInstagram *client = [HPPRInstagram sharedClient];
    if ([client getAccessToken] == nil) {
        NSLog(@"Missing access token: Unable to retrieve user media");
        if (completion) {
            completion(nil, nil);
        }
        return;
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[client getAccessToken], @"access_token", nextMaxId, @"max_id",nil];
    NSString *path = [NSString stringWithFormat:endpoint, userId];
    
    [[HPPRInstagram sharedClient] getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", error.localizedDescription);
        if (completion) {
            completion(nil, error);
        }
    }];
}

+ (void)userFirstImageWithId:(NSString *)userId completion:(void (^)(UIImage *image))completion
{
    HPPRInstagram *client = [HPPRInstagram sharedClient];
    if ([client getAccessToken] == nil) {
        NSLog(@"Missing access token: Unable to retrieve user media");
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[client getAccessToken], @"access_token",nil];
    NSString *path = [NSString stringWithFormat:kUserMediaRecentEndpoint, userId];
    
    [[HPPRInstagram sharedClient] getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *data = [responseObject objectForKey:@"data"];
        
        UIImage *image = nil;
        
        for (NSDictionary *obj in data) {
            if ([HPPRInstagramMedia isImage:obj]) {
                HPPRInstagramMedia *media = [[HPPRInstagramMedia alloc] initWithAttributes:obj];
                image = [[HPPRCacheService sharedInstance] imageForUrl:media.standardUrl];
                break;
            }
        }
        
        if (completion) {
            completion(image);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", error.localizedDescription);
        if (completion) {
            completion(nil);
        }
    }];
}


@end
