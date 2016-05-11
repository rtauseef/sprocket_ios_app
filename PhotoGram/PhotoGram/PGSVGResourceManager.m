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

#import "PGSVGResourceManager.h"
#import "ZipArchive.h"

@implementation PGSVGResourceManager

// Returns the filename (with .svg extension) for any short name or full path to an hpc or svg file.
+ (NSString *)getFilenameForSvgResource:(NSString *)filename
{
    // strip the path and file extension from filename
    filename = [filename lastPathComponent];
    filename = [filename stringByReplacingOccurrencesOfString:@".hpc" withString:@""];
    filename = [filename stringByReplacingOccurrencesOfString:@".svg" withString:@""];
    
    // add .svg to whatever is left
    filename = [NSString stringWithFormat:@"%@.svg", filename];
    
    return filename;
}

// Since .svg files can be found in the main bundle, in the Documents directory, or
//  zipped up in a .hpc file, we create a single function for finding them
+ (NSString *)getPathForSvgResource:(NSString *)filename forceUnzip:(BOOL)forceUnzip
{
    NSString *retPath = nil;
    
    // Strip off all extensions... we will determine if .svg file already exists
    filename = [filename lastPathComponent];
    filename = [filename stringByReplacingOccurrencesOfString:@".svg" withString:@""];
    filename = [filename stringByReplacingOccurrencesOfString:@".hpc" withString:@""];
    
    // Create the desired fully qualified filenames and search
    NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *mainBundleFileName = [NSString stringWithFormat:@"%@/%@.svg", mainBundlePath, filename];
    
    NSString *docsFilename = [NSString stringWithFormat:@"%@/%@.svg", [PGSVGResourceManager hpcDirectory], filename];
    
    // Order matters... main bundle items can be replaced by writing new versions to the docs directory.
    //  So, always return the item in the docs directory, if it exists
    if( !forceUnzip  &&  [[NSFileManager defaultManager] fileExistsAtPath:docsFilename] ) {
        retPath = [PGSVGResourceManager hpcDirectory];
    } else if ( !forceUnzip  &&  [[NSFileManager defaultManager] fileExistsAtPath:mainBundleFileName] ) {
        retPath = mainBundlePath;
    } else {
        // Order matters... main bundle items can be replaced by writing new versions to the docs directory.
        //  So, always use the item in the docs directory, if it exists
        NSString *hpcFilename = [NSString stringWithFormat:@"%@/%@.hpc", [PGSVGResourceManager hpcDirectory], filename];
        if( ![[NSFileManager defaultManager] fileExistsAtPath:hpcFilename] ) {
            hpcFilename = [NSString stringWithFormat:@"%@/%@.hpc", mainBundlePath, filename];
        }
        
        if( [[NSFileManager defaultManager] fileExistsAtPath:hpcFilename] &&
            [PGSVGResourceManager unzipHpcFile:hpcFilename] ) {
            if( [[NSFileManager defaultManager] fileExistsAtPath:docsFilename] ) {
                retPath = [PGSVGResourceManager hpcDirectory];
            } else {
                PGLogError(@"%@ unzipped successfully, but lost", hpcFilename);
            }
        }
        else {
            PGLogError(@"Unable to handle %@ as a .svg or .hpc file", filename);
        }
    }
    
    return retPath;
}

+ (NSString *)hpcDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
}

+ (void)unzipAllHpcFiles:(BOOL)forceUnzip
{
    NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [fm contentsOfDirectoryAtPath:mainBundlePath error:nil];
    
    for( NSString *file in files ) {       
        if( [file hasSuffix:@".hpc"] ) {
            NSString *name = [file stringByReplacingOccurrencesOfString:@".hpc" withString:@""];
            
            // The following function will unzip the file only if necessary.
            //  If it has already been unzipped, it will skip it.
            [PGSVGResourceManager getPathForSvgResource:name forceUnzip:forceUnzip];
        }
    }
}

// All HPC files are unzipped to the Documents directory
//  This was done because the SVGLoader does not handle new files added to
//  the main app bundle until the app is restarted.
+ (BOOL)unzipHpcFile:(NSString *)fullFilename
{
    BOOL retVal = FALSE;
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    if([zipArchive UnzipOpenFile:fullFilename]) {
        if ([zipArchive UnzipFileTo:[PGSVGResourceManager hpcDirectory] overWrite:YES]) {
            retVal = TRUE;
            
            PGLogInfo(@"Unzipping %@ to %@", fullFilename, [PGSVGResourceManager hpcDirectory]);
            
            // clean up by deleting unnecessary hpc file...
            //  this doesn't actually work, but it produces no error and we need to try
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:fullFilename error:&error];
            if( error ) {
                PGLogError(@"Failed to delete %@ after unzipping", fullFilename);
            }
            
            // clean up by deleting unnecessary __MACOSX directory
            fullFilename = [NSString stringWithFormat:@"%@/__MACOSX", [PGSVGResourceManager hpcDirectory]];
            [[NSFileManager defaultManager] removeItemAtPath:fullFilename error:&error];
            if( error ) {
                PGLogError(@"Error removing unzip directory");
            }
        } else {
            PGLogError(@"Unable to unzip %@ to %@", fullFilename, [PGSVGResourceManager hpcDirectory]);
        }
    }
    
    return retVal;
}

@end
