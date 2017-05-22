//
//  PGPage.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/18/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "PGMetarLocation.h"

@interface PGMetarIcon : NSObject

@property (strong, nonatomic) NSString* thumb;
@property (strong, nonatomic) NSString* original;

- (instancetype)initWithDictionary: (NSDictionary *) dict;

@end

@interface PGMetarBlock: NSObject

@property (strong, nonatomic) NSNumber* index;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* text;

- (instancetype)initWithDictionary: (NSDictionary *) dict;

@end

@interface PGMetarPage : NSObject

@property (strong, nonatomic) NSNumber* index;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* shortText;
@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) PGMetarLocation* location;
@property (strong, nonatomic) PGMetarIcon* icon;
@property (strong, nonatomic) NSString* from;
@property (strong, nonatomic) NSArray <PGMetarBlock *>* blocks;
@property (strong, nonatomic) NSArray <PGMetarIcon *>* images;
@property (strong, nonatomic) NSArray <NSString *>* externalLinks;

- (instancetype)initWithDictionary: (NSDictionary *) dict;

@end
