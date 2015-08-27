//
//  WindowController.m
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-24.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import "WindowController.h"
#import "SeriesConverter.h"
#import "SeriesInfo.h"
#import "AppDelegate.h"
#import "UserDefaults.h"


#include <itkNrrdImageIOFactory.h>
#include <itkJPEGImageIOFactory.h>
#include <itkBioRadImageIOFactory.h>
#include <itkBMPImageIOFactory.h>
#include <itkGDCMImageIOFactory.h>
#include <itkGE4ImageIOFactory.h>
#include <itkGE5ImageIOFactory.h>
#include <itkGEAdwImageIOFactory.h>
#include <itkGiplImageIOFactory.h>
#include <itkHDF5ImageIOFactory.h>
#include <itkImageIOFactory.h>
#include <itkJPEGImageIOFactory.h>
#include <itkLSMImageIOFactory.h>
#include <itkMetaImageIOFactory.h>
#include <itkMRCImageIOFactory.h>
#include <itkNiftiImageIOFactory.h>
#include <itkNrrdImageIOFactory.h>
#include <itkPNGImageIOFactory.h>
#include <itkSiemensVisionImageIOFactory.h>
#include <itkStimulateImageIOFactory.h>
#include <itkTIFFImageIOFactory.h>
#include <itkVTKImageIOFactory.h>
#include <gdcmUIDGenerator.h>

#include "LoggerName.h"
#include "LoggerUtils.h"

#include <Log4m/Log4m.h>

@implementation WindowController

/**
 * Called before anything else and registers all of the ITK ImageIO factories.
 */
+(void)initialize
{
    itk::BioRadImageIOFactory::RegisterOneFactory();
    itk::BMPImageIOFactory::RegisterOneFactory();
    itk::GDCMImageIOFactory::RegisterOneFactory();
    itk::GE4ImageIOFactory::RegisterOneFactory();
    itk::GE5ImageIOFactory::RegisterOneFactory();
    itk::GEAdwImageIOFactory::RegisterOneFactory();
    itk::GiplImageIOFactory::RegisterOneFactory();
    itk::HDF5ImageIOFactory::RegisterOneFactory();
    itk::JPEGImageIOFactory::RegisterOneFactory();
    itk::LSMImageIOFactory::RegisterOneFactory();
    itk::MetaImageIOFactory::RegisterOneFactory();
    itk::MRCImageIOFactory::RegisterOneFactory();
    itk::NiftiImageIOFactory::RegisterOneFactory();
    itk::NrrdImageIOFactory::RegisterOneFactory();
    itk::PNGImageIOFactory::RegisterOneFactory();
    itk::SiemensVisionImageIOFactory::RegisterOneFactory();
    itk::StimulateImageIOFactory::RegisterOneFactory();
    itk::TIFFImageIOFactory::RegisterOneFactory();
    itk::VTKImageIOFactory::RegisterOneFactory();
    itk::GDCMImageIOFactory::RegisterOneFactory();

    SetupLogger(LOGGER_NAME, LOG4M_LEVEL_TRACE);
}

/**
 * Init method. Calls [super initWithWindowNibName:@"MainWindow"].
 */
- (id)init
{
    self = [super initWithWindowNibName:@"MainWindow"];
    if (self)
    {
        modalities = [NSArray arrayWithObjects:
                      @"CR", @"CT", @"DX", @"ES", @"MG", @"MR", @"NM",
                      @"OT", @"PT", @"RF", @"SC", @"US", @"XA", nil];
        sexes = [NSArray arrayWithObjects:@"Male", @"Female", @"Unspecified", nil];

        patientPositions = [NSArray arrayWithObjects: @"HFP", @"HFS", @"HFDR", @"HFDL", @"FFDR",
                            @"FFDL", @"FFP", @"FFS", nil];

        // We need to put some objects in the array to prevent initial display of
        // an empty combobox.
        sliceCounts = [NSMutableArray arrayWithObjects:@0, @1, @2, nil];

        NSString* loggerName = [[NSString stringWithUTF8String:LOGGER_NAME]
                                stringByAppendingString:@".WindowController"];
        logger_ = [Logger newInstance:loggerName];
        LOG4M_TRACE(logger_, @"Enter");
    }
    return self;
}

- (void)awakeFromNib
{
    seriesConverter = [[SeriesConverter alloc] initWithController:self andInfo:_seriesInfo];

    // Turn this off until the user sets things up.
    //[self.convertButton setEnabled:NO];
}

/**
 * Button to set input directory was pressed.
 * @param sender The button that was pressed.
 */
- (IBAction)inputDirButtonPressed:(NSButton *)sender
{
    NSOpenPanel* panel = [NSOpenPanel openPanel];

    panel.canChooseFiles = NO;
    panel.canChooseDirectories = YES;
    panel.canCreateDirectories = NO;
    panel.allowsMultipleSelection = NO;
    [panel setDirectoryURL:[NSURL fileURLWithPath:self.seriesInfo.inputDir]];

    [panel beginWithCompletionHandler:^(NSInteger result)
    {
        if (result == NSFileHandlingPanelOKButton)
        {
            NSURL* inputDir = [[panel URLs] objectAtIndex:0];
            self.seriesInfo.inputDir = [inputDir path];
            LOG4M_DEBUG(logger_, @"Input dir URL chosen: %@", inputDir);
        }
    }];
}

/**
 * Button to set output directory was pressed.
 * @param sender The button that was pressed.
 */
- (IBAction)outputDirButtonPressed:(NSButton *)sender
{
    NSOpenPanel* panel = [NSOpenPanel openPanel];

    panel.canChooseFiles = NO;
    panel.canChooseDirectories = YES;
    panel.canCreateDirectories = YES;
    panel.allowsMultipleSelection = NO;
    [panel setDirectoryURL:[NSURL fileURLWithPath:self.seriesInfo.outputDir]];

    [panel beginWithCompletionHandler:^(NSInteger result)
     {
         if (result == NSFileHandlingPanelOKButton)
         {
             NSURL* outputDir = [[panel URLs] objectAtIndex:0];
             self.seriesInfo.outputDir = [outputDir path];
             LOG4M_DEBUG(logger_, @"Output dir URL chosen: %@", outputDir);
         }
     }];
}

/**
 * Button to convert data was pressed.
 * @param sender The button that was pressed.
 */
- (IBAction)convertButtonPressed:(NSButton *)sender
{
    //[self.convertButton setEnabled:NO];

    NSError* error = nil;
    ErrorCode errCode = [self makeOutputDirectory:self.seriesInfo.outputDir Error:&error];

    // Cannot create the directory. Use the returned error to fill the alert.
    if (errCode == ERROR_CREATING_DIRECTORY)
    {
        NSAlert* alert = [NSAlert alertWithError:error];
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode){}];
        return;
    }

    // Do this so that the user will be aware that he is about to overwrite a data set
    if ((errCode == ERROR_DIRECTORY_NOT_EMPTY) && (self.seriesInfo.overwriteFiles == NO))
    {
        NSAlert* alert = [[NSAlert alloc] init];
        alert.alertStyle = NSWarningAlertStyle;
        alert.messageText = @"Output directory is not empty.";
        alert.informativeText = @"Check the \'Overwrite files\' box to overwrite the"
                                 " contents of the output directory.";
        [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
        LOG4M_WARN(logger_, @"Output directory not empty. Check the \'Overwrite files\' box if you"
                             " wish to overwrite the contents of the output directory.");
        return;
    }

    errCode = [self convertFiles];
    
    if (errCode == SUCCESS)
    {
        NSAlert* alert = [NSAlert alertWithMessageText:@"Converted files successfully."
                                         defaultButton:@"Close" alternateButton:nil otherButton:nil
                             informativeTextWithFormat:@""];
        [alert setAlertStyle:NSInformationalAlertStyle];

        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode)
         {
         }];

        LOG4M_INFO(logger_, @"Converted files successfully.");
        return;
    }
    else if (errCode == ERROR_FILE_NOT_FOUND)
    {
        NSAlert* alert = [NSAlert alertWithMessageText:@"Could not read files."
                                         defaultButton:@"Close" alternateButton:nil otherButton:nil
                             informativeTextWithFormat:@"Directory: %@", seriesConverter.inputDir];
        [alert setAlertStyle:NSCriticalAlertStyle];

        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode)
         {
         }];

        LOG4M_ERROR(logger_, @"Could not read files from %@:", seriesConverter.inputDir);
        return;
    }
    else if (errCode == ERROR_WRITING_FILE)
    {
        NSAlert* alert = [NSAlert alertWithMessageText:@"Could not write files."
                                         defaultButton:@"Close" alternateButton:nil otherButton:nil
                             informativeTextWithFormat:@"Directory: %@", seriesConverter.outputDir];
        [alert setAlertStyle:NSCriticalAlertStyle];

        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode)
         {
         }];

        LOG4M_ERROR(logger_, @"Could not write files to %@:", seriesConverter.outputDir);
        return;
    }
    else
    {
        
    }

}

/**
 * Button to close program.
 * @param sender The button that was pressed.
 */
- (IBAction)closeButtonPressed:(NSButton *)sender
{
    [UserDefaults saveDefaults:self.seriesInfo];
    [self close];

    LOG4M_DEBUG(logger_, @"Terminating.");

    [NSApp terminate:nil];
}

/**
 * Button to read input files and set up DICOM attributes was pressed.
 * Allows the user to set information that is probably not in the input files.
 * @param sender The button that was pressed.
 */
- (IBAction)setDicomTagsButtonPushed:(NSButton *)sender
{
    seriesConverter.inputDir = [NSURL fileURLWithPath:self.seriesInfo.inputDir isDirectory:YES];
    seriesConverter.seriesInfo = self.seriesInfo;

    if ([seriesConverter extractSeriesAttributes] != SUCCESS)
    {
        NSAlert* alert = [NSAlert alertWithMessageText:@"Could not read image file in input directory."
                                         defaultButton:@"Close" alternateButton:nil otherButton:nil
                             informativeTextWithFormat:@"%@ does not contain readable image files.",
                                                         self.seriesInfo.inputDir];

        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode)
         {
         }];

        LOG4M_ERROR(logger_, @"Could not read image file in input directory. "
                    "%@ does not contain readable image files.", self.seriesInfo.inputDir);
        return;
    }

    [sliceCounts removeAllObjects];
    NSUInteger sliceCount = [self.seriesInfo.numberOfSlices unsignedIntValue];
    for (NSUInteger idx = 1; idx <= sliceCount; ++idx)
    {
        if ((sliceCount % idx) == 0)
            [sliceCounts addObject:[NSNumber numberWithUnsignedInteger:idx]];
    }
    
    NSInteger idx = [sliceCounts indexOfObject:self.seriesInfo.slicesPerImage];
    [self.slicesPerImageComboBox selectItemAtIndex:idx];
    [self.slicesPerImageComboBox setObjectValue:[self comboBox:self.slicesPerImageComboBox
                                     objectValueForItemAtIndex:[self.slicesPerImageComboBox indexOfSelectedItem]]];

    // All seems well so we can put up the DICOM Attributes sheet.
    [NSApp beginSheet:self.dicomInfoPanel modalForWindow:self.window modalDelegate:self
       didEndSelector:@selector(didEndDicomAttributesSheet:returnCode:contextInfo:)
          contextInfo:nil];
}

/**
 * See if the output directory can be created by trying to do so.
 * @return ErrorCode SUCCESS if successful, ERROR_CREATING_DIRECTORY if not.
 */
- (ErrorCode)checkOutputDirCreatability
{
    NSFileManager* fm = [NSFileManager defaultManager];
    NSError* err;
    if ([fm createDirectoryAtPath:self.seriesInfo.outputDir withIntermediateDirectories:YES
                   attributes:nil error:&err] == NO)
    {
        NSAlert* alert = [NSAlert alertWithError:err];
        [alert beginSheetModalForWindow:self.window
                      completionHandler:^(NSModalResponse returnCode) {
        }];
        return ERROR_CREATING_DIRECTORY;
    }
    else
    {
        //[fm removeItemAtPath:self.seriesInfo.outputDir error:nil];
        return SUCCESS;
    }
}

/**
 * Called when Dicom attributes sheet is closed, checking for errors
 * @param sheet The sheet that closed
 * @param returnCode The sheet return code.
 * @param contextInfo Not used.
 */
- (void)didEndDicomAttributesSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    LOG4M_TRACE(logger_, @"didEndDicomAttributesSheet:returnCode:contextInfo:");

    if (returnCode == NSOKButton)
    {
        if ([seriesConverter loadFileNames] == 0)
        {
            NSAlert* alert = [[NSAlert alloc] init];
            [alert setAlertStyle:NSCriticalAlertStyle];
            [alert setMessageText:[@"No image files found in directory "
                                   stringByAppendingString:self.seriesInfo.inputDir]];
            [alert setInformativeText:@"Set the input directory to one containing image files."];
            [alert beginSheetModalForWindow:self.window
                              modalDelegate:self
                             didEndSelector:nil
                                contextInfo:nil];

            LOG4M_ERROR(logger_, @"No image files found in directory %@", self.seriesInfo.inputDir);
            return;
        }
        else
        {
            //[self.convertButton setEnabled:YES];
        }
    }
}

/**
 * Do the file reading, conversion and writing.
 * @return ErrorCode SUCCESS if successful.
 */
- (ErrorCode)convertFiles
{
    ErrorCode err = [seriesConverter convertFiles];

    return err;
}

#pragma mark - DicomPanel

/**
 * Set Image Orientation Patient to axial.
 * @param sender The button that was pressed.
 */
- (IBAction)imageSetIopAxialButtonPressed:(NSButton*)sender
{
    NSLog(@"imageSetIopAxialButtonPressed");
    self.seriesInfo.imagePatientOrientation = @"1\\0\\0\\0\\1\\0";
}

/**
 * Set Image Orientation Patient to saggital.
 * @param sender The button that was pressed.
 */
- (IBAction)imageSetIopSaggitalButtonPressed:(NSButton *)sender
{
    NSLog(@"imageSetIopSaggitalButtonPressed");
    self.seriesInfo.imagePatientOrientation = @"0\\1\\0\\0\\0\\1";
}

/**
 * Set Image Orientation Patient to coronal.
 * @param sender The button that was pressed.
 */
- (IBAction)imageSetIopCoronalButtonPressed:(NSButton*)sender
{
    NSLog(@"imageSetIopCoronalButtonPressed");
    self.seriesInfo.imagePatientOrientation = @"1\\0\\0\\0\\0\\1";
}

/**
 * Generate a study UID.
 * @param sender The button that was pressed.
 */
- (IBAction)studyStudyUIDGenerateButtonPushed:(NSButton*)sender
{
    gdcm::UIDGenerator suid;
    std::string studyUID = suid.Generate();
    self.seriesInfo.studyStudyUID = [NSString stringWithUTF8String:studyUID.c_str()];

    NSLog(@"studyStudyUIDGenerateButtonPressed: %@", self.seriesInfo.studyStudyUID);
}

/**
 * Set the date to now.
 * @param sender The button that was pressed.
 */
- (IBAction)studyDateNowButtonPressed:(NSButton *)sender
{
    self.seriesInfo.studyDateTime = [NSDate date];
}

/**
 * Dicom attributes sheet button was pressed.
 * Checks for completeness and consistency and saves defaults.
 * @param sender The button that was pressed.
 */
- (IBAction)dicomCloseButtonPressed:(NSButton *)sender
{
    LOG4M_TRACE(logger_, @"dicomCloseButtonPressed");

    [NSApp endSheet:self.dicomInfoPanel];
    [self.dicomInfoPanel orderOut:self];

    if (![self.seriesInfo isConsistent])
    {
        // check input data
        unsigned numImages = [self.seriesInfo.numberOfImages unsignedIntValue];
        unsigned numSlices = [self.seriesInfo.numberOfSlices unsignedIntValue];

        NSAlert* alert = [[NSAlert alloc] init];
        alert.alertStyle = NSCriticalAlertStyle;
        alert.messageText = @"Images are inconsistent.";
        NSString* infoText = [NSString stringWithFormat:@"The number of slices (%u) must divide exactly"
                              " by the number of images (%u) in the input series.", numSlices, numImages];
        alert.informativeText = infoText;
        [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
        LOG4M_WARN(logger_, infoText);
        return;
    }

    [UserDefaults saveDefaults:self.seriesInfo];
}

#pragma mark - NSComboBoxDatasource

- (id)comboBox:(NSComboBox*)comboBox objectValueForItemAtIndex:(NSInteger)index
{
    NSString* ident = comboBox.identifier;

    if ([ident isEqualToString:@"PatientsSexComboBox"])
    {
        return [sexes objectAtIndex:index];
    }
    else if ([ident isEqualToString:@"StudyModalityComboBox"])
    {
        return [modalities objectAtIndex:index];
    }
    else if ([ident isEqualToString:@"SlicesPerImageComboBox"])
    {
        return [sliceCounts objectAtIndex:index];
    }
    else if ([ident isEqualToString:@"PatientPositionComboBox"])
    {
        return [patientPositions objectAtIndex:index];
    }
    else
    {
        NSException* ex =
           [NSException exceptionWithName:@"InvalidIdentifier"
                            reason:[NSString stringWithFormat:@"Combobox identifier %@ is invalid.", ident]
                                 userInfo:nil];
        @throw ex;
    }
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox*)comboBox
{
    NSString* ident = comboBox.identifier;

    if ([ident isEqualToString:@"PatientsSexComboBox"])
    {
        return [sexes count];
    }
    else if ([ident isEqualToString:@"StudyModalityComboBox"])
    {
        return [modalities count];
    }
    else if ([ident isEqualToString:@"SlicesPerImageComboBox"])
    {
        return [sliceCounts count];
    }
    else if ([ident isEqualToString:@"PatientPositionComboBox"])
    {
        return [patientPositions count];
    }
    else
    {
        NSException* ex =
        [NSException exceptionWithName:@"InvalidIdentifier"
                                reason:[NSString stringWithFormat:@"Combobox identifier %@ is invalid.", ident]
                              userInfo:nil];
        @throw ex;
    }
}

#pragma mark - ComboboxDelegate

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    NSComboBox* cb = notification.object;

    if ([cb.identifier isEqualToString:@"SlicesPerImageComboBox"])
    {
        NSInteger idx = [cb indexOfSelectedItem];
        self.seriesInfo.slicesPerImage = [sliceCounts objectAtIndex:idx];
        self.seriesInfo.numberOfImages = [NSNumber numberWithUnsignedInt:
                                          [self.seriesInfo.numberOfSlices unsignedIntValue] /
                                          [self.seriesInfo.slicesPerImage unsignedIntValue]];
    }

    return;
}

#pragma mark - Utilities
/**
 * Make the full output directory name.
 * The files exist at the bottom of a tree that looks like this:
 * dirName/PatientName/StudyDescription - StudyID/SeriesDescription - SeriesNumber/
 */
- (void)makeOutputDirectoryName:(NSString*)dirName
{
    NSString* fullName = [NSString stringWithFormat:@"%@/%@/%@ - %@/%@ - %@/",
                          dirName, self.seriesInfo.patientsName,
                          self.seriesInfo.studyDescription, self.seriesInfo.studyID,
                          self.seriesInfo.seriesDescription, self.seriesInfo.seriesNumber];

    self.seriesInfo.outputPath = fullName;

    LOG4M_INFO(logger_, @"Output path set to: %@", self.seriesInfo.outputPath);
}

/**
 * Make the full output directory.
 * @param dirName The root directory name that will be expanded by makeOutputDirectoryName:
 * @return ErrorCode SUCCESS if successful, ERROR_CREATING_DIRECTORY or ERROR_DIRECTORY_NOT_EMPTY if not.
 */
- (ErrorCode)makeOutputDirectory:(NSString*)dirName Error:(NSError**)errp
{
    NSError* error = *errp;

    [self makeOutputDirectoryName:self.seriesInfo.outputDir];

    NSFileManager* fm = [NSFileManager defaultManager];

    BOOL b = [fm createDirectoryAtPath:self.seriesInfo.outputPath withIntermediateDirectories:YES
                                attributes:nil error:&error];
    if (b == NO)
    {
        return ERROR_CREATING_DIRECTORY;
    }
    else
    {
        // We want an empty directory, maybe
        NSArray* contents = [fm contentsOfDirectoryAtPath:self.seriesInfo.outputPath error:&error];
        if ([contents count] != 0)
            return ERROR_DIRECTORY_NOT_EMPTY;
        else
            return SUCCESS;
    }
}

@end
