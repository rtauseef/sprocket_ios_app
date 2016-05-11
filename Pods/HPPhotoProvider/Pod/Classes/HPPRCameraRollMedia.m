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

#import "HPPRCameraRollMedia.h"
#import "HPPRCameraRollLoginProvider.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>

@implementation HPPRCameraRollMedia

- (id)initWithAsset:(ALAsset *)asset;
{
    self = [super init];
 
    if (self) {
        // Uncomment the following in order to see ALL photo info
        // [self printAllPhotoInfo:asset];

        self.objectID = [[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
        self.thumbnailUrl = [[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
        self.standardUrl = [[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
        self.createdTime = [asset valueForProperty:ALAssetPropertyDate];

        self.location = [asset valueForProperty:ALAssetPropertyLocation];

        ALAssetRepresentation *representation = [asset defaultRepresentation];
        NSDictionary *imageMetadata = [representation metadata];
        NSDictionary *exifDictionary = [imageMetadata objectForKey:(NSString *)kCGImagePropertyExifDictionary];

        NSNumber* shutterSpeed = [exifDictionary objectForKey:(NSString *)kCGImagePropertyExifShutterSpeedValue];
        if( shutterSpeed ) {
            // shutter speed formula: http://www.media.mit.edu/pia/Research/deepview/exif.html
            self.shutterSpeed = [NSString stringWithFormat:@"1/%.0f", pow(2,[shutterSpeed floatValue])];
        }
        
        NSArray *ISOSpeed = [exifDictionary objectForKey:(NSString *)kCGImagePropertyExifISOSpeedRatings];
        if( ISOSpeed ) {
            self.isoSpeed = [ISOSpeed objectAtIndex:0];
        }
    }

    return self;
}

-(void) printAllPhotoInfo:(ALAsset *)asset {
    
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    NSDictionary *imageMetadata = [representation metadata];
    
    NSDictionary *tiffDictionary = [imageMetadata objectForKey:(NSString *)kCGImagePropertyTIFFDictionary];
    NSString *cameraMake = [tiffDictionary objectForKey:(NSString *)kCGImagePropertyTIFFMake];
    NSString *cameraModel = [tiffDictionary objectForKey:(NSString *)kCGImagePropertyTIFFModel];
    NSString *cameraSoftware = [tiffDictionary objectForKey:(NSString *)kCGImagePropertyTIFFSoftware];
    NSString *photoCopyright = [tiffDictionary objectForKey:(NSString *)kCGImagePropertyTIFFCopyright];
    
    
    NSDictionary *exifDictionary = [imageMetadata objectForKey:(NSString *)kCGImagePropertyExifDictionary];
    NSString *lensMake = [exifDictionary objectForKey:(NSString *)kCGImagePropertyExifLensMake];
    NSString *lensModel = [exifDictionary objectForKey:(NSString *)kCGImagePropertyExifLensModel];
    NSString *exposureTime = [exifDictionary objectForKey:(NSString *)kCGImagePropertyExifExposureTime];
    NSString *exposureProgram = [exifDictionary objectForKey:(NSString *)kCGImagePropertyExifExposureProgram];
    NSString *dateTime = [exifDictionary objectForKey:(NSString *)kCGImagePropertyExifDateTimeOriginal];
    NSString *apertureValue = [exifDictionary objectForKey:(NSString *)kCGImagePropertyExifApertureValue];
    NSString *focalLength = [exifDictionary objectForKey:(NSString *)kCGImagePropertyExifFocalLength];
    NSString *whiteBalance = [exifDictionary objectForKey:(NSString *)kCGImagePropertyExifWhiteBalance];
    NSString *shutterSpeed = [exifDictionary objectForKey:(NSString *)kCGImagePropertyExifShutterSpeedValue];
    NSArray *ISOSpeed = [exifDictionary objectForKey:(NSString *)kCGImagePropertyExifISOSpeedRatings];
    
    NSNumber *photoSize = [imageMetadata objectForKey:(NSString *)kCGImagePropertyFileSize];
    NSString *photoWidth = [imageMetadata objectForKey:(NSString *)kCGImagePropertyPixelWidth];
    NSString *photoHeight = [imageMetadata objectForKey:(NSString *)kCGImagePropertyPixelHeight];
    
    NSDictionary *gpsDictionary = [imageMetadata objectForKey:(NSString *)kCGImagePropertyGPSDictionary];
    NSString *gpsLatitude = [gpsDictionary objectForKey:(NSString *)kCGImagePropertyGPSLatitude];
    NSString *gpsLatitudeRef = [gpsDictionary objectForKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    NSString *gpsLongitude = [gpsDictionary objectForKey:(NSString *)kCGImagePropertyGPSLongitude];
    NSString *gpsLongitudeRef = [gpsDictionary objectForKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    
    NSLog(@"MAKE = %@", cameraMake);
    NSLog(@"MODEL = %@", cameraModel);
    NSLog(@"SOFTWARE = %@", cameraSoftware);
    NSLog(@"COPYRIGHT = %@", photoCopyright);
    NSLog(@"LENS MAKE = %@", lensMake);
    NSLog(@"LENS MODEL = %@", lensModel);
    NSLog(@"EXPOSURE TIME = %@", exposureTime);
    NSLog(@"EXPOSURE PROGRAM = %@", exposureProgram);
    NSLog(@"ISO SPEED = %@", ISOSpeed);
    NSLog(@"DATE & TIME = %@", dateTime);
    NSLog(@"SHUTTER SPEED = %@", shutterSpeed);
    NSLog(@"APERTURE VALUE = %@", apertureValue);
    NSLog(@"FOCAL LENGTH = %@", focalLength);
    NSLog(@"WHITE BALANCE = %@", whiteBalance);
    NSLog(@"IMAGE SIZE = %@", photoSize);
    NSLog(@"IMAGE WIDTH = %@", photoWidth);
    NSLog(@"IMAGE HEIGHT = %@", photoHeight);
    NSLog(@"GPS Coordinates: %@ %@ / %@ %@", gpsLatitude, gpsLatitudeRef, gpsLongitude, gpsLongitudeRef);
}

@end
