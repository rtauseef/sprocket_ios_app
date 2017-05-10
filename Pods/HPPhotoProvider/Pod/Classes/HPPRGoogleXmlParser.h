//
//  HPPRGoogleXmlParser.h
//  Pods
//
//  Created by Susy Snowflake on 5/9/17.
//
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
