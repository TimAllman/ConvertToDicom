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


#include "ImageReader.h"
#include "DicomSeriesWriter.h"
#include "SeriesInfoITK.h"

#include <itkImage.h>
#include <itkImageIOBase.h>
#include <itkImageIOFactory.h>

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
        fileNames = [NSMutableArray array];
    }
    return self;
}

- (void)createTimesArray
{
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
}


- (BOOL)extractSeriesDicomAttributes
{
    // Take the information we need from the first image
    [self loadFileNames];
    if ([fileNames count] == 0)
    {
        std::cout << "Could not find files in " << [self.seriesInfo.inputDir UTF8String] << "\n";
        return NO;
    }
    
    std::string firstFileName([[[fileNames objectAtIndex:0] path] UTF8String]);
    itk::ImageIOBase::Pointer imageIO =
        itk::ImageIOFactory::CreateImageIO(firstFileName.c_str(), itk::ImageIOFactory::ReadMode);

    // If there is a problem, catch it
    if (imageIO.IsNull())
    {
        std::cout << "Could not get metadata from file: " << firstFileName << "\n";
        return NO;
    };

    imageIO->SetFileName(firstFileName);
    imageIO->ReadImageInformation();

    // Get the number of dimensions.
    unsigned numDims = imageIO->GetNumberOfDimensions();

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

    // Image Position Patient
    self.seriesInfo.imagePatientPositionX = [NSNumber numberWithFloat:imageIO->GetOrigin(0)];
    self.seriesInfo.imagePatientPositionY = [NSNumber numberWithFloat:imageIO->GetOrigin(1)];
    if (numDims == 3)
        self.seriesInfo.imagePatientPositionZ = [NSNumber numberWithFloat:imageIO->GetOrigin(2)];
    else
        self.seriesInfo.imagePatientPositionZ = [NSNumber numberWithFloat:0.0];

    [self createTimesArray];

    return YES;
}

- (NSUInteger)loadFileNames
{
    // If the array is not empty, empty it
    if ([fileNames count] != 0)
        [fileNames removeAllObjects];
    
    NSArray* keys = [NSArray arrayWithObjects:NSURLIsDirectoryKey, NSURLLocalizedNameKey, nil];

    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator =
        [fileManager enumeratorAtURL:self.inputDir includingPropertiesForKeys:keys
                             options:(NSDirectoryEnumerationSkipsPackageDescendants |
                                      NSDirectoryEnumerationSkipsHiddenFiles)
                        errorHandler:^(NSURL *url, NSError *error) {
                                             // Handle the error.
                                             // Return YES if the enumeration should continue after the error.
                                             return YES;
                                         }];

    for (NSURL* url in enumerator)
    {
        NSString *localizedName = nil;
        [url getResourceValue:&localizedName forKey:NSURLLocalizedNameKey error:NULL];

        NSNumber *isDirectory = nil;
        [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];

        if (![isDirectory boolValue])
        {
            [fileNames addObject:url];
            NSLog(@"Added url %@", localizedName);
        }
        else
        {
            NSLog(@"Rejected url %@", localizedName);
        }
    }

    return fileNames.count;
}


- (void) readFiles
{
    std::vector<std::string> paths;

    for (NSURL* url in fileNames)
    {
        NSString* filePath = [url path];
        //NSLog(@"%@", filePath);

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
}

- (void)writeFiles
{
    // Convert the needed Dicom values to C++
    SeriesInfoITK info(self.seriesInfo);
    
    // Now write them out
    DicomSeriesWriter writer(info, imageStack, [self.seriesInfo.outputPath UTF8String]);
    writer.WriteFileSeries();
}

@end
