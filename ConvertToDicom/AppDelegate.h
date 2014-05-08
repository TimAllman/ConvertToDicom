//
//  AppDelegate.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-24.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WindowController.h"

// Keys for preferences.
extern NSString* InputDirKey;
extern NSString* OutputDirKey;
extern NSString* SlicesPerImageKey;
extern NSString* TimeIncrementKey;

extern NSString* PatientsNameKey;
extern NSString* PatientsIDKey;
extern NSString* PatientsDOBKey;
extern NSString* PatientsSexKey;
extern NSString* StudyDescriptionKey;
extern NSString* StudyIDKey;
extern NSString* StudyModalityKey;
extern NSString* StudyDateTimeKey;
extern NSString* StudySeriesUIDKey;
extern NSString* ImageSliceThicknessKey;
extern NSString* ImagePatientPositionXKey;
extern NSString* ImagePatientPositionYKey;
extern NSString* ImagePatientPositionZKey;
extern NSString* ImagePatientOrientationKey;


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (strong) IBOutlet WindowController *windowController;

@end
