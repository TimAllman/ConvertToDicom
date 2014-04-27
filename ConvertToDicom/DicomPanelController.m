//
//  DicomPanelController.m
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-30.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import "DicomPanelController.h"

@interface DicomPanelController ()

@end

@implementation DicomPanelController

- (id)init
{
    self = [super initWithWindowNibName:@"DicomPanel"];
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
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

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

- (IBAction)closeButtonPressed:(NSButton *)sender
{
    NSLog(@"closeButtonPressed");

    [NSApp endSheet:self.window];
    //[self.window orderOut:self];
    //openSheet_ = nil;

    //[self close];
}
@end
