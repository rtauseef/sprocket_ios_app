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

#import <Foundation/Foundation.h>

@protocol PGSurveyManagerDelegate;


@interface PGSurveyManager : NSObject

@property (nonatomic, weak) id<PGSurveyManagerDelegate> delegate;

@property (nonatomic, assign) NSUInteger usesUntilPrompt;

@property (nonatomic, strong) NSString *messageTitle;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *acceptButtonLabel;
@property (nonatomic, strong) NSString *remindLaterButtonLabel;
@property (nonatomic, strong) NSString *declineButtonLabel;

+ (PGSurveyManager *)sharedInstance;
- (void)check;
- (void)setDisable:(BOOL)disable;

@end

@protocol PGSurveyManagerDelegate <NSObject>

@optional
- (void)surveyManagerUserDidSelectDecline:(PGSurveyManager *)surveyManager;
- (void)surveyManagerUserDidSelectRemindLater:(PGSurveyManager *)surveyManager;
- (void)surveyManagerUserDidSelectAccept:(PGSurveyManager *)surveyManager;

@end