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

#import "HPPRGoogleXmlParser.h"
#import <Google/SignIn.h>

@interface HPPRGoogleXmlParser() <NSXMLParserDelegate>
    
@property (nonatomic, strong) NSXMLParser *rssParser;
@property (nonatomic, strong) NSMutableDictionary *item;
@property (nonatomic, strong) NSMutableString *elementValue;
@property (nonatomic, strong) NSMutableURLRequest *request;
    
@property (nonatomic, strong) NSString *userThumbnail;
@property (nonatomic, strong) NSString *userName;
@property (copy) void (^completionBlock)(NSArray *records, NSError *error);
    
@end

@implementation HPPRGoogleXmlParser

- (HPPRGoogleXmlParser *)initWithUrl:(NSString *)url delegate:(id<HPPRGoogleXmlParserDelegate>)delegate completion:(void (^)(NSArray *records, NSError *error))completion
{
    self = [super init];
        
    if (self) {
        _url = url;
        
        NSString *agentString = @"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_6; en-us) AppleWebKit/525.27.1 (KHTML, like Gecko) Version/3.2.1 Safari/525.27.1";
        _request = [NSMutableURLRequest requestWithURL:
                                        [NSURL URLWithString:_url]];
        [_request setValue:agentString forHTTPHeaderField:@"User-Agent"];
        
        [_request setHTTPMethod:@"GET"];
        [_request setValue:[NSString stringWithFormat:@"Bearer %@", [GIDSignIn sharedInstance].currentUser.authentication.accessToken] forHTTPHeaderField:@"Authorization"];
        [_request setValue:@"3" forHTTPHeaderField:@"GData-Version"];
        
        _delegate = delegate;
        _completionBlock = completion;
    }
    
    return self;
}
    
- (void)startParsing
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:_request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable xmlData, NSError * _Nullable error) {
        if (error) {
            
        } else {
            self.currentParsingItems = [[NSMutableArray alloc] init];
            
            self.rssParser = [[NSXMLParser alloc] initWithData:xmlData];

            [self.rssParser setDelegate:self];
            [self.rssParser setShouldProcessNamespaces:NO];
            [self.rssParser setShouldReportNamespacePrefixes:NO];
            [self.rssParser setShouldResolveExternalEntities:NO];
            
            [self.rssParser parse];
        }
    }];
}
    
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    self.error = parseError;
}
    
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    self.elementValue = [[NSMutableString alloc] init];
    if ([elementName isEqualToString:@"entry"]) {
        self.item = [[NSMutableDictionary alloc] init];
        
    } else if ([elementName isEqualToString:@"media:thumbnail"]) {
        NSMutableArray *thumbnails = [self.item objectForKey:@"thumbnails"];
        
        if (nil == thumbnails) {
            thumbnails = [[NSMutableArray alloc] init];
        }
        
        [thumbnails addObject:[self removePlayItemFromDict:attributeDict forKey:@"url"]];
        [self.item setObject:thumbnails forKey:@"thumbnails"];
    } else if ([elementName isEqualToString:@"media:content"]) {
        NSMutableArray *contents = [self.item objectForKey:@"contents"];
        
        if (nil == contents) {
            contents = [[NSMutableArray alloc] init];
        }
        
        [contents addObject:[self removePlayItemFromDict:attributeDict forKey:@"url"]];
        [self.item setObject:contents forKey:@"contents"];
    } else if ([elementName isEqualToString:@"content"]) {
        [self.item setObject:[self removePlayItemFromDict:attributeDict forKey:@"src"] forKey:@"original"];
    }
}

- (NSDictionary *)removePlayItemFromDict:(NSDictionary *)attributeDict forKey:(NSString *)attributeName {
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
    
    if (attributeDict != nil) {
        NSString *url = [attributeDict objectForKey:attributeName];
        
        if (url != nil) {
            NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"/s([0-9]+)(\\-c)?/" options:NSRegularExpressionCaseInsensitive error:&error];
            NSString *modifiedString = [regex stringByReplacingMatchesInString:url options:0 range:NSMakeRange(0, [url length]) withTemplate:@"/s$1-c-no/"];
            [mutDict setValue:modifiedString forKey:attributeName];
        }
    }
    
    return mutDict;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"entry"]) {
        if (self.userThumbnail) {
            [self.item setObject:self.userThumbnail forKey:@"userThumbnail"];
        }
        if (self.userName) {
            [self.item setObject:self.userName forKey:@"userName"];
        }
        
        [self.currentParsingItems addObject:self.item];
    } else if ([elementName isEqualToString:@"gphoto:thumbnail"]) {
        self.userThumbnail = self.elementValue;
    } else if ([elementName isEqualToString:@"gphoto:nickname"]) {
        self.userName = self.elementValue;
    } else {
        [self.item setObject:self.elementValue forKey:elementName];
    }
}
    
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [self.elementValue appendString:string];
}
    
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (!self.error)
    {
        NSLog(@"XML processing done!");
        
        if (self.delegate) {
            [self.delegate didFinishParsing:self items:self.currentParsingItems completion:_completionBlock];
        }
    } else {
        NSLog(@"Error occurred during XML processing");
        self.currentParsingItems = [[NSMutableArray alloc] init];
    }
}

@end
