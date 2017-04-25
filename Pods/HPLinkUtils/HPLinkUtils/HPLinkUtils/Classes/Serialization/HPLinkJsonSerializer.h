//
//  HPLinkJsonSerializer.h
//  HPLinkUtils
//
//  Created by Alejandro Mendez on 1/12/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HPLinkUtils/HPLinkRequestDeserializer.h>
#import <HPLinkUtils/HPLinkRequestSerializer.h>

@interface HPLinkJsonSerializer : NSObject <HPLinkRequestSerializer, HPLinkRequestDeserializer>

@end
