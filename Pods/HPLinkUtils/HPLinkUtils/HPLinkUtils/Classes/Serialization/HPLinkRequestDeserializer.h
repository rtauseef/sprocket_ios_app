//
//  HPLinkRequestDeserializer.h
//  HPLinkUtils
//
//  Created by Alejandro Mendez on 1/12/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HPLinkRequestDeserializer <NSObject>

- (nullable id)deserializeData:(nonnull id)data error:(NSError * _Nullable * _Nullable )error;

@end
