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

#import "HPPRKeychainService.h"
#import <Security/Security.h>

@interface HPPRKeychainService ()

@property (nonatomic, strong) NSCache *cache;

@end

@implementation HPPRKeychainService

+ (instancetype)sharedInstance {
    static HPPRKeychainService *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HPPRKeychainService alloc] init];
    });

    return instance;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        self.cache = [[NSCache alloc] init];
    }

    return self;
}

- (void)setValue:(NSString *)value forKey:(NSString *)key {
    if (value == nil) {
        [self removeValueForKey:key];

    } else {
        OSStatus status;

        if ([self hasValueForKey:key]) {
            NSDictionary *findQuery = @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                        (__bridge id)kSecAttrService: [[NSBundle mainBundle] bundleIdentifier],
                                        (__bridge id)kSecAttrAccount: key
                                        };
            NSDictionary *updateQuery = @{(__bridge id)kSecValueData: [value dataUsingEncoding:NSUTF8StringEncoding]
                                          };

            status = SecItemUpdate((__bridge CFDictionaryRef)findQuery, (__bridge CFDictionaryRef)updateQuery);

        } else {
            NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                    (__bridge id)kSecAttrService: [[NSBundle mainBundle] bundleIdentifier],
                                    (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                    (__bridge id)kSecValueData: [value dataUsingEncoding:NSUTF8StringEncoding],
                                    (__bridge id)kSecAttrAccount: key
                                    };

            status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
        }

        if (status == errSecSuccess) {
            [self.cache setObject:value forKey:key];
        }
    }
}

- (NSString *)valueForKey:(NSString *)key {
    NSString *cachedValue = [self.cache objectForKey:key];
    if (cachedValue) {
        return cachedValue;
    }

    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService: [[NSBundle mainBundle] bundleIdentifier],
                            (__bridge id)kSecReturnData: @YES,
                            (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne,
                            (__bridge id)kSecAttrAccount: key
                            };

    CFTypeRef result;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);

    NSData *data;
    NSString *value;
    if (status == errSecSuccess) {
        data = [NSData dataWithData:(__bridge NSData *)result];

        if (data) {
            value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }

    if (value) {
        [self.cache setObject:value forKey:key];
    }

    return value;
}

- (void)removeValueForKey:(NSString *)key {
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService: [[NSBundle mainBundle] bundleIdentifier],
                            (__bridge id)kSecAttrAccount: key
                            };

    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);

    if (status == errSecSuccess) {
        [self.cache removeObjectForKey:key];
    }
}

- (BOOL)hasValueForKey:(NSString *)key {
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService: [[NSBundle mainBundle] bundleIdentifier],
                            (__bridge id)kSecAttrAccount: key
                            };

    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);

    return status == errSecSuccess;
}

@end
