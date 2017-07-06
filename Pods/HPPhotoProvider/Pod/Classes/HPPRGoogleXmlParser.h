//
// Hewlett-Packard Company
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import <Foundation/Foundation.h>

@protocol HPPRGoogleXmlParserDelegate;

@interface HPPRGoogleXmlParser : NSObject

@property (strong, nonatomic) NSString *url;
@property (weak,   nonatomic) id<HPPRGoogleXmlParserDelegate>delegate;
@property (strong, nonatomic) NSMutableArray *currentParsingItems;
@property (strong, nonatomic) NSError *error;

- (HPPRGoogleXmlParser *)initWithUrl:(NSString *)url delegate:(id<HPPRGoogleXmlParserDelegate>)delegate completion:(void (^)(NSArray *records, NSError *error))completion;
- (void)startParsing;
    
@end

@protocol HPPRGoogleXmlParserDelegate
    
- (void)didFinishParsing:(HPPRGoogleXmlParser *)parser items:(NSMutableArray *)items completion:(void (^)(NSArray *records, NSError *error))completion;

@end
