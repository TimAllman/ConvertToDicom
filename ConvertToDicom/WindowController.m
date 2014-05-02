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

@interface WindowController ()

@end

@implementation WindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)inputDirButtonPressed:(NSButton *)sender
{

    NSOpenPanel* panel = [NSOpenPanel openPanel];

    panel.canChooseFiles = NO;
    panel.canChooseDirectories = YES;
    panel.canCreateDirectories = NO;
    panel.allowsMultipleSelection = NO;

    [panel beginWithCompletionHandler:^(NSInteger result)
    {
        if (result == NSFileHandlingPanelOKButton)
        {
            inputDir = [[panel URLs] objectAtIndex:0];
            [self.inputDirTextField setStringValue:[inputDir path]];
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
             outputDir = [[panel URLs] objectAtIndex:0];
             [self.outputDirTextField setStringValue:[outputDir path]];
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
    if (dicomPanelController == nil)
        dicomPanelController = [[DicomPanelController alloc]init];

    if (dicomPanelController.window == nil)
    {
        NSLog(@"dicomPanelController.window == nil");
        return;
    }
    
    SeriesConverter* sc = [[SeriesConverter alloc]initWithInputDir:inputDir outputDir:outputDir];
    if ([sc loadFileNames] == 0)
    {
        NSAlert* alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert setMessageText:[@"Image file not found in directory " stringByAppendingString:[inputDir path]]];
        [alert setInformativeText:@"Set the input directory to one containing image files."];
        [alert beginSheetModalForWindow:dicomPanelController.window
                          modalDelegate:self
                         didEndSelector:@selector(didEndAlertSheet:returnCode:contextInfo:)
                            contextInfo:nil];
        return;
    };

    [sc extractSeriesDicomAttributes:dicomPanelController.dicomInfo];
    
    [NSApp beginSheet:dicomPanelController.window modalForWindow:self.window modalDelegate:self
       didEndSelector:@selector(didEndDicomAttributesSheet:returnCode:contextInfo:) contextInfo:nil];

}

- (void)didEndDicomAttributesSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    NSLog(@"didEndSheet:returnCode:contextInfo:");

    [dicomPanelController.window orderOut:self];
}

- (void)didEndAlertSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    NSLog(@"didEndAlertSheet:returnCode:contextInfo:");
}

- (void)convertFiles
{
    SeriesConverter* sc = [[SeriesConverter alloc]initWithInputDir:inputDir outputDir:outputDir];
    [sc loadFileNames];
    [sc readFiles];
    [sc writeFiles];
}

@end
