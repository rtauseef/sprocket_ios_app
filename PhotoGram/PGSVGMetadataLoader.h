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

// the following constants are used as keys in the dictionary returned by the parseFile function
extern NSString *const kLocationIconColor;
extern NSString *const kCommentsIconColor;
extern NSString *const kDateIconColor;
extern NSString *const kIsoIconColor;
extern NSString *const kShutterSpeedIconColor;
extern NSString *const kFacebookLikesIconColor;
extern NSString *const kFlickrLikesIconColor;
extern NSString *const kInstagramLikesIconColor;
extern NSString *const kBackgroundImage;
extern NSString *const kUserMaskImage;

@interface PGSVGMetadataLoader : NSObject <NSXMLParserDelegate>

- (NSDictionary *)parseFile:(NSString *)fileName path:(NSString *)path fields:(NSArray *)fields;

@end