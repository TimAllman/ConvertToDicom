//
//  SeriesInfo.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-04-01.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

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
