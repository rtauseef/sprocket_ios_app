//
//  LRSharePayoff.h
//  LinkReaderSDK
//
//  Copyright (c) 2015 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRPayoff.h"

/**
 Represents sharable content. The LRSharePayoff supports the Share action and is intended to represent a piece of content a user can share with others.
 
 @since 1.0
 */
@interface LRSharePayoff : NSObject <LRPayoff>

/**
 Content to be shared
 
 @since 1.0
 */
@property (nonatomic, readonly) NSString *content;

/**
 Initializer

 @param content The content available to the user for sharing

 @return LRSharePayoff
 
 @since 1.0
 */
-(instancetype)initWithContent:(NSString *)content;

@end
