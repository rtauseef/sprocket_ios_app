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

#import "PGSurveyManager.h"

#define DEFAULT_USES_UNTIL_PROMPT 6
#define DEFAULT_ALERT_VIEW_MESSAGE_TITLE [NSString stringWithFormat:NSLocalizedString(@"Tell us what you think of %@", nil), [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]]
#define DEFAULT_ALERT_VIEW_MESSAGE NSLocalizedString(@"Please tell us what is awesome and what is lame", @"Ask the user to take a survey to say his opinion of the app")
#define DEFAULT_ALERT_VIEW_ACCEPT_BUTTON_LABEL NSLocalizedString(@"Take the survey", nil)
#define DEFAULT_ALERT_VIEW_REMIND_LATER_BUTTON_LABEL NSLocalizedString(@"Remind me later", nil)
#define DEFAULT_ALERT_VIEW_DECLINE_BUTTON_LABEL NSLocalizedString(@"No, thanks", nil)

#define ACCEPT_BUTTON_INDEX 0
#define REMIND_LATER_BUTTON_INDEX 1
#define DECLINE_BUTTON_INDEX 2

static NSString *const surveyManagerUseCountKey = @"surveyManagerUseCountKey";
static NSString *const surveyManagerDisableKey = @"surveyManagerDisableKey";

@interface PGSurveyManager() <UIAlertViewDelegate>

@end

@implementation PGSurveyManager

+ (PGSurveyManager *)sharedInstance
{
    static PGSurveyManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PGSurveyManager alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.usesUntilPrompt = DEFAULT_USES_UNTIL_PROMPT;
        self.messageTitle = DEFAULT_ALERT_VIEW_MESSAGE_TITLE;
        self.message = DEFAULT_ALERT_VIEW_MESSAGE;
        self.acceptButtonLabel = DEFAULT_ALERT_VIEW_ACCEPT_BUTTON_LABEL;
        self.remindLaterButtonLabel = DEFAULT_ALERT_VIEW_REMIND_LATER_BUTTON_LABEL;
        self.declineButtonLabel = DEFAULT_ALERT_VIEW_DECLINE_BUTTON_LABEL;
    }
    
    return self;
}

- (BOOL)disable
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:surveyManagerDisableKey];
}

- (void)setDisable:(BOOL)disable
{
    [[NSUserDefaults standardUserDefaults] setBool:(BOOL)disable forKey:surveyManagerDisableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSUInteger)usesCount
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:surveyManagerUseCountKey];
}

- (void)setUsesCount:(NSUInteger)count
{
    [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)count forKey:surveyManagerUseCountKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)incrementUseCount
{
    NSInteger usesCount = [self usesCount];
    usesCount++;
    [self setUsesCount:usesCount];
}

- (void)check
{
    if (![self disable]) {
        [self incrementUseCount];
        
        if ([self shouldPromptForSurvey]) {
            [self promptForSurvey];
        }
    }
}

- (BOOL)shouldPromptForSurvey
{
    return ([self usesCount] >= self.usesUntilPrompt);
}

- (void)promptForSurvey
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.messageTitle
                                                    message:self.message
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:self.acceptButtonLabel, self.remindLaterButtonLabel, self.declineButtonLabel, nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == DECLINE_BUTTON_INDEX) {
        [self decline];
    } else if (buttonIndex == REMIND_LATER_BUTTON_INDEX) {
        [self remindLater];
    } else if (buttonIndex == ACCEPT_BUTTON_INDEX) {
        [self accept];
    }
}

#pragma mark - User's actions

- (void)accept
{
    if ([self.delegate respondsToSelector:@selector(surveyManagerUserDidSelectAccept:)]) {
        [self.delegate surveyManagerUserDidSelectAccept:self];
    }
}

- (void)remindLater
{
    // This will cause the prompt to show after another <usesUntilPrompt> times
    [self setUsesCount:0];
    
    if ([self.delegate respondsToSelector:@selector(surveyManagerUserDidSelectRemindLater:)]) {
        [self.delegate surveyManagerUserDidSelectRemindLater:self];
    }
}

- (void)decline
{
    [self setDisable:YES];
    
    if ([self.delegate respondsToSelector:@selector(surveyManagerUserDidSelectDecline:)]) {
        [self.delegate surveyManagerUserDidSelectDecline:self];
    }
}

@end
