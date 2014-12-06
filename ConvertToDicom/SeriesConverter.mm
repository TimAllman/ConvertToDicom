//
//  SeriesConverter.mm
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-24.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import "Typedefs.h"
#import "SeriesConverter.h"
#import "SeriesInfo.h"
#import "LoggerName.h"

#include "ImageReader.h"
#include "DicomSeriesWriter.h"
#include "SeriesInfoITK.h"

#include <itkImage.h>
#include <itkImageIOBase.h>
#include <itkImageIOFactory.h>

#import <Log4m/Log4m.h>

#include <vector>

@interface SeriesConverter()
{
    std::vector<Image2DType::Pointer> imageStack;
}

@end

@implementation SeriesConverter

- (id)init
{
    self = [super init];
    if (self)
    {
        NSString* loggerName = [[NSString stringWithUTF8String:LOGGER_NAME]
                                stringByAppendingString:@".SeriesConverter"];
        logger_ = [Logger newInstance:loggerName];
        LOG4M_TRACE(logger_, @"Enter");

        fileNames = [NSMutableArray array];
    }
    return self;
}

- (void)createTimesArray
{
    LOG4M_TRACE(logger_, @"Enter");

    // Here we create an array of DICOM acquisition times as time strings
    if (self.seriesInfo.acqTimes == nil)
        self.seriesInfo.acqTimes = [[NSMutableArray alloc] init];
    else if ([self.seriesInfo.acqTimes count] != 0)
        [self.seriesInfo.acqTimes removeAllObjects];
    
    if ([fileNames count] == 0)
        [self loadFileNames];

    // Get the starting time (NSTimeinterval is a typedef for double)
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"HHmmss.SSS"];

    NSDate* acqTime = self.seriesInfo.studyDateTime;
    double timeIncr = [self.seriesInfo.timeIncrement doubleValue];

    unsigned numFiles = (unsigned)[fileNames count];
    unsigned slicesPerFile = [self.seriesInfo.slicesPerImage unsignedIntValue];
    unsigned numSlices = numFiles * slicesPerFile;
    for (unsigned sliceIdx = 0; sliceIdx < numSlices; ++sliceIdx)
    {
        NSString* timeStr = [df stringFromDate:acqTime];
        [self.seriesInfo.acqTimes addObject:timeStr];

        // if the next slice needs to be incremented do it here
        if (sliceIdx % slicesPerFile == slicesPerFile - 1)
        {
            acqTime = [acqTime dateByAddingTimeInterval:timeIncr];
        }
    }

    LOG4M_DEBUG(logger_, @"acqTimes = %@", self.seriesInfo.acqTimes);
}

- (ErrorCode)extractSeriesDicomAttributes
{
    LOG4M_TRACE(logger_, @"Enter");

    // Take the information we need from the first image
    if ([self loadFileNames] == ERROR_FILE_NOT_FOUND)
    {
        LOG4M_ERROR(logger_, @"Could not find files in %@", self.seriesInfo.inputDir);
        return ERROR_FILE_NOT_FOUND;
    }
    
    std::string firstFileName([[[fileNames objectAtIndex:0] path] UTF8String]);
    itk::ImageIOBase::Pointer imageIO =
        itk::ImageIOFactory::CreateImageIO(firstFileName.c_str(), itk::ImageIOFactory::ReadMode);

    // If there is a problem, catch it
    if (imageIO.IsNull())
    {
        LOG4M_ERROR(logger_, @"Could not get metadata from file: %@",
                    [NSString stringWithUTF8String:firstFileName.c_str()]);
        return ERROR_READING_FILE;
    };

    imageIO->SetFileName(firstFileName);
    imageIO->ReadImageInformation();

    // Get the number of dimensions.
    unsigned numDims = imageIO->GetNumberOfDimensions();
    LOG4M_DEBUG(logger_, @"dimensions = %@", [NSNumber numberWithUnsignedInt:numDims]);

    // Slice thickness
    if (numDims == 3)
    {
        self.seriesInfo.slicesPerImage = [NSNumber numberWithUnsignedLong:imageIO->GetDimensions(2)];
        self.seriesInfo.imageSliceSpacing = [NSNumber numberWithFloat:imageIO->GetSpacing(2)];
    }
    else
    {
        self.seriesInfo.slicesPerImage = [NSNumber numberWithUnsignedInt:1u];
        // If we have a value use it, otherwise set to 1.0 mm
        if (self.seriesInfo.imageSliceSpacing == nil)
            self.seriesInfo.imageSliceSpacing = [NSNumber numberWithFloat:1.0];
    }

    LOG4M_DEBUG(logger_, @"slicesPerImage = %@", self.seriesInfo.slicesPerImage);
    LOG4M_DEBUG(logger_, @"imageSliceSpacing = %@", self.seriesInfo.imageSliceSpacing);
    unsigned numFiles = (unsigned)[fileNames count];
    unsigned slicesPerImage = [self.seriesInfo.slicesPerImage unsignedIntValue];
    self.seriesInfo.numberOfImages = [NSNumber numberWithUnsignedInt:numFiles / slicesPerImage];

    // use for creating strings below.
    std::ostringstream value;

    // Set the Image Orientation Patient attribute from the image direction info.
    std::vector<double> dir = imageIO->GetDirection(0);
    value << dir[0] << "\\" << dir[1] << "\\" << dir[2] << "\\";
    dir = imageIO->GetDirection(1);
    value << dir[0] << "\\" << dir[1] << "\\" << dir[2];
    std::string imageOrientationPatient = value.str();
    self.seriesInfo.imagePatientOrientation = [NSString stringWithUTF8String:imageOrientationPatient.c_str()];

    LOG4M_DEBUG(logger_, @"imagePatientOrientation = %@", self.seriesInfo.imagePatientOrientation);

    // Image Position Patient
    self.seriesInfo.imagePatientPositionX = [NSNumber numberWithFloat:imageIO->GetOrigin(0)];
    self.seriesInfo.imagePatientPositionY = [NSNumber numberWithFloat:imageIO->GetOrigin(1)];
    if (numDims == 3)
        self.seriesInfo.imagePatientPositionZ = [NSNumber numberWithFloat:imageIO->GetOrigin(2)];
    else
        self.seriesInfo.imagePatientPositionZ = [NSNumber numberWithFloat:0.0];

    LOG4M_DEBUG(logger_, @"imagePatientPosition(X, Y, Z) = %@, %@, %@",
                self.seriesInfo.imagePatientPositionX, self.seriesInfo.imagePatientPositionY,
                self.seriesInfo.imagePatientPositionZ);

    [self createTimesArray];

    return SUCCESS;
}

- (ErrorCode)loadFileNames
{
    LOG4M_TRACE(logger_, @"Enter");

    // If the array is not empty, empty it
    if ([fileNames count] != 0)
        [fileNames removeAllObjects];
    
    NSArray* keys = [NSArray arrayWithObjects:NSURLIsDirectoryKey, NSURLLocalizedNameKey, nil];

    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator =
        [fileManager enumeratorAtURL:self.inputDir includingPropertiesForKeys:keys
                             options:(NSDirectoryEnumerationSkipsSubdirectoryDescendants |
                                      NSDirectoryEnumerationSkipsPackageDescendants |
                                      NSDirectoryEnumerationSkipsHiddenFiles)
                        errorHandler:^(NSURL *url, NSError *error)
    {
        LOG4M_ERROR(logger_, @"emumeratorAtURL failed. %@", url);
        
        // Return YES if the enumeration should continue after the error.
        return NO;
    }];

    LOG4M_INFO(logger_, @"Loading files from directory: %@", self.inputDir);

    for (NSURL* url in enumerator)
    {
        NSString *localizedName = nil;
        [url getResourceValue:&localizedName forKey:NSURLLocalizedNameKey error:NULL];

        NSNumber *isDirectory = nil;
        [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];

        if (![isDirectory boolValue])
        {
            [fileNames addObject:url];
            LOG4M_DEBUG(logger_, @"Added url %@", localizedName);
        }
        else
        {
            LOG4M_DEBUG(logger_, @"Rejected url %@", localizedName);
        }
    }

    if (fileNames.count == 0)
        return ERROR_FILE_NOT_FOUND;
    else
        return SUCCESS;
}

- (ErrorCode) readFiles
{
    LOG4M_TRACE(logger_, @"Enter");

    std::vector<std::string> paths;

    for (NSURL* url in fileNames)
    {
        NSString* filePath = [url path];
        paths.push_back([filePath UTF8String]);
    }

    // Read in all of the slices
    imageStack.clear();
    ImageReader reader;
    for (std::vector<std::string>::iterator iter = paths.begin(); iter != paths.end(); ++iter)
    {
        ImageReader::ImageVector imageVec = reader.ReadImage(*iter);
        for (ImageReader::ImageVector::const_iterator iter = imageVec.begin(); iter != imageVec.end(); ++iter)
        {
            Image2DType::Pointer image = *iter;
            imageStack.push_back(*iter);
        }
    }

    LOG4M_DEBUG(logger_, @"Read %@ slices into image stack.",
                [NSNumber numberWithUnsignedLong:imageStack.size()]);
    if (imageStack.size() != (std::vector<std::string>::size_type)[fileNames count])
        return ERROR_READING_FILE;
    else
        return SUCCESS;
}

- (ErrorCode)writeFiles
{
    LOG4M_TRACE(logger_, @"Enter");

    // Convert the needed Dicom values to C++
    SeriesInfoITK info(self.seriesInfo);

    // Create the directory
    [self.windowController makeOutputDirectory:self.seriesInfo.outputDir];
    
    // Now write them out
    DicomSeriesWriter writer(info, imageStack, [self.seriesInfo.outputPath UTF8String]);
    return writer.WriteFileSeries();
}

@end
