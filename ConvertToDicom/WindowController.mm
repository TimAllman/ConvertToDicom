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

#include <gdcmUIDGenerator.h>

@implementation WindowController

- (id)init
{
    self = [super initWithWindowNibName:@"MainWindow"];
    if (self)
    {
        modalities = [NSArray arrayWithObjects:
                      @"CR", @"CT", @"DX", @"ES", @"MG", @"MR", @"NM",
                      @"OT", @"PT", @"RF", @"SC", @"US", @"XA", nil];
        sexes = [NSArray arrayWithObjects:@"Male", @"Female", @"Unspecified", nil];
    }
    return self;
}

- (IBAction)inputDirButtonPressed:(NSButton *)sender
{

    NSOpenPanel* panel = [NSOpenPanel openPanel];

    panel.canChooseFiles = NO;
    panel.canChooseDirectories = YES;
    panel.canCreateDirectories = NO;
    panel.allowsMultipleSelection = NO;
    [panel setDirectoryURL:[NSURL URLWithString:self.seriesInfo.inputDir]];

    [panel beginWithCompletionHandler:^(NSInteger result)
    {
        if (result == NSFileHandlingPanelOKButton)
        {
            NSURL* inputDir = [[panel URLs] objectAtIndex:0];
            self.seriesInfo.inputDir = [inputDir path];
            NSLog(@"URL chosen: %@", inputDir);
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

    [panel beginWithCompletionHandler:^(NSInteger result)
     {
         if (result == NSFileHandlingPanelOKButton)
         {
             NSURL* outputDir = [[panel URLs] objectAtIndex:0];
             self.seriesInfo.outputDir = [outputDir path];
             NSLog(@"URL chosen: %@", outputDir);
         }
     }];
}

- (IBAction)convertButtonPressed:(NSButton *)sender
{
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
    [NSApp beginSheet:self.dicomInfoPanel modalForWindow:self.window modalDelegate:self
       didEndSelector:@selector(didEndDicomAttributesSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (void)didEndDicomAttributesSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    NSLog(@"didEndDicomAttributesSheet:returnCode:contextInfo:");

    if (returnCode == NSOKButton)
    {
        SeriesConverter* sc = [[SeriesConverter alloc]
                               initWithInputDir:[NSURL URLWithString:self.seriesInfo.inputDir]
                               outputDir:[NSURL URLWithString:self.seriesInfo.outputDir]];
        if ([sc loadFileNames] == 0)
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
        };

        [sc extractSeriesDicomAttributes:self.seriesInfo];
    }
}

- (void)didEndAlertSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    NSLog(@"didEndAlertSheet:returnCode:contextInfo:");
}

- (void)convertFiles
{
    SeriesConverter* sc = [[SeriesConverter alloc]
                           initWithInputDir:[NSURL URLWithString:self.seriesInfo.inputDir]
                           outputDir:[NSURL URLWithString:self.seriesInfo.outputDir]];
    [sc loadFileNames];
    [sc readFiles];
    [sc writeFiles];
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
    NSLog(@"closeButtonPressed");

    [UserDefaults saveDefaults:self.seriesInfo];
    [NSApp endSheet:self.dicomInfoPanel];
    [self.dicomInfoPanel orderOut:self];
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
@end
