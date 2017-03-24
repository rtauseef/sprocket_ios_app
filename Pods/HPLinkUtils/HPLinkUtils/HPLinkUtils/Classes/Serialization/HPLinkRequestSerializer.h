//
//  HPLinkRequestSerializer.h
//  HPLinkUtils
//
//  Created by Alejandro Mendez on 1/12/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HPLinkRequestSerializer <NSObject>

- (nullable NSData*)serializeObject:(nullable id)object error:(NSError * _Nullable * _Nullable)error;

@end
