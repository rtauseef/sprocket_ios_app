//
// HP Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import "MPBTSprocket+Protected.h"

static const NSString *kFirmwareUpdatePath = @"https://s3-us-west-2.amazonaws.com/sprocket-fw-updates-2/fw_release.json";
static const NSString *kExperimentalFirmwareUpdatePath = @"https://s3-us-west-2.amazonaws.com/sprocket-fw-update-test/fw_release.json";

@implementation MPBTSprocket (Protected)

#pragma mark -
#pragma mark Supported protocols

- (NSString *)supportedProtocolString:(EAAccessory *)accessory
{
    NSAssert(FALSE, @"Need to implement supportedProtocolString");
    
    return nil;
}

#pragma mark -
#pragma mark Scale and crop image

- (UIImage*)imageByScalingAndCroppingForSize:(UIImage *)image targetSize:(CGSize)targetSize
{
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        MPLogError(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark -
#pragma mark Firmware

+ (NSUInteger)fwVersionFromString:(NSString *)strVersion
{
    NSUInteger fwVersion = 0;
    
    if (![strVersion isEqualToString:@"none"]) {
        NSArray *bytes = [strVersion componentsSeparatedByString:@"."];
        NSInteger topIdx = bytes.count-1;
        for (NSInteger idx = topIdx; idx >= 0; idx--) {
            NSString *strByte = bytes[idx];
            NSInteger byte = [strByte integerValue];
            
            NSInteger shiftValue = topIdx-idx;
            fwVersion += (byte << (8 * shiftValue));
        }
    }
    
    return fwVersion;
}

+ (void)getFirmwareUpdateInfo:(void (^)(NSDictionary *fwUpdateInfo))completion
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.URLCache = nil;
    NSURLSession *httpSession = [NSURLSession sessionWithConfiguration:config delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    const NSString *fwInfoPath = [MPBTSprocket useExperimentalFirmware] ? kExperimentalFirmwareUpdatePath : kFirmwareUpdatePath;
    
    [[httpSession dataTaskWithURL: [NSURL URLWithString:[fwInfoPath copy]]
                completionHandler:^(NSData *data, NSURLResponse *response,
                                    NSError *error) {
                    NSDictionary *fwUpdateInfo = nil;
                    if (data  &&  !error) {
                        NSError *error;
                        NSDictionary *fwDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                        if (fwDictionary) {
                            MPLogInfo(@"FW Update:  Result = %@", fwDictionary);
                            fwUpdateInfo = [fwDictionary valueForKey:@"firmware"];
                        } else {
                            MPLogError(@"FW Update:  Parse Error = %@", error);
                            NSString *returnString = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
                            MPLogInfo(@"FW Update:  Return string = %@", returnString);
                        }
                    } else {
                        MPLogError(@"FW Update Info failure: %@, data: %@", error, data);
                    }
                    
                    if (completion) {
                        completion(fwUpdateInfo);
                    }
                }] resume];
}

+ (NSDictionary *)getCorrectFirmwareVersion:(NSArray *)fwInfo forExistingVersion:(NSUInteger)existingFwVersion
{
    NSDictionary *correctFwVersionInfo = nil;
    
    if (nil != fwInfo) {
        
        // Create a dictionary for quick look-up of dependency versions
        NSMutableDictionary *fwVersions = [[NSMutableDictionary alloc] init];
        NSUInteger length = [fwInfo count];
        NSString *strVersion = nil;
        for (int idx=0; idx<length; ++idx) {
            NSDictionary *fwVersionInfo = [fwInfo objectAtIndex:idx];
            strVersion = [fwVersionInfo objectForKey:@"fw_ver"];
            [fwVersions setObject:fwVersionInfo forKey:strVersion];
        }
        
        // Start with the latest version. Install it, or any necessary dependency
        BOOL keepChecking = YES;
        while (keepChecking) {
            NSDictionary *fwVersionInfo = [fwVersions objectForKey:strVersion];
            strVersion = [fwVersionInfo objectForKey:@"fw_ver"];
            NSUInteger fwVersion = [MPBTSprocket fwVersionFromString:strVersion];
            
            if (existingFwVersion < fwVersion) {
                // check the dependency
                NSString *dependencyStrVersion = [fwVersionInfo objectForKey:@"dependency"];
                NSUInteger dependencyFwVersion = [MPBTSprocket fwVersionFromString:dependencyStrVersion];
                if (existingFwVersion < dependencyFwVersion) {
                    strVersion = dependencyStrVersion;
                    keepChecking = YES;
                } else {
                    keepChecking = NO;
                }
            } else {
                keepChecking = NO;
            }
        }
        
        correctFwVersionInfo = [fwVersions objectForKey:strVersion];
    }
    
    return correctFwVersionInfo;
}

+ (void)latestFirmwareVersion:(NSString *)protocolString forExistingVersion:(NSUInteger)existingFwVersion completion:(void (^)(NSUInteger fwVersion))completion
{
    [MPBTSprocket getFirmwareUpdateInfo:^(NSDictionary *fwUpdateInfo){
        NSUInteger fwVersion = 0;
        NSDictionary *deviceUpdateInfo = nil;
        
        if (nil != fwUpdateInfo) {
            if ([kPolaroidProtocol isEqualToString:protocolString]) {
                deviceUpdateInfo = [fwUpdateInfo objectForKey:@"Polaroid"];
            } else {
                NSArray *info = [fwUpdateInfo objectForKey:@"HP"];
                deviceUpdateInfo = [MPBTSprocket getCorrectFirmwareVersion:info forExistingVersion:existingFwVersion];
            }
            
            if (deviceUpdateInfo) {
                NSString *strVersion = [deviceUpdateInfo objectForKey:@"fw_ver"];
                fwVersion = [MPBTSprocket fwVersionFromString:strVersion];
            } else {
                MPLogError(@"Unrecognized firmware update info: %@", fwUpdateInfo);
            }
            
            if (completion) {
                completion(fwVersion);
            }
        }
    }];
}

+ (void)latestFirmwarePath:(NSString *)protocolString forExistingVersion:(NSUInteger)existingFwVersion completion:(void (^)(NSString *fwPath))completion
{
    [MPBTSprocket getFirmwareUpdateInfo:^(NSDictionary *fwUpdateInfo){
        NSString *fwPath = nil;
        NSDictionary *deviceUpdateInfo = nil;
        
        if (nil != fwUpdateInfo) {
            if ([kPolaroidProtocol isEqualToString:protocolString]) {
                deviceUpdateInfo = [fwUpdateInfo objectForKey:@"Polaroid"];
            } else {
                NSArray *info = [fwUpdateInfo objectForKey:@"HP"];
                deviceUpdateInfo = [MPBTSprocket getCorrectFirmwareVersion:info forExistingVersion:existingFwVersion];
            }
            
            if (deviceUpdateInfo) {
                fwPath = [deviceUpdateInfo objectForKey:@"fw_url"];
            } else {
                MPLogError(@"Unrecognized firmware update info: %@", fwUpdateInfo);
            }
            
            if (completion) {
                completion(fwPath);
            }
        }
    }];
}

#pragma mark -
#pragma mark Internal strings

+ (NSString *)printModeString:(SprocketPrintMode)mode
{
    NSString *modeString;
    
    switch (mode) {
        case SprocketPrintModePaperFull:
            modeString = @"SprocketPrintModePaperFull";
            break;
        case SprocketPrintModeImageFull:
            modeString = @"SprocketPrintModeImageFull";
            break;
            
        default:
            modeString = [NSString stringWithFormat:@"Unrecognized print mode: %d", mode];
            break;
    };
    
    return modeString;
}

+ (NSString *)autoExposureString:(SprocketAutoExposure)exp
{
    NSString *expString;
    
    switch (exp) {
        case SprocketAutoExposureOff:
            expString = @"SprocketAutoExposureOff";
            break;
        case SprocketAutoExposureOn:
            expString = @"SprocketAutoExposureOn";
            break;
            
        default:
            expString = [NSString stringWithFormat:@"Unrecognized auto exposure: %d", exp];
            break;
    };
    
    return expString;
}

+ (NSString *)dataClassificationString:(SprocketDataClassification)class
{
    NSString *classString;
    
    switch (class) {
        case SprocketDataClassImage:
            classString = @" SprocketDataClassImage";
            break;
        case SprocketDataClassTMD:
            classString = @"SprocketDataClassTMD";
            break;
        case SprocketDataClassFirmware:
            classString = @"SprocketDataClassFirmware";
            break;
            
        default:
            classString = [NSString stringWithFormat:@"Unrecognized classification: %d", class];
            break;
    };
    
    return classString;
}

+ (NSString *)upgradeStatusString:(SprocketUpgradeStatus)status
{
    NSString *statusString;
    
    switch (status) {
        case SprocketUpgradeStatusStart:
            statusString = @"SprocketUpgradeStatusStart";
            break;
        case SprocketUpgradeStatusFinish:
            statusString = @"SprocketUpgradeStatusFinish";
            break;
        case SprocketUpgradeStatusFail:
            statusString = @"SprocketUpgradeStatusFail";
            break;
            
        default:
            statusString = [NSString stringWithFormat:@"Unrecognized status: %d", status];
            break;
    };
    
    return statusString;
}

@end
