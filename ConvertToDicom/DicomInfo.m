//
//  DicomInfo.m
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-04-01.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import "DicomInfo.h"

// Keys for preferences.
NSString* PatientsSexKey = @"PatientsSex";
NSString* StudyDateTimeKey  = @"StudyDateTime";
NSString* ImageSliceThicknessKey = @"ImageSliceThickness";

@implementation DicomInfo

+ (void)initialize
{
    // Create the factory defaults for the preferences
    NSMutableDictionary* defaults = [NSMutableDictionary dictionary];

    [defaults setObject:@"Other" forKey:PatientsSexKey];
    [defaults setObject:[NSDate date] forKey:StudyDateTimeKey];
    [defaults setObject:@1.0 forKey:ImageSliceThicknessKey];

    [[NSUserDefaults standardUserDefaults]registerDefaults:defaults];
}



- (id)init
{
    self = [super init];
    if (self)
    {

    }
    return self;
}

@end
