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

#import "HPPRInstagramUser.h"
#import "HPPRInstagram.h"
//#import "MCAnalyticsManager.h"

@implementation HPPRInstagramUser

static NSString *_profilePictureURL = nil;
static NSString *_userName = nil;
static NSString *_userId = nil;
static NSNumber *_posts = nil;
static NSNumber *_followers = nil;
static NSNumber *_following = nil;

+ (void)userProfileWithId:(NSString *)userId completion:(void (^)(NSString *userName, NSString *userId, NSString *profilePictureUrl, NSNumber *posts, NSNumber *followers, NSNumber *following))completion
{
    if (_profilePictureURL != nil) {
        
        if (completion) {
            completion(_userName, _userId, _profilePictureURL, _posts, _followers, _following);
        }
        
    } else {
        
        HPPRInstagram *client = [HPPRInstagram sharedClient];
        
        if ([client getAccessToken] == nil) {
            
            if (completion) {
                completion(nil, nil, nil, nil, nil, nil);
            }
            
        } else {
            
            NSDictionary *params = [NSDictionary dictionaryWithObject:[client getAccessToken] forKey:@"access_token"];
            NSString *path = [NSString stringWithFormat:kUserUserProfileEndpoint, userId];
            
            [client getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSDictionary *data = [responseObject objectForKey:@"data"];
                _profilePictureURL = [data objectForKey:@"profile_picture"];
				_userName = [data objectForKey:@"username"];
				_userId = [data objectForKey:@"id"];
                
                NSDictionary *counts = [data objectForKey:@"counts"];
				_posts = [counts objectForKey:@"media"];
				_followers = [counts objectForKey:@"followed_by"];
                _following = [counts objectForKey:@"follows"];
                               
                if (completion) {
                    completion(_userName, _userId, _profilePictureURL, _posts, _followers, _following);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                NSLog(@"error: %@", error.localizedDescription);
                
                if (completion) {
                    completion(nil, nil, nil, nil, nil, nil);
                }
                
            }];
        }
    }
}

+ (void)userSearch:(NSString *)searchString completion:(void (^)(NSArray *results, NSError *error))completion
{
    HPPRInstagram *client = [HPPRInstagram sharedClient];
    
    if ([client getAccessToken] == nil) {
        
        NSLog(@"Missing access token: Unable to search for users");
        
        if (completion) {
            completion(nil, nil);
        }
        
    } else {
        
        NSLog(@"Retrieving search results for user '%@'", searchString);
        
        NSArray *objects = @[searchString, [client getAccessToken]];
        NSArray *keys    = @[@"q", @"access_token"];
        NSDictionary *params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        NSString *path = kUserUserSearchEndpoint;
        
        [client getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSArray *users = [responseObject objectForKey:@"data"];
           
            if (completion) {
                completion(users, nil);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"error: %@", error.localizedDescription);
            
            if (completion) {
                completion(nil, error);
            }
            
        }];
    }
}

+ (void)clearSaveUserProfile
{
    _profilePictureURL = nil;
    _userName = nil;
    _userId = nil;
    _posts = nil;
    _followers = nil;
    _following = nil;
}

@end
