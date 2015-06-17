//
//  SeriesInfo.m
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-04-01.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import "SeriesInfo.h"
#import "LoggerName.h"

#import <Log4m/Log4m.h>

@implementation SeriesInfo

- (id)init
{
    self = [super init];
    if (self)
    {
        NSString* loggerName = [[NSString stringWithUTF8String:LOGGER_NAME]
                                stringByAppendingString:@".SeriesInfo"];
        logger_ = [Logger newInstance:loggerName];
        LOG4M_TRACE(logger_, @"Enter");
    }
    return self;
}

- (BOOL)isConsistent
{
    // check input data
    unsigned numImages = [self.numberOfImages unsignedIntValue];
    unsigned numSlices = [self.numberOfSlices unsignedIntValue];

    if ((numSlices % numImages) != 0)
    {
        LOG4M_ERROR(logger_, @"Inconsistent number of images (%u) and number of slices (%u)",
                    numImages, numSlices);
        return NO;
    }

    return YES;
}

@end
