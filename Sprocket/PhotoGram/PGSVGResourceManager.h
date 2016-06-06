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
#import "MPLayout.h"

@interface PGSVGResourceManager : MPLayout

/*!
 * @abstract Returns the filename (no path) for the resource.  The filename includes the .svg extension.
 * @param filename The filename of the SVG resource, with or without a .hpc or .svg extension, and with or without the path appended to the front of it.
 * @discussion Returns the proper .svg filename for the resource, whether or not it actually exists.
 */
+ (NSString *)getFilenameForSvgResource:(NSString *)filename;

/*!
 * @abstract Returns the path (excluding filename) of the SVG resource specified by filename
 * @param filename The filename of the SVG resource, with or without a .hpc or .svg extension.
 * @param forceUnizp If TRUE, .hpc files are unzipped even if the corresponding .svg file already exists
 * @discussion Takes the filename and searches for the associated .svg or .hpc resource.  If the .svg resource exists, the path to that resource (excluding filename) is returned.  If the .hpc resource exists, but the .svg resource does not, the .hpc resource is unzipped and the path to the resulting .svg resource (excluding filename) is returned.  If no .svg file can be found or generated, nil is returned.
 */
+ (NSString *)getPathForSvgResource:(NSString *)filename forceUnzip:(BOOL)forceUnzip;

/*!
 * @abstract Returns the directory all .hpc files are unzipped into
 * @discussion Currently, all .hpc files are unzipped into the application's Documents directory.  So, this function returns that directory.
 */
+ (NSString *)hpcDirectory;

/*!
 * @abstract Unzips all .hpc files within the application's main bundle.
 * @param forceUnizp If TRUE, .hpc files are unzipped even if the corresponding .svg file already exists
 * @discussion If a .hpc file within the main bundle has not yet been unzipped, it is unzipped to the hpcDirectory.
 */
+ (void)unzipAllHpcFiles:(BOOL)forceUnzip;

/*!
 * @abstract Unzips the specified .hpc file into the hpcDirectory
 * @param fullFilename The fully qualified filename of the .hpc file extension.
 * @discussion Returns TRUE if the file was successfully unzipped, FALSE otherwise.
 */
+ (BOOL)unzipHpcFile:(NSString *)fullFilename;

@end
