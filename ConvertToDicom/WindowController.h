//
//  WindowController.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-24.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include "ErrorCodes.h"

#import <Log4m/Logger.h>

@class SeriesInfo;
@class SeriesConverter;

/**
 * The main class for the program. Handles all GUI events and calling the image conversion functions.
 */
@interface WindowController : NSWindowController <NSComboBoxDataSource, NSFileManagerDelegate,
                                                  NSTextFieldDelegate>
{
    NSArray* modalities;              ///< List of DICOM abbreviations of possible modalities.
    NSArray* sexes;                   ///< List of sexes.
    NSMutableArray* sliceCounts;      ///< List of possible numbers of slices per image
    SeriesConverter* seriesConverter; ///< Object which handles conversion.
    Logger* logger_;                  ///< The class Log4m logger.
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
@property (weak) IBOutlet NSComboBox *slicesPerImageComboBox;
@property (weak) IBOutlet NSTextField *timeIncrementTextField;
@property (weak) IBOutlet NSTextField *imageSliceThicknessTextField;
@property (weak) IBOutlet NSTextField *imagePatientPositionXTextField;
@property (weak) IBOutlet NSTextField *imagePatientPositionYTextField;
@property (weak) IBOutlet NSTextField *imagePatientPositionZTextField;
@property (weak) IBOutlet NSTextField *imagePatientOrientationTextField;

@property (weak) IBOutlet NSButton *convertButton;
@property (weak) IBOutlet NSButton *closeButton;
@property (weak) IBOutlet NSButton *dicomPanelCloseButton;

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
//- (void)makeOutputDirectoryName:(NSString*)dirName;
- (ErrorCode)makeOutputDirectory:(NSString*)dirName Error:(NSError**)errp;

@end
