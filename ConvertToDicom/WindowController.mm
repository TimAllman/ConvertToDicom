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

@implementation WindowController

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
}

- (id)init
{
    self = [super initWithWindowNibName:@"MainWindow"];
    if (self)
    {
        modalities = [NSArray arrayWithObjects:
                      @"CR", @"CT", @"DX", @"ES", @"MG", @"MR", @"NM",
                      @"OT", @"PT", @"RF", @"SC", @"US", @"XA", nil];
        sexes = [NSArray arrayWithObjects:@"Male", @"Female", @"Unspecified", nil];
        seriesConverter = [[SeriesConverter alloc] init];
    }
    return self;
}

- (void)awakeFromNib
{
    [self.convertButton setEnabled:NO];
}

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
            NSLog(@"Input dir URL chosen: %@", inputDir);
        }
    }];
}

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
             NSLog(@"Output dir URL chosen: %@", outputDir);
         }
     }];
}

- (IBAction)convertButtonPressed:(NSButton *)sender
{
    [self.convertButton setEnabled:NO];
    
    [self convertFiles];
}

- (IBAction)closeButtonPressed:(NSButton *)sender
{
    [UserDefaults saveDefaults:self.seriesInfo];
    [self close];
    [NSApp terminate:nil];
}

- (IBAction)setDicomTagsButtonPushed:(NSButton *)sender
{
    //seriesConverter.inputDir = [NSURL URLWithString:self.seriesInfo.inputDir];
    seriesConverter.inputDir = [NSURL fileURLWithPath:self.seriesInfo.inputDir isDirectory:YES];
    seriesConverter.seriesInfo = self.seriesInfo;
    seriesConverter.parentWindow = self.window;

    if ([seriesConverter extractSeriesDicomAttributes] == NO)
    {
        NSAlert* alert = [NSAlert alertWithMessageText:@"Could not read image file in input directory."
                                         defaultButton:@"Close" alternateButton:nil otherButton:nil
                             informativeTextWithFormat:@"%@ does not contain readable image files.", self.seriesInfo.inputDir];

        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        }];

    }
    else if ([self checkOutputDirExistence] == NO)
    {
        return; // makeOutputDirectory contains alerts, no need here.
    }
    else
    {
        [NSApp beginSheet:self.dicomInfoPanel modalForWindow:self.window modalDelegate:self
           didEndSelector:@selector(didEndDicomAttributesSheet:returnCode:contextInfo:) contextInfo:nil];
    }
}

- (BOOL)checkOutputDirExistence
{
    NSFileManager* fm = [NSFileManager defaultManager];
    NSError* err;
    if ([fm createDirectoryAtPath:self.seriesInfo.outputDir withIntermediateDirectories:YES
                   attributes:nil error:&err] == NO)
    {
        NSAlert* alert = [NSAlert alertWithError:err];
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        }];
        return NO;
    }
    else
        return YES;
}

- (void)didEndDicomAttributesSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    NSLog(@"didEndDicomAttributesSheet:returnCode:contextInfo:");

    if (returnCode == NSOKButton)
    {
        if ([seriesConverter loadFileNames] == 0)
        {
            NSAlert* alert = [[NSAlert alloc] init];
            [alert setAlertStyle:NSCriticalAlertStyle];
            [alert setMessageText:[@"Image file not found in directory "
                                   stringByAppendingString:self.seriesInfo.inputDir]];
            [alert setInformativeText:@"Set the input directory to one containing image files."];
            [alert beginSheetModalForWindow:self.window
                              modalDelegate:self
                             didEndSelector:@selector(didEndAlertSheet:returnCode:contextInfo:)
                                contextInfo:nil];

            return;
        }
        else
        {
            [self.convertButton setEnabled:YES];
        }
    }
}

- (void)didEndAlertSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    NSLog(@"didEndAlertSheet:returnCode:contextInfo:");
}

- (void)convertFiles
{
    seriesConverter.inputDir = [NSURL fileURLWithPath:self.seriesInfo.inputDir isDirectory:YES];
    seriesConverter.outputDir = [NSURL fileURLWithPath:self.seriesInfo.outputDir isDirectory:YES];
    seriesConverter.seriesInfo = self.seriesInfo;
    seriesConverter.parentWindow = self.window;

    [seriesConverter loadFileNames];
    [seriesConverter readFiles];
    [seriesConverter writeFiles];
}

#pragma mark - DicomPanel

- (IBAction)imageSetIopAxialButtonPressed:(NSButton*)sender
{
    NSLog(@"imageSetIopAxialButtonPressed");
    self.seriesInfo.imagePatientOrientation = @"1\\0\\0\\0\\1\\0";
}

- (IBAction)imageSetIopSaggitalButtonPressed:(NSButton *)sender
{
    NSLog(@"imageSetIopSaggitalButtonPressed");
    self.seriesInfo.imagePatientOrientation = @"0\\1\\0\\0\\0\\1";
}

- (IBAction)imageSetIopCoronalButtonPressed:(NSButton*)sender
{
    NSLog(@"imageSetIopCoronalButtonPressed");
    self.seriesInfo.imagePatientOrientation = @"1\\0\\0\\0\\0\\1";
}

- (IBAction)studyStudyUIDGenerateButtonPushed:(NSButton*)sender
{
    gdcm::UIDGenerator suid;
    std::string studyUID = suid.Generate();
    self.seriesInfo.studyStudyUID = [NSString stringWithUTF8String:studyUID.c_str()];

    NSLog(@"studyStudyUIDGenerateButtonPressed: %@", self.seriesInfo.studyStudyUID);
}

- (IBAction)studyDateNowButtonPressed:(NSButton *)sender
{
    self.seriesInfo.studyDateTime = [NSDate date];
}

- (IBAction)dicomCloseButtonPressed:(NSButton *)sender
{
    NSLog(@"dicomCloseButtonPressed");

    if (![self.seriesInfo isComplete])
    {
        NSAlert* alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert setMessageText:@"Information is incomplete."];
        [alert setInformativeText:@"All DICOM information fields must be filled in."];
        [alert beginSheetModalForWindow:self.window
                          modalDelegate:nil didEndSelector:nil contextInfo:nil];
        return;
    }

    if (![self.seriesInfo isConsistent])
    {
        return;
    }

    if ([self makeOutputDirectory:self.seriesInfo.outputDir] == YES)
    {
        [self.convertButton setEnabled:YES];
        
        [UserDefaults saveDefaults:self.seriesInfo];
        [NSApp endSheet:self.dicomInfoPanel];
        [self.dicomInfoPanel orderOut:self];
    }
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
    else
    {
        NSException* ex =
        [NSException exceptionWithName:@"InvalidIdentifier"
                                reason:[NSString stringWithFormat:@"Combobox identifier %@ is invalid.", ident]
                              userInfo:nil];
        @throw ex;
    }

}

#pragma mark - Utilities

- (void)makeOutputDirectoryName:(NSString*)dirName
{
    NSString* fullName = [NSMutableString stringWithFormat:@"%@/%@/%@ - %@/%@ - %@/",
                          dirName, self.seriesInfo.patientsName,
                          self.seriesInfo.studyDescription, self.seriesInfo.studyID,
                          self.seriesInfo.seriesDescription, self.seriesInfo.seriesNumber];

    self.seriesInfo.outputPath = fullName;
}

- (BOOL)makeOutputDirectory:(NSString*)dirName
{
    NSError* error = nil;

    [self makeOutputDirectoryName:self.seriesInfo.outputDir];

    NSFileManager* fm = [NSFileManager defaultManager];

    BOOL retVal = [fm createDirectoryAtPath:self.seriesInfo.outputPath withIntermediateDirectories:YES
                                attributes:nil error:&error];

    if (retVal == NO)
    {
        if (error != nil)
        {
            NSAlert* alert = [NSAlert alertWithError:error];
            [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            }];
        }

        return retVal;
    }
    else
    {
        // We want an empty directory
        NSArray* contents = [fm contentsOfDirectoryAtPath:self.seriesInfo.outputPath error:&error];
        if ([contents count] != 0)
        {
            NSAlert* alert = [NSAlert alertWithMessageText:@"Output directory is not empty."
                                             defaultButton:@"Close" alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"%@", self.seriesInfo.outputPath];
            [alert beginSheetModalForWindow:self.dicomInfoPanel completionHandler:^(NSModalResponse returnCode) {
            }];

            retVal = NO;
        }
    }

    return retVal;
}

@end
