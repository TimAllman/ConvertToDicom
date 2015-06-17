//
//  SeriesConverter.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-24.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ErrorCodes.h"
#import "WindowController.h"

@class SeriesInfo;
@class Logger;

/**
 * Class to do the conversion work. It reads the image files, converts them to DICOM
 * and writes them out as DICOM files.
 */
@interface SeriesConverter : NSObject
{
    Logger* logger_;                      ///< Logger for this class.
    NSMutableArray* fileNames;            ///< The list of input file names.
    WindowController* windowController;   ///< The window controller which created this instance.
}

@property (retain) NSURL* inputDir;         ///< Where the input files are found.
@property (retain) NSURL* outputDir;        ///< Where to put the output file tree.
@property (retain) SeriesInfo* seriesInfo;  ///< Information about the series.


/**
 * init with WindowController which creates this instance
 * @param controller The WindowController instance.
 * @returns self or nil
 */
- (id)initWithController:(WindowController*)controller andInfo:(SeriesInfo*)info;

/**
 * Load all of the names within the input directory. Assumes that these are all suitable 
 * image files.
 * @return Suitable code in ErrorCode enum.
 */
- (ErrorCode)loadFileNames;

/**
 * Tries to get as much metadata from the input image files as possible.
 * @return Suitable code in ErrorCode enum.
 */
- (ErrorCode)extractSeriesAttributes;

/**
 * Read the input files and write the DICOM files to the output directory. A directory tree is
 * formed like this: patientsName/studyDescription - studyID/seriesDescription - seriesNumber.
 * @return Suitable code in ErrorCode enum.
 */
- (ErrorCode)convertFiles;

@end
