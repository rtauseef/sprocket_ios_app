//
//  PGAurasmaGlobalContext.m
//  Sprocket
//
//  Created by Alex Walter on 06/06/2017.
//  Copyright © 2017 HP. All rights reserved.
//

#import <AurasmaSDK/AurasmaSDK.h>
#import "PGAurasmaGlobalContext.h"

@interface PGAurasmaGlobalContext ()
@property (readwrite) NSString *guestName;
@property (readwrite) BOOL syncing;
@end

@implementation PGAurasmaGlobalContext {
    AURContext *_context;
    AURAuthService *_authService;
    AURSyncService *_syncService;
    BOOL _currentlyProcessingLogin;
    BOOL _currentlyProcessingGuestCreation;
    NSString *_guestName;
    BOOL _syncing;
}

@synthesize context = _context;
@synthesize guestName = _guestName;
@synthesize syncing = _syncing;

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
        _context = [Aurasma createContextWithKey:[[NSBundle mainBundle] URLForResource:@"Sprocket" withExtension:@"key"]
                                    clientSecret:clientSecret
                                   globalOptions:globalOptions
                                           error:&error];
        
        if (!_context) {
            NSLog(@"%@", error);
            return nil;
        }
        
        /* Get all the services we're going to use. Alternatively you could call these only when you need them. */
        _authService = [AURAuthService getServiceWithContext:_context];
        _syncService = [AURSyncService getServiceWithContext:_context];
        _guestName = [[NSUserDefaults standardUserDefaults] objectForKey:persistUsernameKey];
        _syncing = _syncService.isRunning;
        
        /* Observe if we become logged out, and then log in again */
        [_authService addObserver:self
                       forKeyPath:@"state"
                          options:NSKeyValueObservingOptionNew
                          context:nil];
    }
    return self;
}

- (void)loginAndStartSync {
    AURAuthServiceHandler loginHandler = ^(NSError *error) {
        _currentlyProcessingLogin = NO;
        if (error) {
            /*
             Depending on your application, you will need to handle this error in order to proceed.
             For guest users this should never fail, but network problems may cause a temporary failure.
             */
            NSLog(@"%@", error);
            return;
        }
        
        [_syncService start]; // Start sync immediatly after login.
        self.syncing = _syncService.isRunning;
    };
    
    AURAuthServiceStringHandler guestCreationHandler = ^(NSError *error, NSString *result) {
        _currentlyProcessingGuestCreation = NO;
        if (error) {
            /* Depending on your application, you will need to handle this error in order to proceed. */
            NSLog(@"%@", error);
            return;
        }
        
        self.guestName = result;
        
        /* Save the user id so it is not lost on restart. Any form of persistent storage could be used. */
        [[NSUserDefaults standardUserDefaults] setObject:result forKey:persistUsernameKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        _currentlyProcessingLogin = YES;
        
        /* Immediatly login as the new guest user. */
        [_authService loginGuest:result andCallback:loginHandler];
    };
    
    if (!_guestName) {
        /* If we have no record of a user for this app, we need to make one. */
        if (_currentlyProcessingGuestCreation) {
            return;
        }
        _currentlyProcessingGuestCreation = YES;
        
        /* Pass nil as we don't care what the name actually is. */
        [_authService createGuest:nil withCallback:guestCreationHandler];
    }
    else if (_authService.state == AURAuthState_None) {
        /* If we have a user already and they're not logged in, then log in. */
        if (_currentlyProcessingLogin) {
            return;
        }
        _currentlyProcessingLogin = YES;
        /* Login as the user. Guest accounts don't require a password, but cannot be used across applications. */
        [_authService loginGuest:_guestName andCallback:loginHandler];
    }
    else {
        /* If we have a user and they're logged in, then start syncing. */
        [_syncService start];
        self.syncing = _syncService.isRunning;
    }
}

- (void)stopSync {
    [_syncService stop];
    self.syncing = _syncService.isRunning;
}

- (void)startSync {
    if (_authService.state != AURAuthState_None) {
        [_syncService start];
        self.syncing = _syncService.isRunning;
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
