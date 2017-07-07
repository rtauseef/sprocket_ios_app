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

#import "PFPhotoFix.h"
#import "TH_iOSWrapper.h"



@implementation PFPhotoFix

CGColorSpaceRef colorspace;
CGDataProviderRef provider;
CGImageRef destImageRef;


+(UIImage *)applyTo:(UIImage *)image
{
    UIImage *photoFixedImage = nil;
    
    if (image) {
        unsigned long width = CGImageGetWidth(image.CGImage);
        unsigned long height = CGImageGetHeight(image.CGImage);
        
        NSData *imageData = (__bridge NSData *)CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
        
        unsigned char *pixelsPtr = (unsigned char*) [imageData bytes];
        
        BOOL success = EverestRunMainTH(image, pixelsPtr);
        if (success) {

            
            provider = CGDataProviderCreateWithData(NULL, pixelsPtr, [imageData length], NULL);
            colorspace = CGColorSpaceCreateDeviceRGB();
            destImageRef = CGImageCreate  (
                                              width,
                                              height,
                                              CGImageGetBitsPerComponent(image.CGImage),
                                              CGImageGetBitsPerPixel(image.CGImage),
                                              CGImageGetBytesPerRow(image.CGImage),
                                              colorspace,
                                              CGImageGetBitmapInfo(image.CGImage),
                                              provider,
                                              NULL,
                                              NO,
                                              kCGRenderingIntentDefault);
            
            photoFixedImage = [UIImage imageWithCGImage:destImageRef];
            
            //cleanup
            CGColorSpaceRelease(colorspace);
            CGDataProviderRelease(provider);
            CGImageRelease(destImageRef);
            
//            UIImageWriteToSavedPhotosAlbum(photoFixedImage, self, @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), NULL);
//            
//#if 0  // for verification
//            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//            NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
//            NSString *filePath = [ basePath stringByAppendingPathComponent:@"Image.png"];
//            [UIImagePNGRepresentation(photoFixedImage) writeToFile:filePath atomically:YES];
//#endif
        }
    }
    return photoFixedImage;
}

@end
