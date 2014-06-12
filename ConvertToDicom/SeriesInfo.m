//
//  SeriesInfo.m
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-04-01.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import "SeriesInfo.h"

@implementation SeriesInfo

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (BOOL)isComplete
{
    if ((self.inputDir == nil) || (self.outputDir == nil) || (self.numberOfImages == nil) ||
        (self.slicesPerImage == nil) || (self.timeIncrement == nil) || (self.patientsName == nil) ||
        (self.patientsID == nil) || (self.patientsDOB == nil) || (self.patientsSex == nil) ||
        (self.studyDescription == nil) || (self.studyID == nil) || (self.studyModality == nil) ||
        (self.studyDateTime == nil) || (self.studyID == nil) || (self.seriesNumber == nil) ||
        (self.seriesDescription == nil) || (self.imagePatientPositionX == nil) ||
        (self.imagePatientPositionY == nil) || (self.imagePatientPositionZ == nil) ||
        (self.imagePatientOrientation == nil))
        return NO;

    if (([self.slicesPerImage unsignedIntValue] > 1) && (self.imageSliceSpacing == nil))
        return NO;
    
    return YES;
}

- (BOOL)isConsistent
{
    return YES;
}

@end
