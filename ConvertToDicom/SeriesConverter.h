//
//  SeriesConverter.h
//  ConvertToDicom
//

/* ConvertToDicom converts a series of images to DICOM format from any format recognized
 * by ITK (http://www.itk.org).
 * Copyright (C) 2014  Tim Allman
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

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
