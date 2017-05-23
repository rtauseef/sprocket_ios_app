//
//  HPPRWikipediaMedia.m
//  Pods
//
//  Created by Fernando Caprio on 5/23/17.
//
//

#import "HPPRWikipediaMedia.h"
#import "HPPRWikipediaPhotoProvider.h"

@implementation HPPRWikipediaMedia

- (HPPRSelectPhotoProvider *)photoProvider {
    return [HPPRWikipediaPhotoProvider sharedInstance];
}


@end
