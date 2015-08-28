//
//  UserDefaults.m
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

#import "UserDefaults.h"
#import "SeriesInfo.h"
#import "LoggerName.h"

#import <Log4m/Log4m.h>

// Keys for preferences.
NSString* LoggingLevelKey = @"LoggingLevel";
NSString* OverwriteFilesKey = @"OverwriteFiles";
NSString* InputDirKey = @"InputDir";
NSString* OutputDirKey = @"OutputDir";
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

NSString* SeriesDescriptionKey = @"SeriesDescription";
NSString* SeriesNumberKey = @"SeriesNumber";
NSString* SeriesPatientPositionKey = @"SeriesPatientPosition";


@implementation UserDefaults

+ (void)initialize
{
    NSString* loggerName = [[NSString stringWithUTF8String:LOGGER_NAME]
                            stringByAppendingString:@".UserDefaults"];
    Logger* logger_ = [Logger newInstance:loggerName];
    LOG4M_TRACE(logger_, @"Enter");
}

+ (void)registerDefaults
{
    NSString* loggerName = [[NSString stringWithUTF8String:LOGGER_NAME]
                            stringByAppendingString:@".UserDefaults"];
    Logger* logger_ = [Logger newInstance:loggerName];
    LOG4M_TRACE(logger_, @"Enter");

    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:LOG4M_LEVEL_INFO], LoggingLevelKey,
                          @NO, OverwriteFilesKey,
                          NSHomeDirectory(), InputDirKey,
                          NSHomeDirectory(), OutputDirKey,
                          @1.0, TimeIncrementKey,
                          @"", PatientsNameKey,
                          @0, PatientsIDKey,
                          [NSDate dateWithString:@"1918-10-19 10:45:32 +0500"], PatientsDOBKey,
                          @"Unspecified", PatientsSexKey,
                          @"", StudyDescriptionKey,
                          @"", SeriesDescriptionKey,
                          @0, SeriesNumberKey,
                          @"FFS", SeriesPatientPositionKey,
                          @0, StudyIDKey,
                          @"Unknown", StudyModalityKey,
                          [NSDate date], StudyDateTimeKey,
                          @"", StudyStudyUIDKey,
                          nil];

    LOG4M_DEBUG(logger_, @"Registered defaults:\n%@", dict);

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:dict];
}

+ (void)loadDefaults:(SeriesInfo*)info
{
    NSString* loggerName = [[NSString stringWithUTF8String:LOGGER_NAME]
                            stringByAppendingString:@".UserDefaults"];
    Logger* logger_ = [Logger newInstance:loggerName];
    LOG4M_TRACE(logger_, @"Enter");

    // Load preferences and do other initialisation
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];

    // Main window params
    info.overwriteFiles = [defs boolForKey:OverwriteFilesKey];
    info.inputDir = [defs stringForKey:InputDirKey];
    info.outputDir = [defs stringForKey:OutputDirKey];
    info.timeIncrement = [defs objectForKey:TimeIncrementKey];

    // Dicom info window params
    info.patientsName = [defs stringForKey:PatientsNameKey];
    info.patientsID = [defs objectForKey:PatientsIDKey];
    info.patientsDOB = [defs objectForKey:PatientsDOBKey];
    info.patientsSex = [defs stringForKey:PatientsSexKey];
    info.studyDescription = [defs stringForKey:StudyDescriptionKey];
    info.studyID = [defs objectForKey:StudyIDKey];
    info.seriesDescription = [defs stringForKey:SeriesDescriptionKey];
    info.seriesNumber = [defs objectForKey:SeriesNumberKey];
    info.seriesPatientPosition = [defs objectForKey:SeriesPatientPositionKey];
    info.studyModality = [defs stringForKey:StudyModalityKey];
    info.studyDateTime = [defs objectForKey:StudyDateTimeKey];
    info.studyStudyUID = [defs stringForKey:StudyStudyUIDKey];

    LOG4M_DEBUG(logger_, @"Loaded defaults:\n%@", defs);
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
    [defs setObject:info.seriesPatientPosition forKey:SeriesPatientPositionKey];
    [defs setObject:info.studyModality forKey:StudyModalityKey];
    [defs setObject:info.studyDateTime forKey:StudyDateTimeKey];
    [defs setObject:info.studyStudyUID forKey:StudyStudyUIDKey];
}

@end
