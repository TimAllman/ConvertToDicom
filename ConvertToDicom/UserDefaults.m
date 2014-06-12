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
NSString* TimeIncrementKey = @"TimeIncrement";

NSString* PatientsNameKey = @"PatientsName";
NSString* PatientsIDKey = @"PatientsID";
NSString* PatientsDOBKey = @"PatientsDOB";
NSString* PatientsSexKey = @"PatientsSex";
NSString* StudyDescriptionKey = @"StudyDescription";
NSString* SeriesDescriptionKey = @"SeriesDescription";
NSString* SeriesNumberKey = @"SeriesNumber";
NSString* StudyIDKey = @"StudyID";
NSString* StudyModalityKey = @"StudyModality";
NSString* StudyDateTimeKey = @"StudyDateTime";
NSString* StudyStudyUIDKey = @"StudyStudyUID";

@implementation UserDefaults

+ (void)registerDefaults
{
    NSDictionary* dict =
    [NSDictionary dictionaryWithObjectsAndKeys:
     NSHomeDirectory(), InputDirKey,
     NSHomeDirectory(), OutputDirKey,
     @1.0, TimeIncrementKey,
     @"", PatientsNameKey,
     @"", PatientsIDKey,
     [NSDate dateWithString:@"1918-10-19 10:45:32 +0500"], PatientsDOBKey,
     @"Unspecified", PatientsSexKey,
     @"", StudyDescriptionKey,
     @"", SeriesDescriptionKey,
     @"", SeriesNumberKey,
     @"", StudyIDKey,
     @"Unknown", StudyModalityKey,
     [NSDate date], StudyDateTimeKey,
     @"", StudyStudyUIDKey,
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
    info.timeIncrement = [defs objectForKey:TimeIncrementKey];

    // Dicom info window params
    info.patientsName = [defs stringForKey:PatientsNameKey];
    info.patientsID = [defs stringForKey:PatientsIDKey];
    info.patientsDOB = [defs objectForKey:PatientsDOBKey];
    info.patientsSex = [defs stringForKey:PatientsSexKey];
    info.studyDescription = [defs stringForKey:StudyDescriptionKey];
    info.studyID = [defs stringForKey:StudyIDKey];
    info.seriesDescription = [defs stringForKey:SeriesDescriptionKey];
    info.seriesNumber = [defs stringForKey:SeriesNumberKey];
    info.studyModality = [defs stringForKey:StudyModalityKey];
    info.studyDateTime = [defs objectForKey:StudyDateTimeKey];
    info.studyStudyUID = [defs stringForKey:StudyStudyUIDKey];
}

+ (void)saveDefaults:(SeriesInfo *)info
{
    // Load preferences and do other initialisation
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];

    // Main window params
    [defs setObject:info.inputDir forKey:InputDirKey];
    [defs setObject:info.outputDir forKey:OutputDirKey];
    [defs setObject:info.timeIncrement forKey:TimeIncrementKey];

    // Dicom info window params
    [defs setObject:info.patientsName forKey:PatientsNameKey];
    [defs setObject:info.patientsID forKey:PatientsIDKey];
    [defs setObject:info.patientsDOB forKey:PatientsDOBKey];
    [defs setObject:info.patientsSex forKey:PatientsSexKey];
    [defs setObject:info.studyDescription forKey:StudyDescriptionKey];
    [defs setObject:info.studyID forKey:StudyIDKey];
    [defs setObject:info.seriesDescription forKey:SeriesDescriptionKey];
    [defs setObject:info.seriesNumber forKey:SeriesNumberKey];
    [defs setObject:info.studyModality forKey:StudyModalityKey];
    [defs setObject:info.studyDateTime forKey:StudyDateTimeKey];
    [defs setObject:info.studyStudyUID forKey:StudyStudyUIDKey];
}

@end
