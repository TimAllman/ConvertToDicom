//
//  SeriesInfo.m
//  ConvertToDicom
//

/* ConvertToDicom converts a series of images to DICOM format from any format recognized
 * by ITK (http://www.itk.org).
 * Copyright (C) 2014  Tim Allman
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

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
