//
//  AppDelegate.m
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-24.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import "AppDelegate.h"

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
NSString* StudySeriesUIDKey = @"StudySeriesUID";
NSString* ImageSliceThicknessKey = @"ImageSliceThickness";
NSString* ImagePatientPositionXKey = @"ImagePatientPositionX";
NSString* ImagePatientPositionYKey = @"ImagePatientPositionY";
NSString* ImagePatientPositionZKey = @"ImagePatientPositionZ";
NSString* ImagePatientOrientationKey = @"ImagePatientOrientation";

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self createFactoryDefaults];
    
}

- (void)createFactoryDefaults
{
    NSDictionary* dict =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [NSURL URLWithString:@""], InputDirKey,
         [NSURL URLWithString:@""], OutputDirKey,
         @1, SlicesPerImageKey,
         @1.0, TimeIncrementKey,
         @"", PatientsNameKey,
         @"", PatientsIDKey,
         [NSDate dateWithString:@"1918-10-19 10:45:32 +0500"], PatientsDOBKey,
         @"Unspecified", PatientsSexKey,
         @"", StudyDescriptionKey,
         @"", StudyIDKey,
         @"", StudyModalityKey,
         [NSDate date], StudyDateTimeKey,
         @"", StudySeriesUIDKey,
         @1.0, ImageSliceThicknessKey,
         @0.0, ImagePatientPositionXKey,
         @0.0, ImagePatientPositionYKey,
         @0.0, ImagePatientPositionZKey,
         @"1.0\\0.0\\0.0\\0.0\\1.0\\0.0", ImagePatientOrientationKey,
         nil];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:dict];
}

@end
