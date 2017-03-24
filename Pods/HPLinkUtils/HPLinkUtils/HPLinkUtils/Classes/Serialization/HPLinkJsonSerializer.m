//
//  HPLinkJsonSerializer.m
//  HPLinkUtils
//
//  Created by Alejandro Mendez on 1/12/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import "HPLinkJsonSerializer.h"

@implementation HPLinkJsonSerializer

-(id)deserializeData:(id)data error:(NSError **)error {
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
}

-(NSData*)serializeObject:(id)object error:(NSError **)error {
    return [NSJSONSerialization dataWithJSONObject:object options:0 error:error];
}

@end
