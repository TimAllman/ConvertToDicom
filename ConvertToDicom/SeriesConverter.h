//
//  SeriesConverter.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-24.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DicomInfo;

@interface SeriesConverter : NSObject
{
    NSURL* inputDir;
    NSURL* outputDir;
    NSMutableArray* fileNames;
}

- (id)initWithInputDir:(NSURL *)inpDir outputDir:(NSURL *)outpDir;
- (NSUInteger)loadFileNames;
- (void)extractDicomAttributes:(DicomInfo*)dicomInfo;
- (void)readFiles;
- (void)writeFiles;

@end
