//
//  UserDefaults.h
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
