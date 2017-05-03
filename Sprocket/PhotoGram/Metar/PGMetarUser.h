//
//  PGMetarUser.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/3/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGMetarUser : NSObject<NSCoding> {

}

@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *secret;
@property (strong, nonatomic) NSString *accountID;

@end
