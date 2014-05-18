//
//  DicomInfo.h
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
@interface DicomInfo : NSObject
{
}

@property (strong) IBOutlet NSString* inputDir;
@property (strong) IBOutlet NSString* outputDir;
@property (assign) IBOutlet NSNumber* slicesPerImage;
@property (assign) IBOutlet NSNumber* timeIncrement;

@property (strong) IBOutlet NSString* patientsName;
@property (strong) IBOutlet NSString* patientsID;
@property (strong) IBOutlet NSDate* patientsDOB;
@property (strong) IBOutlet NSString* patientsSex;
@property (strong) IBOutlet NSString* studyDescription;
@property (strong) IBOutlet NSString* studyID;
@property (strong) IBOutlet NSString* studyModality;
@property (strong) IBOutlet NSDate* studyDateTime;
@property (strong) IBOutlet NSString* studySeriesUID;
@property (strong) IBOutlet NSNumber* imageSliceThickness;
@property (strong) IBOutlet NSNumber* imagePatientPositionX;
@property (strong) IBOutlet NSNumber* imagePatientPositionY;
@property (strong) IBOutlet NSNumber* imagePatientPositionZ;
@property (strong) IBOutlet NSString* imagePatientOrientation;

- (id)init;

@end
