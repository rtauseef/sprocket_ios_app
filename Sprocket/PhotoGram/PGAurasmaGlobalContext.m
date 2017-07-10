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

#import <AurasmaSDK/AurasmaSDK.h>
#import "PGAurasmaGlobalContext.h"

@interface PGAurasmaGlobalContext ()

@property (readwrite) AURContext *context;
@property (readwrite) NSString *guestName;
@property (readwrite) BOOL syncing;

@property (strong, nonatomic) AURAuthService *authService;
@property (strong, nonatomic) AURSyncService *syncService;
@property (atomic) BOOL currentlyProcessingLogin;
@property (atomic) BOOL currentlyProcessingGuestCreation;

@end

@implementation PGAurasmaGlobalContext


/* This is just for illustration. Your actual client secret should be as hidden as you are able. */
static NSString *clientSecret = @"eY+y3KQwIkVTb4fYe/pDdg";

/* NSUserDefaults key used to store the user id. Repeatedly creating new users should be avoided. */
static NSString *persistUsernameKey = @"PGAurasmaUsernameKey";

/* Options to set AurasmaSDK capabilities */
static AURGlobalOptions globalOptions = kNilOptions;

/* In most applications only a single AURContext is required. The following singleton pattern achieves this. */
+ (PGAurasmaGlobalContext *)instance {
    static PGAurasmaGlobalContext *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

- (instancetype)init {
    if ((self = [super init])) {
        NSError *error;
        /*
         Create an AURContext using your provided license key.
         The CFBundleName of this app must match the name given in your SDK app request.
         */
        self.context = [Aurasma createContextWithKey:[[NSBundle mainBundle] URLForResource:@"Sprocket" withExtension:@"key"]
                                    clientSecret:clientSecret
                                   globalOptions:globalOptions
                                           error:&error];
        
        if (!self.context) {
            NSLog(@"%@", error);
            return nil;
        }
        
        /* Get all the services we're going to use. Alternatively you could call these only when you need them. */
        self.authService = [AURAuthService getServiceWithContext:self.context];
        self.syncService = [AURSyncService getServiceWithContext:self.context];
        self.guestName = [[NSUserDefaults standardUserDefaults] objectForKey:persistUsernameKey];
        self.syncing = self.syncService.isRunning;
        
        /* Observe if we become logged out, and then log in again */
        [self.authService addObserver:self
                       forKeyPath:@"state"
                          options:NSKeyValueObservingOptionNew
                          context:nil];
    }
    return self;
}

- (void)loginAndStartSync {
    AURAuthServiceHandler loginHandler = ^(NSError *error) {
        self.currentlyProcessingLogin = NO;
        if (error) {
            /*
             Depending on your application, you will need to handle this error in order to proceed.
             For guest users this should never fail, but network problems may cause a temporary failure.
             */
            NSLog(@"%@", error);
            return;
        }
        
        [self.syncService start]; // Start sync immediatly after login.
        self.syncing = self.syncService.isRunning;
    };
    
    AURAuthServiceStringHandler guestCreationHandler = ^(NSError *error, NSString *result) {
        self.currentlyProcessingGuestCreation = NO;
        if (error) {
            /* Depending on your application, you will need to handle this error in order to proceed. */
            NSLog(@"%@", error);
            return;
        }
        
        self.guestName = result;
        
        /* Save the user id so it is not lost on restart. Any form of persistent storage could be used. */
        [[NSUserDefaults standardUserDefaults] setObject:result forKey:persistUsernameKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.currentlyProcessingLogin = YES;
        
        /* Immediatly login as the new guest user. */
        [self.authService loginGuest:result andCallback:loginHandler];
    };
    
    if (!self.guestName) {
        /* If we have no record of a user for this app, we need to make one. */
        if (self.currentlyProcessingGuestCreation) {
            return;
        }
        self.currentlyProcessingGuestCreation = YES;
        
        /* Pass nil as we don't care what the name actually is. */
        [self.authService createGuest:nil withCallback:guestCreationHandler];
    }
    else if (self.authService.state == AURAuthState_None) {
        /* If we have a user already and they're not logged in, then log in. */
        if (self.currentlyProcessingLogin) {
            return;
        }
        self.currentlyProcessingLogin = YES;
        /* Login as the user. Guest accounts don't require a password, but cannot be used across applications. */
        [self.authService loginGuest:self.guestName andCallback:loginHandler];
    }
    else {
        /* If we have a user and they're logged in, then start syncing. */
        [self.syncService start];
        self.syncing = self.syncService.isRunning;
    }
}

- (void)stopSync {
    [self.syncService stop];
    self.syncing = self.syncService.isRunning;
}

- (void)startSync {
    if (self.authService.state != AURAuthState_None) {
        [self.syncService start];
        self.syncing = self.syncService.isRunning;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([object isKindOfClass:[AURAuthService class]] && [keyPath isEqualToString:@"state"]) {
        AURAuthState authState = [change[NSKeyValueChangeNewKey] unsignedIntegerValue];
        if (authState == AURAuthState_None) {
            [self loginAndStartSync];
        }
        return;
    }
}

@end
