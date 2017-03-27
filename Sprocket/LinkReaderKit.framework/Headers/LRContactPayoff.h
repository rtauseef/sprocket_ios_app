//
//  HPContactPayoff.h
//  LinkReaderSDK
//
//  Copyright (c) 2015 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRPayoff.h"

@import AddressBook;

/**
 LRContactPayoff represents a contact card
 
 @since 1.0
 */
@interface LRContactPayoff : NSObject <LRPayoff>

/**
 Raw contact card data. This could be a vcard or (similar) mecard
 
 @since 1.0
 */
@property (nonatomic, readonly) id rawContact;

/**
 An array of ABRecords (can get arrays from vcards, sometimes)
 
 @since 1.0
 */
@property (nonatomic, readonly) NSArray *contacts;

/**
 Initializes a LRContactPayoff object with a contact string.
 
 @param contact A NSString that contains the raw contact data.
 
 @return An initialized LRContactPayoff object.
 
 @since 1.0
 */
- (instancetype)initWithContact:(id)contact;

@end
