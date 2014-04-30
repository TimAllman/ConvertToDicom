//
//  DicomInfo.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-04-01.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import <Foundation/Foundation.h>

// Keys for preferences.
extern NSString* PatientsSexKey;
extern NSString* StudyDateTimeKey;
extern NSString* ImageSliceThicknessKey;

/*
 * Some parameters are set as preferences and some are ordinary properties.
 * This class sets a common interface to the parameters, regardless of origin.
 */
@interface DicomInfo : NSObject
{
//    NSString* patientsSex;
//    NSDate* studyDateTime;
}

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

+ (void)initialize;
- (id)init;

@end
