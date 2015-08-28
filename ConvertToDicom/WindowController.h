//
//  WindowController.h
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

#import <Cocoa/Cocoa.h>

#include "ErrorCodes.h"

#import <Log4m/Logger.h>

@class SeriesInfo;
@class SeriesConverter;

/**
 * The main class for the program. Handles all GUI events and calling the image conversion functions.
 */
@interface WindowController : NSWindowController <NSComboBoxDataSource, NSComboBoxDelegate,
                                                  NSFileManagerDelegate, NSTextFieldDelegate>
{
    NSArray* modalities;              ///< List of DICOM abbreviations of possible modalities.
    NSArray* sexes;                   ///< List of sexes.
    NSArray* patientPositions;        ///< List of patient positions.
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
@property (weak) IBOutlet NSComboBox *seriesPatientPositionComboBox;

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

- (ErrorCode)makeOutputDirectory:(NSString*)dirName Error:(NSError**)errp;

@end
