//
//  SeriesInfo.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-04-01.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * Some parameters are set as preferences and some are ordinary properties.
 * This class sets a common interface to the parameters, regardless of origin.
 */
@interface SeriesInfo : NSObject
{
}

@property (strong) IBOutlet NSString* inputDir;
@property (strong) IBOutlet NSString* outputDir;
@property (strong) IBOutlet NSString* outputPath;
@property (strong) IBOutlet NSNumber* numberOfImages;
@property (strong) IBOutlet NSNumber* slicesPerImage;
@property (strong) IBOutlet NSNumber* timeIncrement;
@property (strong) IBOutlet NSMutableArray* acqTimes;

@property (strong) IBOutlet NSString* patientsName;
@property (strong) IBOutlet NSNumber* patientsID;
@property (strong) IBOutlet NSDate* patientsDOB;
@property (strong) IBOutlet NSString* patientsSex;
@property (strong) IBOutlet NSString* studyDescription;
@property (strong) IBOutlet NSNumber* studyID;
@property (strong) IBOutlet NSString* studyModality;
@property (strong) IBOutlet NSDate* studyDateTime;
@property (strong) IBOutlet NSString* studyStudyUID;
@property (strong) IBOutlet NSNumber* seriesNumber;
@property (strong) IBOutlet NSString* seriesDescription;
@property (strong) IBOutlet NSNumber* imageSliceSpacing;
@property (strong) IBOutlet NSNumber* imagePatientPositionX;
@property (strong) IBOutlet NSNumber* imagePatientPositionY;
@property (strong) IBOutlet NSNumber* imagePatientPositionZ;
@property (strong) IBOutlet NSString* imagePatientOrientation;

- (id)init;
- (BOOL)isComplete;
- (BOOL)isConsistent;

@end
