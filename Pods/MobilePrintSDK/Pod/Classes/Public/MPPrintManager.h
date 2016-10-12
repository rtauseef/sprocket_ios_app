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

#import <Foundation/Foundation.h>
#import "MPPageRange.h"
#import "MPPrintSettings.h"
#import "MPPrintItem.h"

@protocol MPPrintManagerDelegate;

/*!
 * @abstract Error types returned by the print:pageRange:numCopies function
 */
typedef enum {
    MPPrintManagerErrorNone,
    MPPrintManagerErrorNoPrinterUrl,
    MPPrintManagerErrorPrinterNotAvailable,
    MPPrintManagerErrorNoPaperType,
    MPPrintManagerErrorDirectPrintNotSupported,
    MPPrintManagerErrorUnknown
} MPPrintManagerError;

/*!
 * @abstract Class used to print on iOS 8 and greater systems
 */
@interface MPPrintManager : NSObject <UIPrintInteractionControllerDelegate>

/*!
 * @abstract Used to hold the print settings for the print job
 */
@property (strong, nonatomic) MPPrintSettings *currentPrintSettings;

/*!
 * @abstract The delegate that will receive callbacks from the print job
 */
@property (weak, nonatomic) id<MPPrintManagerDelegate> delegate;


/*!
 * @abstract Used to construct an MPPrintManager with a set of print settings
 * @param printSettings The print settings to use for the print job
 * @returns An initialized MPPrintManager object
 */
- (id)initWithPrintSettings:(MPPrintSettings *)printSettings;

/*!
 * @abstract Used to perform a print job
 * @discussion If the printSettings object does not contain enough information
 *  to send the print job, no print job will be started and FALSE will be returned.
 *  If run on a version of iOS prior to iOS 8, no print job will be started and
 *  FALSE will be returned
 * @param printItem The item to be printed
 * @param pageRange The page range to be printed
 * @param numCopies The number of copies to print
 * @param errorPtr The NSError object will be populated with any error generated by running
 *   this function
 */
- (void)print:(MPPrintItem *)printItem
    pageRange:(MPPageRange *)pageRange
    numCopies:(NSInteger)numCopies
        error:(NSError **)errorPtr;

/*!
 * @abstract Used to prepare a UIPrintInterationController for printing
 * @discussion This function may be used on iOS 7 and greater.
 * @param controller The UIPrintInteractionController to configure
 * @param printItem The item to be printed
 * @param color If TRUE, a color print will be generated.  If FALSE, a black and
 *  white print will be generated.
 * @param pageRange The page range to be printed
 * @param numCopies The number of copies to print
 */
- (void)prepareController:(UIPrintInteractionController *)controller
                printItem:(MPPrintItem *)printItem
                    color:(BOOL)color
                pageRange:(MPPageRange *)pageRange
                numCopies:(NSInteger)numCopies;

/*
 * @abstract Called when the print item was printed successfully
 * @param printItem The item being printed
 * @param pageRange The range of pages being printed
 */
- (void)processMetricsForPrintItem:(MPPrintItem *)printItem andPageRange:(MPPageRange *)pageRange;

/*!
 * @abstract Indicates if an offramp is a printing offramp
 * @description Identifies print-related offramps such as print, add to queue, and delete from queue.
 * @return YES or NO indicating if the offramp provided is a print-related offramp
 */
+ (BOOL)printingOfframp:(NSString *)offramp;

/*!
 * @abstract Indicates if an offramp is an immediate print offramp
 * @description Identifies print-related offramps that print immediately (rather than delayed printing like add-to-queue)
 * @return YES or NO indicating if the offramp provided is an immediate print offramp
 */
+ (BOOL)printNowOfframp:(NSString *)offramp;

/*!
 * @abstract Indicates if an offramp is a delayed print offramp
 * @description Identifies print-related offramps that print delayed (rather than immediate print offramps like print-from-share)
 * @return YES or NO indicating if the offramp provided is a delayed print offramp
 */
+ (BOOL)printLaterOfframp:(NSString *)offramp;

/*!
 * @abstract The printOfframp string (for prints that bypass the MPPrintManager)
 * @description Returns the print-from-share offramp
 * @return Returns the print-from-share offramp
 */
+ (NSString *)printOfframp;

/*!
 * @abstract The directPrintOfframp string (for prints that bypass the MPPrintManager)
 * @description Returns the print-without-ui offramp
 * @return Returns the print-without-ui offramp
 */
+ (NSString *)directPrintOfframp;

/*!
 * @abstract The printFromActionExtension string (for prints that bypass the MPPrintManager)
 * @description Returns the print-from-action-extension offramp
 * @return Returns the print-from-action-extension offramp
 */
+ (NSString *)printFromActionExtension;
    
@end

/*!
 * @abstract Protocol used to indicate that a page range was selected
 */
@protocol MPPrintManagerDelegate <NSObject>
@optional

/*!
 * @abstract Called when the print job completes
 * @param printController The iOS controller used to print
 * @param completed If TRUE, the print job completed successfully.
 * @param error Any error associated with the print job
 */
- (void)didFinishPrintJob:(UIPrintInteractionController *)printController completed:(BOOL)completed error:(NSError *)error;

@end
