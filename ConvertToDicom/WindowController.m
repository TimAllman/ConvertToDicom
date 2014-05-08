//
//  WindowController.m
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-24.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import "WindowController.h"
#import "SeriesConverter.h"
#import "DicomPanelController.h"

// Keys for preferences.
NSString* InputDirKey = @"InputDir";
NSString* OutputDirKey = @"OutputDir";
NSString* SlicesPerImageKey = @"SlicesPerImage";
NSString* TimeIncrementKey = @"TimeIncrement";

NSString* PatientsNameKey = @"PatientsName";
NSString* PatientsIDKey = @"PatientsID";
NSString* PatientsDOBKey = @"PatientsDOB";
NSString* PatientsSexKey = @"PatientsSex";
NSString* StudyDescriptionKey = @"studyDescription";
NSString* StudyIDKey = @"studyID";
NSString* StudyModalityKey = @"studyModality";
NSString* StudyDateTimeKey = @"StudyDateTime";
NSString* StudySeriesUIDKey = @"studySeriesUID";
NSString* ImageSliceThicknessKey = @"ImageSliceThickness";
NSString* ImagePatientPositionXKey = @"ImagePatientPositionX";
NSString* ImagePatientPositionYKey = @"ImagePatientPositionY";
NSString* ImagePatientPositionZKey = @"ImagePatientPositionZ";
NSString* ImagePatientOrientationKey = @"ImagePatientOrientation";

@interface WindowController ()

@end

@implementation WindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self)
    {
        modalities = [NSArray arrayWithObjects:
                      @"CR", @"CT", @"DX", @"ES", @"MG", @"MR", @"NM",
                      @"OT", @"PT", @"RF", @"SC", @"US", @"XA", nil];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Load preferences and do other initialisation

}

- (IBAction)inputDirButtonPressed:(NSButton *)sender
{

    NSOpenPanel* panel = [NSOpenPanel openPanel];

    panel.canChooseFiles = NO;
    panel.canChooseDirectories = YES;
    panel.canCreateDirectories = NO;
    panel.allowsMultipleSelection = NO;
    [panel setDirectoryURL:[NSURL URLWithString:self.inputDir]];

    [panel beginWithCompletionHandler:^(NSInteger result)
    {
        if (result == NSFileHandlingPanelOKButton)
        {
            NSURL* inputDir = [[panel URLs] objectAtIndex:0];
            self.inputDir = [inputDir path];
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
             self.outputDir = [outputDir path];
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
    [self close];
}

- (IBAction)setDicomTagsButtonPushed:(NSButton *)sender
{
    [NSApp beginSheet:self.dicomInfoPanel modalForWindow:self.window modalDelegate:self
       didEndSelector:@selector(didEndDicomAttributesSheet:returnCode:contextInfo:) contextInfo:nil];


}

- (void)didEndDicomAttributesSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    NSLog(@"didEndSheet:returnCode:contextInfo:");

    if (returnCode == NSOKButton)
    {
        SeriesConverter* sc = [[SeriesConverter alloc]initWithInputDir:[NSURL URLWithString:self.inputDir]
                                                             outputDir:[NSURL URLWithString:self.outputDir]];
        if ([sc loadFileNames] == 0)
        {
            NSAlert* alert = [[NSAlert alloc] init];
            [alert setAlertStyle:NSCriticalAlertStyle];
            [alert setMessageText:[@"Image file not found in directory "
                                   stringByAppendingString:self.inputDir]];
            [alert setInformativeText:@"Set the input directory to one containing image files."];
            [alert beginSheetModalForWindow:self.window
                              modalDelegate:self
                             didEndSelector:@selector(didEndAlertSheet:returnCode:contextInfo:)
                                contextInfo:nil];
            return;
        };

        [sc extractSeriesDicomAttributes:self.dicomInfo];

        //[self.dicomInfoPanel orderOut:self];
    }
}

- (void)didEndAlertSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    NSLog(@"didEndAlertSheet:returnCode:contextInfo:");
}

- (void)convertFiles
{
    SeriesConverter* sc = [[SeriesConverter alloc]initWithInputDir:[NSURL URLWithString:self.inputDir]
                                                         outputDir:[NSURL URLWithString:self.outputDir]];
    [sc loadFileNames];
    [sc readFiles];
    [sc writeFiles];
}

#pragma mark - DicomPanel

- (IBAction)imageSetIopAxialButtonPressed:(NSButton*)sender
{
    NSLog(@"imageSetIopAxialButtonPressed");
}

- (IBAction)imageSetIopSaggitalButtonPressed:(NSButton *)sender
{
    NSLog(@"imageSetIopSaggitalButtonPressed");
}

- (IBAction)imageSetIopCoronalButtonPressed:(NSButton*)sender
{
    NSLog(@"imageSetIopCoronalButtonPressed");
}

- (IBAction)studySeriesUIDGenerateButtonPushed:(NSButton*)sender
{
    NSLog(@"studySeriesUIDGenerateButtonPressed");
}

- (IBAction)studyDateNowButtonPressed:(NSButton *)sender {
}

- (IBAction)dicomCloseButtonPressed:(NSButton *)sender
{
    NSLog(@"closeButtonPressed");

    [NSApp endSheet:self.window];
    //[self.window orderOut:self];
    //openSheet_ = nil;

    //[self close];
}

@end
