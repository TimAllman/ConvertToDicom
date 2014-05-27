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

- (id)initWithInputDir:(NSURL *)inpDir outputDir:(NSURL *)outpDir seriesInfo:(SeriesInfo *)info
{
    self = [super init];
    if (self)
    {
        inputDir = inpDir;
        outputDir = outpDir;
        fileNames = [NSMutableArray array];
        seriesInfo = info;
    }
    return self;
}

- (void)extractSeriesDicomAttributes
{
    // Take the information we need from the first image
    std::string firstFileName([[[fileNames objectAtIndex:0] path] UTF8String]);
    itk::ImageIOBase::Pointer imageIO =
        itk::ImageIOFactory::CreateImageIO(firstFileName.c_str(), itk::ImageIOFactory::ReadMode);

    // If there is a problem, catch it
    if (imageIO.IsNull())
    {
        std::cout << "Could not get metadata from file: " << firstFileName << "\n";
        return;
    };

    // Get the number of dimensions.
    unsigned numDims = imageIO->GetNumberOfDimensions();

    // use for creating strings below.
    std::ostringstream value;

    // Set the Image Orientation Patient attribute from the image direction info.
    std::vector<double> dir = imageIO->GetDirection(0);
    value << dir[0] << "\\" << dir[1] << "\\" << dir[2] << "\\";
    dir = imageIO->GetDirection(1);
    value << dir[0] << "\\" << dir[1] << "\\" << dir[2];
    std::string imageOrientationPatient = value.str();
    seriesInfo.imagePatientOrientation = [NSString stringWithUTF8String:imageOrientationPatient.c_str()];

    // Image Position Patient
    seriesInfo.imagePatientPositionX = [NSNumber numberWithDouble:imageIO->GetOrigin(0)];
    seriesInfo.imagePatientPositionY = [NSNumber numberWithDouble:imageIO->GetOrigin(1)];
    if (numDims == 3)
        seriesInfo.imagePatientPositionZ = [NSNumber numberWithDouble:imageIO->GetOrigin(2)];
    else
        seriesInfo.imagePatientPositionZ = [NSNumber numberWithDouble:0.0];
}

- (NSUInteger)loadFileNames
{
    NSArray* keys = [NSArray arrayWithObjects:NSURLIsDirectoryKey, NSURLLocalizedNameKey, nil];

    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator =
        [fileManager enumeratorAtURL:inputDir includingPropertiesForKeys:keys
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
        NSLog(@"%@", filePath);

        paths.push_back([filePath UTF8String]);
    }

    // Read in all of the slices
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
    // Now write them out
    DicomSeriesWriter writer( imageStack, [[outputDir path] UTF8String], 314159u);
    writer.WriteFileSeries();
}

@end
