//
//  SeriesConverter.mm
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-24.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import "SeriesConverter.h"
#import "ProjectDefs.h"

#include "FileReader.h"
#include "DicomSeriesWriter.h"

#include <vector>

@interface SeriesConverter()
{
    std::vector<Image2DType::Pointer> images;
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
    FileReader reader;
    for (std::vector<std::string>::iterator iter = paths.begin(); iter != paths.end(); ++iter)
    {
        Image2DType::Pointer image = reader.ReadImage(*iter);
        images.push_back(image);
    }
}

- (void)writeFiles
{
    // Now write them out
    DicomSeriesWriter writer(images, [[outputDir path] UTF8String], 314159u);
    writer.WriteFileSeries();
}

@end
