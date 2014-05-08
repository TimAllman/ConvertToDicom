//
//  WindowController.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-24.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import <Cocoa/Cocoa.h>

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

@class DicomInfo;

@interface WindowController : NSWindowController <NSComboBoxDataSource, NSComboBoxDelegate>
{
    NSArray* modalities;
}

- (id)initWithWindow:(NSWindow *)window;

@property (strong) NSString* inputDir;
@property (strong) NSString* outputDir;
@property (assign) unsigned slicesPerImage;
@property (assign) float timeIncrement;

@property (weak) IBOutlet DicomInfo *dicomInfo;

// Main panel controls
@property (weak) IBOutlet NSTextField *inputDirTextField;
@property (weak) IBOutlet NSTextField *outputDirTextField;
@property (weak) IBOutlet NSTextField *slicesPerImageTextField;
@property (weak) IBOutlet NSTextField *timeIncrementTextField;

// Dicom panel
@property (strong) IBOutlet NSPanel *dicomInfoPanel;

// Dicom panel controls
@property (weak) IBOutlet NSTextField *patientsNameTextField;
@property (weak) IBOutlet NSTextField *patientsIDTextField;
@property (weak) IBOutlet NSDatePicker *patientsDOBDatePicker;
@property (weak) IBOutlet NSComboBox *patientsSexComboBox;
@property (weak) IBOutlet NSTextField *studyDescriptionTextField;
@property (weak) IBOutlet NSTextField *studyIDTextField;
@property (weak) IBOutlet NSComboBox *studyModalityComboBox;
@property (weak) IBOutlet NSDatePicker *studyDateTimeDatePicker;
@property (weak) IBOutlet NSTextField *studySeriesUIDTextField;
@property (weak) IBOutlet NSTextField *imageSliceThicknessTextField;
@property (weak) IBOutlet NSTextField *imagePatientPositionXTextField;
@property (weak) IBOutlet NSTextField *imagePatientPositionYTextField;
@property (weak) IBOutlet NSTextField *imagePatientPositionZTextField;
@property (weak) IBOutlet NSTextField *imagePatientOrientationTextField;

- (IBAction)inputDirButtonPressed:(NSButton *)sender;
- (IBAction)outputDirButtonPressed:(NSButton *)sender;
- (IBAction)convertButtonPressed:(NSButton *)sender;
- (IBAction)closeButtonPressed:(NSButton *)sender;
- (IBAction)setDicomTagsButtonPushed:(NSButton *)sender;

- (IBAction)imageSetIopAxialButtonPressed:(NSButton*)sender;
- (IBAction)imageSetIopSaggitalButtonPressed:(NSButton*)sender;
- (IBAction)imageSetIopCoronalButtonPressed:(NSButton*)sender;
- (IBAction)studySeriesUIDGenerateButtonPushed:(NSButton *)sender;
- (IBAction)studyDateNowButtonPressed:(NSButton *)sender;
- (IBAction)dicomCloseButtonPressed:(NSButton *)sender;

@end
