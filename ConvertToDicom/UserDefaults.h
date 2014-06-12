//
//  UserDefaults.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-05-14.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import <Foundation/Foundation.h>

// Keys for preferences.
extern NSString* InputDirKey;
extern NSString* OutputDirKey;
extern NSString* TimeIncrementKey;

extern NSString* PatientsNameKey;
extern NSString* PatientsIDKey;
extern NSString* PatientsDOBKey;
extern NSString* PatientsSexKey;
extern NSString* StudyDescriptionKey;
extern NSString* StudyIDKey;
extern NSString* SeriesDescriptionKey;
extern NSString* SeriesNumberKey;
extern NSString* StudyModalityKey;
extern NSString* StudyDateTimeKey;
extern NSString* StudyStudyUIDKey;

@class SeriesInfo;

@interface UserDefaults : NSObject

+ (void)registerDefaults;

+ (void)loadDefaults:(SeriesInfo*)info;

+ (void)saveDefaults:(SeriesInfo*)info;

@end
