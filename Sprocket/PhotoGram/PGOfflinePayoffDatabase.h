//
//  PGOfflinePayoffDatabase.h
//  Sprocket
//
//  Created by Bruno Dal Bo on 4/17/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGPayoffMetadata.h"

@interface PGOfflinePayoffDatabase : NSObject

+(instancetype) sharedInstance;


-(void) saveMetadata:(PGPayoffMetadata *) meta;

-(PGPayoffMetadata*) loadMetadata:(NSString*) id;

@end
