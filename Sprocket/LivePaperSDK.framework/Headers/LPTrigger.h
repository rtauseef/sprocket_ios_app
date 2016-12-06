//
//  LPTrigger.h
//  LivePaperSDK
//
//  Copyright (c) 2015 Hewlett-Packard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPSession.h"

FOUNDATION_EXPORT NSString *const LPTriggerErrorDomain;

@interface LPTrigger : NSObject

+ (void) create:(LPSession *) session json:(NSDictionary *) json completionHandler:(void (^)(LPTrigger *trigger, NSError *error)) handler;

+ (void) createShortUrl:(LPSession *) session name:(NSString *) name startDate:(NSDate *) startDate endDate:(NSDate *) endDate completionHandler:(void (^)(LPTrigger *trigger, NSError *error)) handler;

+ (void) createShortUrl:(LPSession *) session name:(NSString *) name completionHandler:(void (^)(LPTrigger *trigger, NSError *error)) handler;

+ (void) createQrCode:(LPSession *) session name:(NSString *) name startDate:(NSDate *) startDate endDate:(NSDate *) endDate completionHandler:(void (^)(LPTrigger *trigger, NSError *error)) handler;

+ (void) createQrCode:(LPSession *) session name:(NSString *) name completionHandler:(void (^)(LPTrigger *trigger, NSError *error)) handler;

+ (void) createWatermark:(LPSession *)session name:(NSString *)name completionHandler:(void (^)(LPTrigger *,NSError *))handler;

+ (void) get:(LPSession *) session triggerId:(NSString *) triggerId completionHandler:(void (^)(LPTrigger *trigger, NSError *error)) handler;

+ (void) list:(LPSession *) session completionHandler:(void (^)(NSArray *triggers, NSError *error)) handler;

@property(nonatomic, readonly) NSString *triggerId;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, readonly) NSString *type;
@property(nonatomic, retain) NSString *state;
@property(nonatomic, retain) NSDate *startDate;
@property(nonatomic, retain) NSDate *endDate;
@property(nonatomic, readonly) NSArray *link;
@property(nonatomic, readonly) NSURL *shortURL;
@property(nonatomic, readonly) NSURL *qrCodeImageURL;
@property(nonatomic, readonly) NSURL *watermarkImageURL;

- (BOOL) isShortURL;
- (BOOL) isQrCode;
- (BOOL) isWatermark;
- (BOOL) isActive;

- (void) getQrCodeImage:(void (^)(UIImage *image, NSError *error)) handler;

/*
 Get the watermarked image at a URL with the default strength and resolution
 */
- (void) getWatermarkForImageURL:(NSURL *) imageURL completionHandler:(void (^)(UIImage *image, NSError *error)) handler;

/*
 Get the watermarked image at a URL with a given strength and resolution.
 */
- (void) getWatermarkForImageURL:(NSURL *) imageURL strength:(int) strength watermarkResolution:(int)watermarkResolution imageResolution:(int)imageResolution completionHandler:(void (^)(UIImage *image, NSError *error)) handler;

/*
 Upload an image and watermark it using the default strength and resolution
 */
- (void) getWatermarkForImageData:(NSData *)data completionHandler:(void (^)(UIImage *image, NSError *error)) handler;

/*
 Upload an image and watermark it using the gien strength and resolution
 */
- (void) getWatermarkForImageData:(NSData *)imageData strength:(int) strength watermarkResolution:(int)watermarkResolution imageResolution:(int)imageResolution completionHandler:(void (^)(UIImage *image, NSError *error)) handler;

- (void) update:(void (^)(NSError *error)) handler;

- (void) delete:(void (^)(NSError *error)) handler;

@end
