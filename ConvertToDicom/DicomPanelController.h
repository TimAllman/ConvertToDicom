//
//  DicomPanelController.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-30.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DicomInfo;

@interface DicomPanelController : NSWindowController <NSComboBoxDataSource>
{
    //enum ModalitiesEnum {CR, CT, DX, ES, MG, MR, NM, OT, PT, RF, SC, US, XA};

    NSArray* modalities;
}
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
@property (strong) IBOutlet DicomInfo *dicomInfo;

- (IBAction)imageSetIopAxialButtonPressed:(NSButton*)sender;
- (IBAction)imageSetIopSaggitalButtonPressed:(NSButton*)sender;
- (IBAction)imageSetIopCoronalButtonPressed:(NSButton*)sender;
- (IBAction)studySeriesUIDGenerateButtonPushed:(NSButton *)sender;
- (IBAction)studyDateNowButtonPressed:(NSButton *)sender;
- (IBAction)closeButtonPressed:(NSButton *)sender;

- (id)init;

@end
