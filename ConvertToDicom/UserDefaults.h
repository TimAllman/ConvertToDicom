//
//  UserDefaults.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-05-14.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import <Foundation/Foundation.h>

// Keys for preferences.
extern NSString* LoggingLevelKey;
extern NSString* OverwriteFilesKey;
extern NSString* InputDirKey;
extern NSString* OutputDirKey;
extern NSString* TimeIncrementKey;

extern NSString* PatientsNameKey;
extern NSString* PatientsIDKey;
extern NSString* PatientsDOBKey;
extern NSString* PatientsSexKey;

extern NSString* StudyDescriptionKey;
extern NSString* StudyIDKey;
extern NSString* StudyModalityKey;
extern NSString* StudyDateTimeKey;
extern NSString* StudyStudyUIDKey;

extern NSString* SeriesDescriptionKey;
extern NSString* SeriesNumberKey;
extern NSString* SeriesPatientPositionKey;

@class SeriesInfo;

/**
 * Class to handle user defaults (preferences).
 */
@interface UserDefaults : NSObject

/**
 * Set up the factory defaults.
 */
+ (void)registerDefaults;

/**
 * Load defaults set on disk.
 * @param info SeriesInfo instance to receive the stored defaults.
 */
+ (void)loadDefaults:(SeriesInfo*)info;

/**
 * Store defaults to disk.
 * @param info SeriesInfo instance containing default values to store.
 */
+ (void)saveDefaults:(SeriesInfo*)info;

@end
