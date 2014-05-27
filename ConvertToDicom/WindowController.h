//
//  WindowController.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-24.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SeriesInfo;
@class SeriesConverter;

@interface WindowController : NSWindowController <NSComboBoxDataSource>
{
    NSArray* modalities;
    NSArray* sexes;
    SeriesConverter* seriesConverter;
}

@property (weak) IBOutlet SeriesInfo *seriesInfo;

// Main panel controls
@property (weak) IBOutlet NSTextField *inputDirTextField;
@property (weak) IBOutlet NSTextField *outputDirTextField;

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
@property (weak) IBOutlet NSTextField *studyStudyUIDTextField;
@property (weak) IBOutlet NSTextField *slicesPerImageTextField;
@property (weak) IBOutlet NSTextField *timeIncrementTextField;
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
- (IBAction)studyStudyUIDGenerateButtonPushed:(NSButton *)sender;
- (IBAction)studyDateNowButtonPressed:(NSButton *)sender;
- (IBAction)dicomCloseButtonPressed:(NSButton *)sender;

- (id)init;

@end
