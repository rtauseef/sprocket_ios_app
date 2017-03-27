//
//  HPCalendarEventPayoff.h
//  LinkReaderSDK
//
//  Copyright (c) 2015 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRPayoff.h"
@import EventKit;

/**
 Represents a calendar event
 
 @since 1.0
 */
@interface LRCalendarEventPayoff : NSObject <LRPayoff>

/**
 EKEvent created from the event payoload
 
 @since 1.0
 */
@property (nonatomic, readonly) EKEvent *event;

/**
 Returns the event store the event was created in

 @return EKEventStore
 
 @since 1.0
 */
-(EKEventStore *)eventStore;

@end
