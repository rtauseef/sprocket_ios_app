//
//  PGMetarAPI.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/3/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarAPI.h"
#import "PGMetarUser.h"

@implementation PGMetarAPI

NSString * const PGMetarAPIDomain = @"com.hp.sprocket.metarapi";

static NSString * const kMetarApplicationID = @"dm_ios";
static NSString * const kMetarAPIURL = @"http://www.somacoding.com/metar/";
static NSString * const kMetarAPICredentialsKey = @"pg-metar-credentials";

- (void) authenticate: (nullable void (^)(BOOL success)) completion {
    PGMetarUser *user = [self getCredentialsFromStorage];
    
    if (!user.accessToken || !user.secret || !user.accountID) {
        // request new account
        [self challenge:^(NSError *error) {
            
        }];
    }
}

- (NSMutableURLRequest *) getMetarRequest {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request addValue:kMetarAPICredentialsKey forHTTPHeaderField:@"X-HP-AppId"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    return request;
}

- (void) challenge: (nullable void (^)(NSError *error)) completion {
    NSString *requestString = [NSString stringWithFormat:@"%@auth/challenge/", kMetarAPIURL];
    NSURL *requestUrl = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [self getMetarRequest];

    [request setURL:requestUrl];
    [request setHTTPMethod:@"POST"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
      
                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                         if (error) {
                                             completion(error);
                                         } else {
                                             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                             if ([httpResponse statusCode] == 200 || [httpResponse statusCode] == 201) {
                                                 NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                 NSLog(@"%@",dic);
                                             } else {
                                                 completion([NSError errorWithDomain:PGMetarAPIDomain code:PGMetarAPIErrorRequestFailed userInfo:@{ NSLocalizedDescriptionKey: @"API request failed, not 200/201"}]);
                                             }
                                         }
                                     }] resume];
}

- (PGMetarUser *) getCredentialsFromStorage {
    NSData * userData = [[NSUserDefaults standardUserDefaults] objectForKey:kMetarAPICredentialsKey];
    
    PGMetarUser *pgUser;
    
    if( ! userData ) {
         pgUser = [[PGMetarUser alloc] init];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:pgUser]
 forKey:kMetarAPICredentialsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        
        pgUser = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    }

    return pgUser;
}

@end
