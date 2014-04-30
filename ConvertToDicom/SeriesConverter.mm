//
//  SeriesConverter.mm
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-24.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import "Typedefs.h"
#import "SeriesConverter.h"
#import "DicomInfo.h"

#include "ImageReader.h"
#include "DicomSeriesWriter.h"

#include <vector>

@interface SeriesConverter()
{
    std::vector<Image2DType::Pointer> imageStack;
}

@end

@implementation SeriesConverter

- (id)initWithInputDir:(NSURL *)inpDir outputDir:(NSURL *)outpDir
{
    self = [super init];
    if (self)
    {
        inputDir = inpDir;
        outputDir = outpDir;
        fileNames = [NSMutableArray array];
    }
    return self;
}

- (void)extractDicomAttributes:(DicomInfo *)dicomInfo
{
    // Take the information we need from the first image
    ImageReader reader;
    ImageReader::ImageVector images = reader.ReadImage([[[fileNames objectAtIndex:0] path] UTF8String]);
    Image2DType::Pointer firstImage = images[0];

    // use for creating strings below.
    std::ostringstream value;

    // Set the Image Orientation Patient attribute from the image direction info.
    Image2DType::DirectionType dir = firstImage->GetDirection();
    value << dir[0][0] << "\\" << dir[0][1] << "\\" << dir[0][2] << "\\"
    << dir[1][0] << "\\" << dir[1][1] << "\\" << dir[1][2];
    std::string imageOrientationPatient = value.str();
    dicomInfo.imagePatientOrientation = [NSString stringWithUTF8String:imageOrientationPatient.c_str()];

    
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
            imageStack.push_back(*iter);
    }
}

- (void)writeFiles
{
    // Now write them out
    DicomSeriesWriter writer(imageStack, [[outputDir path] UTF8String], 314159u);
    writer.WriteFileSeries();
}

@end
