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

#import <XMLDictionary.h>
#import "PGSVGMetadataLoader.h"
#import "PGSVGText.h"

NSString *const kLocationIconColor       = @"locationIconColor";
NSString *const kCommentsIconColor       = @"commentsIconColor";
NSString *const kDateIconColor           = @"dateIconColor";
NSString *const kIsoIconColor            = @"ISOIconColor";
NSString *const kShutterSpeedIconColor   = @"shutterIconColor";
NSString *const kFacebookLikesIconColor  = @"facebookLikesIconColor";
NSString *const kFlickrLikesIconColor    = @"flickrLikesIconColor";
NSString *const kInstagramLikesIconColor = @"instagramLikesIconColor";
NSString *const kBackgroundImage         = @"backgroundImage";
NSString *const kUserMaskImage           = @"userMaskImage";

@implementation PGSVGMetadataLoader

- (NSDictionary *)parseFile:(NSString *)fileName
                       path:(NSString *)path
                     fields:(NSArray *)fields
{
    NSMutableDictionary *resultsDictionary = [[NSMutableDictionary alloc] init];
    
    NSString *pathToSVG = [NSString stringWithFormat:@"%@/%@", path, fileName];
    NSDictionary *xmlDoc = [NSDictionary dictionaryWithXMLFile:pathToSVG];
    NSDictionary *metadata = [xmlDoc objectForKey:@"metadata"];
    NSDictionary *xmpmeta = [metadata objectForKey:@"x:xmpmeta"];
    NSDictionary *rdfRDF = [xmpmeta objectForKey:@"rdf:RDF"];
    NSDictionary *rdfDescription = [rdfRDF objectForKey:@"rdf:Description"];
    
    @try {
        for (NSDictionary *descriptions in rdfDescription) {
            NSArray *keys = [descriptions allKeys];
            
            for (NSString *key in keys) {
                if ([key isEqualToString:@"_xmlns:photogram"]) {
                    
                    if( nil != [descriptions objectForKey:@"photogram:backgroundImage"] ) {
                        [resultsDictionary setObject:[NSString stringWithFormat:@"%@", [descriptions objectForKey:@"photogram:backgroundImage"]] forKey:kBackgroundImage];
                    }
                    
                    if( nil != [descriptions objectForKey:@"photogram:userMaskImage"] ) {
                        [resultsDictionary setObject:[NSString stringWithFormat:@"%@", [descriptions objectForKey:@"photogram:userMaskImage"]] forKey:kUserMaskImage];
                    }
                    
                    // grab all color fields
                    NSString *iconColor               = [descriptions objectForKey:@"photogram:iconColor"];
                    NSString *locationIconColor       = [descriptions objectForKey:@"photogram:locationIconColor"];
                    NSString *commentsIconColor       = [descriptions objectForKey:@"photogram:commentsIconColor"];
                    NSString *dateIconColor           = [descriptions objectForKey:@"photogram:dateIconColor"];
                    NSString *isoIconColor            = [descriptions objectForKey:@"photogram:ISOIconColor"];
                    NSString *shutterSpeedIconColor   = [descriptions objectForKey:@"photogram:shutterIconColor"];
                    NSString *facebookLikesIconColor  = [descriptions objectForKey:@"photogram:facebookLikesIconColor"];
                    NSString *flickrLikesIconColor    = [descriptions objectForKey:@"photogram:flickrLikesIconColor"];
                    NSString *instagramLikesIconColor = [descriptions objectForKey:@"photogram:instagramLikesIconColor"];

                    // default to iconColor where necessary
                    if( nil == iconColor ) { iconColor = @"grey"; }
                    
                    if( nil == locationIconColor )       { locationIconColor       = iconColor; }
                    if( nil == commentsIconColor )       { commentsIconColor       = iconColor; }
                    if( nil == dateIconColor )           { dateIconColor           = iconColor; }
                    if( nil == isoIconColor )            { isoIconColor            = iconColor; }
                    if( nil == shutterSpeedIconColor )   { shutterSpeedIconColor   = iconColor; }
                    if( nil == facebookLikesIconColor )  { facebookLikesIconColor  = iconColor; }
                    if( nil == flickrLikesIconColor )    { flickrLikesIconColor    = iconColor; }
                    if( nil == instagramLikesIconColor ) { instagramLikesIconColor = iconColor; }
                    
                    // load the results dictionary with the final color fields
                    [resultsDictionary setObject:locationIconColor       forKey:kLocationIconColor];
                    [resultsDictionary setObject:commentsIconColor       forKey:kCommentsIconColor];
                    [resultsDictionary setObject:dateIconColor           forKey:kDateIconColor];
                    [resultsDictionary setObject:isoIconColor            forKey:kIsoIconColor];
                    [resultsDictionary setObject:shutterSpeedIconColor   forKey:kShutterSpeedIconColor];
                    [resultsDictionary setObject:facebookLikesIconColor  forKey:kFacebookLikesIconColor];
                    [resultsDictionary setObject:flickrLikesIconColor    forKey:kFlickrLikesIconColor];
                    [resultsDictionary setObject:instagramLikesIconColor forKey:kInstagramLikesIconColor];
                    
                    // gather textfield info
                    for (PGSVGText *textField in fields) {
                        for (NSString *key in [textField.fields allKeys]) {
                            NSString *completeKey = [NSString stringWithFormat:@"photogram:%@%@", textField.name, key];
                            NSString *value = [descriptions objectForKey:completeKey];
                            [textField.fields setValue:value forKey:key];
                        }
                    }
                }
            }
        }
    }
    @catch (NSException *e){
#ifdef DEBUG
        NSString *errorText = [NSString stringWithFormat:NSLocalizedString(@"The format of the following template is bad: %@", @"The metadata of the template used is incorrect"), fileName];
        
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops! Call in the Designers!", nil)
                                    message:errorText
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil] show];
#else
        PGLogError(@"Bad format in file: %@; Exception: %@", fileName, e);
#endif
    }
    
    return resultsDictionary;
}

@end
