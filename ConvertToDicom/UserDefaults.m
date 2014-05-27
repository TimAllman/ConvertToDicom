//
//  UserDefaults.m
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-05-14.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import "UserDefaults.h"
#import "SeriesInfo.h"

// Keys for preferences.
NSString* InputDirKey = @"InputDir";
NSString* OutputDirKey = @"OutputDir";
NSString* SlicesPerImageKey = @"SlicesPerImage";
NSString* TimeIncrementKey = @"TimeIncrement";

NSString* PatientsNameKey = @"PatientsName";
NSString* PatientsIDKey = @"PatientsID";
NSString* PatientsDOBKey = @"PatientsDOB";
NSString* PatientsSexKey = @"PatientsSex";
NSString* StudyDescriptionKey = @"StudyDescription";
NSString* StudyIDKey = @"StudyID";
NSString* StudyModalityKey = @"StudyModality";
NSString* StudyDateTimeKey = @"StudyDateTime";
NSString* StudyStudyUIDKey = @"StudyStudyUID";
NSString* ImageSliceThicknessKey = @"ImageSliceThickness";
NSString* ImagePatientPositionXKey = @"ImagePatientPositionX";
NSString* ImagePatientPositionYKey = @"ImagePatientPositionY";
NSString* ImagePatientPositionZKey = @"ImagePatientPositionZ";
NSString* ImagePatientOrientationKey = @"ImagePatientOrientation";

@implementation UserDefaults

+ (void)registerDefaults
{
    NSDictionary* dict =
    [NSDictionary dictionaryWithObjectsAndKeys:
     NSHomeDirectory(), InputDirKey,
     NSHomeDirectory(), OutputDirKey,
     @1, SlicesPerImageKey,
     @1.0, TimeIncrementKey,
     @"", PatientsNameKey,
     @"", PatientsIDKey,
     [NSDate dateWithString:@"1918-10-19 10:45:32 +0500"], PatientsDOBKey,
     @"Unspecified", PatientsSexKey,
     @"", StudyDescriptionKey,
     @"", StudyIDKey,
     @"Unknown", StudyModalityKey,
     [NSDate date], StudyDateTimeKey,
     @"", StudyStudyUIDKey,
     @1.0, ImageSliceThicknessKey,
     @0.0, ImagePatientPositionXKey,
     @0.0, ImagePatientPositionYKey,
     @0.0, ImagePatientPositionZKey,
     @"1.0\\0.0\\0.0\\0.0\\1.0\\0.0", ImagePatientOrientationKey,
     nil];

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:dict];
}

+ (void)loadDefaults:(SeriesInfo*)info
{
    // Load preferences and do other initialisation
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];

    // Main window params
    info.inputDir = [defs stringForKey:InputDirKey];
    info.outputDir = [defs stringForKey:OutputDirKey];
    info.slicesPerImage = [defs objectForKey:SlicesPerImageKey];
    info.timeIncrement = [defs objectForKey:TimeIncrementKey];

    // Dicom info window params
    info.patientsName = [defs stringForKey:PatientsNameKey];
    info.patientsID = [defs stringForKey:PatientsIDKey];
    info.patientsDOB = [defs objectForKey:PatientsDOBKey];
    info.patientsSex = [defs stringForKey:PatientsSexKey];
    info.studyDescription = [defs stringForKey:StudyDescriptionKey];
    info.studyID = [defs stringForKey:StudyIDKey];
    info.studyModality = [defs stringForKey:StudyModalityKey];
    info.studyDateTime = [defs objectForKey:StudyDateTimeKey];
    info.studyStudyUID = [defs stringForKey:StudyStudyUIDKey];
    info.imageSliceThickness = [defs objectForKey:ImageSliceThicknessKey];
    info.imagePatientPositionX = [defs objectForKey:ImagePatientPositionXKey];
    info.imagePatientPositionY = [defs objectForKey:ImagePatientPositionYKey];
    info.imagePatientPositionZ = [defs objectForKey:ImagePatientPositionZKey];
    info.imagePatientOrientation = [defs stringForKey:ImagePatientOrientationKey];
}

+ (void)saveDefaults:(SeriesInfo *)info
{
    // Load preferences and do other initialisation
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];

    // Main window params
    [defs setObject:info.inputDir forKey:InputDirKey];
    [defs setObject:info.outputDir forKey:OutputDirKey];
    [defs setObject:info.slicesPerImage forKey:SlicesPerImageKey];
    [defs setObject:info.timeIncrement forKey:TimeIncrementKey];

    // Dicom info window params
    [defs setObject:info.patientsName forKey:PatientsNameKey];
    [defs setObject:info.patientsID forKey:PatientsIDKey];
    [defs setObject:info.patientsDOB forKey:PatientsDOBKey];
    [defs setObject:info.patientsSex forKey:PatientsSexKey];
    [defs setObject:info.studyDescription forKey:StudyDescriptionKey];
    [defs setObject:info.studyID forKey:StudyIDKey];
    [defs setObject:info.studyModality forKey:StudyModalityKey];
    [defs setObject:info.studyDateTime forKey:StudyDateTimeKey];
    [defs setObject:info.studyStudyUID forKey:StudyStudyUIDKey];
    [defs setObject:info.imageSliceThickness forKey:ImageSliceThicknessKey];
    [defs setObject:info.imagePatientPositionX forKey:ImagePatientPositionXKey];
    [defs setObject:info.imagePatientPositionY forKey:ImagePatientPositionYKey];
    [defs setObject:info.imagePatientPositionZ forKey:ImagePatientPositionZKey];
    [defs setObject:info.imagePatientOrientation forKey:ImagePatientOrientationKey];
}

@end
