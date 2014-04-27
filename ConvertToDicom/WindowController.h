//
//  WindowController.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-24.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DicomPanelController;

@interface WindowController : NSWindowController
{
    NSURL* inputDir;
    NSURL* outputDir;
    DicomPanelController* dicomPanelController;
}

@property (weak) IBOutlet NSTextField *inputDirTextField;
@property (weak) IBOutlet NSTextField *outputDirTextField;
@property (weak) IBOutlet NSTextField *slicesPerImageTextField;
@property (weak) IBOutlet NSTextField *timeIncrementTextField;
- (IBAction)inputDirButtonPressed:(NSButton *)sender;
- (IBAction)outputDirButtonPressed:(NSButton *)sender;
- (IBAction)convertButtonPressed:(NSButton *)sender;
- (IBAction)closeButtonPressed:(NSButton *)sender;
- (IBAction)setDicomTagsButtonPushed:(NSButton *)sender;

@end
