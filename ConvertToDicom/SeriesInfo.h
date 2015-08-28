//
//  SeriesInfo.h
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

@class Logger;

/**
 * A container for all of the information we need to know about a series.
 * Some parameters are set as preferences and some are ordinary properties.
 * This class sets a common interface to the parameters, regardless of origin.
 */
@interface SeriesInfo : NSObject
{
    Logger* logger_;
}

@property BOOL overwriteFiles;
@property (strong) NSString* inputDir;
@property (strong) NSString* outputDir;
@property (strong) NSString* outputPath;
@property (strong) NSNumber* numberOfImages;
@property (strong) NSNumber* slicesPerImage;
@property (strong) NSNumber* numberOfSlices;
@property (strong) NSNumber* timeIncrement;
@property (strong) NSMutableArray* acqTimes;

@property (strong) NSString* patientsName;
@property (strong) NSNumber* patientsID;
@property (strong) NSDate* patientsDOB;
@property (strong) NSString* patientsSex;

@property (strong) NSString* studyDescription;
@property (strong) NSNumber* studyID;
@property (strong) NSString* studyModality;
@property (strong) NSDate* studyDateTime;
@property (strong) NSString* studyStudyUID;

@property (strong) NSNumber* seriesNumber;
@property (strong) NSString* seriesDescription;
@property (strong) NSString* seriesPatientPosition;

@property (strong) NSNumber* imageSliceSpacing;
@property (strong) NSNumber* imagePatientPositionX;
@property (strong) NSNumber* imagePatientPositionY;
@property (strong) NSNumber* imagePatientPositionZ;
@property (strong) NSString* imagePatientOrientation;

/**
 * Standard init
 * @return self
 */
- (id)init;

/**
 * Check for internal completeness and consistency.
 * Used for debugging.
 * return YES if consistent, NO otherwise.
 */
- (BOOL)isConsistent;

@end
