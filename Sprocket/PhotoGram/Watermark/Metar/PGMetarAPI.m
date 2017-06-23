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

#import "PGMetarAPI.h"
#import "PGMetarUser.h"
#import <CommonCrypto/CommonHMAC.h>

@interface PGMetarAPI()

@property (assign, nonatomic) BOOL authRetry;

@end

@implementation PGMetarAPI

NSString * const kBatataAPIURL = @"http://www.somacoding.com/sprocket-link";
NSString * const kMetarAPIURL = @"http://www.somacoding.com/metar";
NSString * const PGMetarAPIDomain = @"com.hp.sprocket.metarapi";

static NSString * const kMetarApplicationID = @"dm_ios";
static NSString * const kMetarAPICredentialsKey = @"pg-metar-credentials";

- (NSMutableURLRequest *) getMetarRequest {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setValue:kMetarApplicationID forHTTPHeaderField:@"X-HP-AppId"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    [request setValue:language forHTTPHeaderField:@"Accept-Language"];
    
    return request;
}

- (NSMutableURLRequest *) getMetarRequestWithAuthAndToken: (BOOL) token {
    NSMutableURLRequest *request = [self getMetarRequest];
    
    if (token) {
        [request setValue:[self getAuthHeaderWithAccessToken:YES] forHTTPHeaderField:@"Authorization"];
    } else {
        [request setValue:[self getAuthHeaderWithAccessToken:NO] forHTTPHeaderField:@"Authorization"];
    }
    
    return request;
}

- (NSString *) NSDataToHex: (NSData *) data {
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger          dataLength  = [data length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

- (NSString *) getAuthHeaderWithAccessToken: (BOOL) useToken {
    NSString *headerString;
    
    PGMetarUser *user = [self getCredentialsFromStorage];
    
    if ([self validUser:user]) {
        NSString *unixtime = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
        NSString *cnonce = [self getSHA256:[NSString stringWithFormat:@"%@%@",unixtime,user.accountID]];
        
        if (useToken) {
            headerString = [NSString stringWithFormat:@"acc=%@,token=%@,cnonce=%@,timestamp=%@,signature_method=HMAC_SHA256",user.accountID,user.accessToken,cnonce,unixtime];
        } else {
            headerString = [NSString stringWithFormat:@"acc=%@,cnonce=%@,timestamp=%@,signature_method=HMAC_SHA256",user.accountID,cnonce,unixtime];
        }
        

        NSString *signature = [self getHMACSha256WithKey:[self getSHA256:user.secret] andMessage:headerString];
        
        NSString *encodedHeader = [NSString stringWithFormat:@"Sprocket %@,signature=%@",headerString,signature];
        
        NSLog(@"DEBUG Auth Header: %@",encodedHeader);
        return encodedHeader;
    }
    
    return nil;
}

-(NSString*) getSHA256:(NSString *)clear{
    const char *s=[clear cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData=[NSData dataWithBytes:s length:strlen(s)];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
    CC_SHA256(keyData.bytes, (int) keyData.length, digest);
    NSData *out=[NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSString *hex = [self NSDataToHex:out];
    return hex;
}

- (NSString *) getHMACSha256WithKey: (NSString *) key andMessage: (NSString *) message {
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [message cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *output = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *hexOutput = [self NSDataToHex:output];
    
    return hexOutput;
}

- (NSString *) getHMACSha256WithDataKey: (NSData *) key andMessage: (NSString *) message {
    char *cKey = (char *) [key bytes];
    const char *cData = [message cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *output = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *hexOutput = [self NSDataToHex:output];
    
    return hexOutput;
}

- (BOOL) validUser: (PGMetarUser *) user {
     if (!user.accessToken || !user.secret || !user.accountID || !user.expire) {
         return NO;
     } else {
         return YES;
     }
}

- (void) saveCredentialsToStorage: (PGMetarUser *) user {
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:user]
                                              forKey:kMetarAPICredentialsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

- (void) handleError: (NSHTTPURLResponse *) response completion: (nullable void (^)(NSError *error)) completion {
    
    NSString *XHPError = [[response allHeaderFields] objectForKey:@"X-HP-ErrorCode"];
    
    // TODO: better handling HP response codes, renew token when needed
    if ([response statusCode] == 401 && !self.authRetry) {
        self.authRetry = YES;
     
        PGMetarUser *user = [[PGMetarUser alloc] init];
        [self saveCredentialsToStorage:user];
        
        [self challenge:^(NSError * _Nullable error) {
            self.authRetry = NO;
            
            if (completion) {
                completion([NSError errorWithDomain:PGMetarAPIDomain code:PGMetarAPIErrorRequestFailedAuth userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"API request failed, HTTP error: %d and X-HP-ERROR:%@, did new challenge",(int) [response statusCode], XHPError]}]);
            }
        }];
    } else if ([response statusCode] == 403 && !self.authRetry) {
        // needs a new token
        self.authRetry = YES;
        [self getAccessToken:^(NSError * _Nullable error) {
            
            // invalidating user, two 403 in a row
            if (error != nil) {
                PGMetarUser *user = [[PGMetarUser alloc] init];
                [self saveCredentialsToStorage:user];
            }
            
            self.authRetry = NO;
            
            if (completion) {
                completion([NSError errorWithDomain:PGMetarAPIDomain code:PGMetarAPIErrorRequestFailedAuth userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"API request failed, HTTP error: %d and X-HP-ERROR:%@, did new token",(int) [response statusCode], XHPError]}]);
            }
        }];
    } else {
        if (completion) {
            completion([NSError errorWithDomain:PGMetarAPIDomain code:PGMetarAPIErrorRequestFailed userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"API request failed, HTTP error: %d and X-HP-ERROR:%@",(int) [response statusCode], XHPError]}]);
        }
    }
}

#pragma mark METAR API CALLS

- (void) authenticate: (nullable void (^)(BOOL success)) completion {
    PGMetarUser *user = [self getCredentialsFromStorage];
    
    if (![self validUser:user]) {
        // request new account
        [self challenge:^(NSError *error) {
            if (error) {
                if (completion) {
                    completion(NO);
                }
            } else {
                if (completion) {
                    completion(YES);
                }
            }
        }];
    } else {
        if (completion) {
            completion(YES);
        }
    }
}

- (void) challenge: (nullable void (^)(NSError *error)) completion {
    NSString *requestString = [NSString stringWithFormat:@"%@/auth/challenge/", kMetarAPIURL];
    NSURL *requestUrl = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [self getMetarRequest];
    
    [request setURL:requestUrl];
    [request setHTTPMethod:@"POST"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
      
                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                         if (error) {
                                             if (completion) {
                                                 completion(error);
                                             }
                                         } else {
                                             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                             if ([httpResponse statusCode] == 200 || [httpResponse statusCode] == 201) {
                                                 NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                 NSDictionary * authData = [dic objectForKey:@"auth"];
                                                 
                                                 NSString *account = [authData objectForKey:@"account"];
                                                 NSString *expire = [authData objectForKey:@"expire"];
                                                 NSString *secret = [authData objectForKey:@"secret"];
                                                 NSString *token = [authData objectForKey:@"token"];
                                                 
                                                 if (account && expire && secret && token) {
                                                     PGMetarUser *user =  [[PGMetarUser alloc] initWithToken:token secret:secret accountID:account expire:expire];
                                                     [self saveCredentialsToStorage:user];
                                                     
                                                     if (completion) {
                                                         completion(nil);
                                                     }
                                                 } else {
                                                     if (completion) {
                                                         completion([NSError errorWithDomain:PGMetarAPIDomain code:PGMetarAPIErrorRequestFailed userInfo:@{ NSLocalizedDescriptionKey: @"API request failed, missing auth parameters"}]);
                                                     }
                                                 }
                                             } else {
                                                 [self handleError:httpResponse completion:completion];
                                             }
                                         }
                                     }] resume];
}

- (void) getAccessToken: (nullable void (^)(NSError *error)) completion {
    NSString *requestString = [NSString stringWithFormat:@"%@/auth/token", kMetarAPIURL];
    NSURL *requestUrl = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [self getMetarRequestWithAuthAndToken:NO];
    
    [request setURL:requestUrl];
    [request setHTTPMethod:@"POST"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
      
                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                         if (error) {
                                             if (completion) {
                                                 completion(error);
                                             }
                                         } else {
                                             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                             if ([httpResponse statusCode] == 200 || [httpResponse statusCode] == 201) {
                                                 NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                 NSDictionary * authData = [dic objectForKey:@"auth"];
                                                 
                                                 NSString *account = [authData objectForKey:@"account"];
                                                 NSString *expire = [authData objectForKey:@"expire"];
                                                 NSString *token = [authData objectForKey:@"token"];
                                                 NSString *secret = [[self getCredentialsFromStorage] secret];
                                                                     
                                                 if (account && expire && secret && token) {
                                                     PGMetarUser *user =  [[PGMetarUser alloc] initWithToken:token secret:secret accountID:account expire:expire];
                                                     [self saveCredentialsToStorage:user];
                                                     
                                                     if (completion) {
                                                         completion(nil);
                                                     }
                                                 } else {
                                                     if (completion) {
                                                         completion([NSError errorWithDomain:PGMetarAPIDomain code:PGMetarAPIErrorRequestFailed userInfo:@{ NSLocalizedDescriptionKey: @"API request failed, missing auth parameters"}]);
                                                     }
                                                 }
                                             } else {
                                                  [self handleError:httpResponse completion:completion];
                                             }
                                         }
                                     }] resume];
}

- (void) uploadImage: (UIImage *) image completion: (nullable void (^)(NSError *error, PGMetarImageTag *imageTag)) completion {
    NSString *requestString = [NSString stringWithFormat:@"%@/resource/tag/", kMetarAPIURL];
    NSURL *requestUrl = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [self getMetarRequestWithAuthAndToken:YES];
    
    //TODO: re-scaling?
    NSData *jpeg = UIImageJPEGRepresentation(image, 0.9);
    
    NSLog(@"Watermarked image length: %ld bytes",[jpeg length]);
    
    [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    [request setURL:requestUrl];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jpeg];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
      
                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                         if (error) {
                                             if (completion) {
                                                 completion(error, nil);
                                             }
                                         } else {
                                             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                             if ([httpResponse statusCode] == 200 || [httpResponse statusCode] == 201) {
                                                 if ([data length] > 0) {
                                                     NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                     
                                                     NSString *atString = [dic objectForKey:@"at"];
                                                     NSDate *at = [NSDate dateWithTimeIntervalSince1970:[atString doubleValue]];
                                                     NSString *resource = [dic objectForKey:@"resource"];
                                                     NSString *media = [dic objectForKey:@"media"];
                                                     
                                                     PGMetarImageTag *imageTag = [[PGMetarImageTag alloc] initWithDate:at andResource:resource andMedia:media];
                                                     
                                                     if (completion) {
                                                         completion(nil, imageTag);
                                                     }
                                                 } else {
                                                     completion([NSError errorWithDomain:PGMetarAPIDomain code:PGMetarAPIErrorRequestFailed userInfo:@{ NSLocalizedDescriptionKey: @"API failed to return image tag object"}],nil);
                                                 }
                                             } else {
                                                 [self handleError:httpResponse completion:^(NSError *error) {
                                                     if (completion) {
                                                         completion(error, nil);
                                                     }
                                                 }];
                                             }
                                         }
                                     }] resume];
}

- (void) downloadWatermarkedImage: (PGMetarImageTag *) imageTag completion: (nullable void (^)(NSError * _Nullable error, UIImage * _Nullable watermarkedImage)) completion {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", kMetarAPIURL, imageTag.media];
    NSURL *requestUrl = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [self getMetarRequestWithAuthAndToken:YES];

    [request setURL:requestUrl];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"image/jpeg" forHTTPHeaderField:@"Accept"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
      
                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                         if (error) {
                                             if (completion) {
                                                 completion(error, nil);
                                             }
                                         } else {
                                             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                             if ([httpResponse statusCode] == 200 || [httpResponse statusCode] == 201) {
                                                 if ([data length] > 0) {
                                                     UIImage *image = [UIImage imageWithData:data];
                                                     
                                                     if (completion) {
                                                         completion(nil, image);
                                                     }
                                                 } else {
                                                     if (completion) {
                                                         completion([NSError errorWithDomain:PGMetarAPIDomain code:PGMetarAPIErrorRequestFailed userInfo:@{ NSLocalizedDescriptionKey: @"API returned 0 bytes for watermarked image"}],nil);
                                                     }
                                                 }
                                             } else {
                                                 [self handleError:httpResponse completion:^(NSError *error) {
                                                     if (completion) {
                                                         completion(error, nil);
                                                     }
                                                 }];
                                             }
                                         }
                                     }] resume];
}

- (void) setImageMetadata: (PGMetarImageTag *_Nonnull) imageTag mediaMetada:(PGMetarMedia *_Nonnull) metadata completion: (nullable void (^)(NSError * _Nullable error)) completion {
    
    NSString *requestString = [NSString stringWithFormat:@"%@/resource/tag/%@/meta", kMetarAPIURL, imageTag.resource];
    NSURL *requestUrl = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [self getMetarRequestWithAuthAndToken:YES];
    
    [request setURL:requestUrl];
    [request setHTTPMethod:@"POST"];
    
    NSError *jsonError;
    
    NSDictionary *media = @{@"media" : [metadata getDict]};
    NSDictionary *to = @{@"to" : media};
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:to options:NSJSONWritingPrettyPrinted error:&jsonError];
    
    if (jsonError != nil) {
        
        if (completion) {
            completion([NSError errorWithDomain:PGMetarAPIDomain code:PGMetarAPIErrorCreatingJsonForMediaObject userInfo:@{ NSLocalizedDescriptionKey: @"Failed to create jSON from PGMetarMedia dictionary"}]);
        }
        
        return;
    }
    
    NSString *jsonString =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:jsonData];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
      
                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                         if (error) {
                                             if (completion) {
                                                 completion(error);
                                             }
                                         } else {
                                             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                             if ([httpResponse statusCode] == 200 || [httpResponse statusCode] == 201) {
                                                 
                                                 if (completion) {
                                                     completion(nil);
                                                 }
                                             } else if ([httpResponse statusCode] == 206) {
                                                 //TODO: handle partially accepted
                                                 
                                                 if (completion) {
                                                     completion(nil);
                                                 }
                                             } else {
                                                 [self handleError:httpResponse completion:^(NSError *error) {
                                                     if (completion) {
                                                         completion(error);
                                                     }
                                                 }];
                                             }
                                         }
                                     }] resume];
}

- (void) requestImageMetadataWithUUID: (NSString *_Nonnull) uuid completion: (nullable void (^)(NSError * _Nullable error, PGMetarMedia * _Nullable metarMedia)) completion {
    
    NSLog(@"METAR: fetching metadata for %@",uuid);
    
    NSString *requestString = [NSString stringWithFormat:@"%@/resource/tag/%@/meta", kMetarAPIURL, uuid];
    NSURL *requestUrl = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [self getMetarRequestWithAuthAndToken:YES];
    
    NSLog(@"METAR: fetching metadata: %@",requestString);
    
    
    [request setURL:requestUrl];
    [request setHTTPMethod:@"GET"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
      
                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                         if (error) {
                                             if (completion) {
                                                 completion(error, nil);
                                             }
                                         } else {
                                             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                             if ([httpResponse statusCode] == 200 || [httpResponse statusCode] == 201) {
                                                 if ([data length] > 0) {
                                                     NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                     
                                                     BOOL payloadOk = NO;
                                                     
                                                     if (dic != nil) {
                                                         NSDictionary *to = [dic objectForKey:@"to"];
                                                         if (to != nil) {
                                                             NSDictionary *media = [to objectForKey:@"media"];
                                                    
                                                             if (media != nil) {
                                                                 PGMetarMedia *metarMedia = [[PGMetarMedia alloc] initWithDictionary:media];
                                                                 
                                                                 if (metarMedia != nil) {
                                                                     completion(nil,metarMedia);
                                                                     payloadOk = YES;
                                                                 }
                                                             }
                                                         }
                                                     }
                                                     
                                                     if (!payloadOk) {
                                                         if (completion) {
                                                             completion([NSError errorWithDomain:PGMetarAPIDomain code:PGMetarAPIErrorFailedParsingPayload userInfo:@{ NSLocalizedDescriptionKey: @"METAR: Failed to parse MEDIA payload"}],nil);
                                                         }
                                                     }
                                                 } else {
                                                     if (completion) {
                                                         completion([NSError errorWithDomain:PGMetarAPIDomain code:PGMetarAPIErrorEmptyPayload userInfo:@{ NSLocalizedDescriptionKey: @"METAR: Empty data for image"}],nil);
                                                     }
                                                 }
                                                
                                             } else {
                                                 [self handleError:httpResponse completion:^(NSError *error) {
                                                     if (completion) {
                                                         completion(error, nil);
                                                     }
                                                 }];
                                             }
                                         }
                                     }] resume];
}

- (void) getOfflineTags: (nullable void (^)(NSError *error, NSArray *tags)) completion {
    NSString *requestString = [NSString stringWithFormat:@"%@/resource/tag/", kMetarAPIURL];
    NSURL *requestUrl = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [self getMetarRequestWithAuthAndToken:YES];
    
    [request setURL:requestUrl];
    [request setHTTPMethod:@"GET"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
      
                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                         if (error) {
                                             if (completion) {
                                                 completion(error,nil);
                                             }
                                         } else {
                                             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                             if ([httpResponse statusCode] == 200 || [httpResponse statusCode] == 201) {
                                                 NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                 NSMutableArray *tagArray = [NSMutableArray array];
                                                 if (dic != nil) {
                                                     NSArray *resources = [dic objectForKey:@"resources"];
                                                     
                                                     if (resources != nil) {
                                                         for (NSDictionary *resource in resources) {
                                                             [tagArray addObject:[resource objectForKey:@"resource"]];
                                                         }
                                                        
                                                         if (completion) {
                                                             completion(nil,tagArray);
                                                         }
                                                         
                                                        return;
                                                     }
                                                 }
                                                
                                                if (completion) {
                                                    completion([NSError errorWithDomain:PGMetarAPIDomain code:PGMetarAPIErrorEmptyPayload userInfo:@{ NSLocalizedDescriptionKey: @"METAR: failed to get offline tags"}],nil);
                                                }
                                             } else {
                                                 [self handleError:httpResponse completion:^(NSError *error) {
                                                     if (completion) {
                                                         completion(error, nil);
                                                     }
                                                 }];
                                             }
                                         }
                                     }] resume];
}

@end
