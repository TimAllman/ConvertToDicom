//
//  SeriesConverter.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-24.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SeriesInfo;

@interface SeriesConverter : NSObject
{
    NSURL* inputDir;
    NSURL* outputDir;
    NSMutableArray* fileNames;
    SeriesInfo* seriesInfo;
}

- (id)initWithInputDir:(NSURL *)inpDir outputDir:(NSURL *)outpDir seriesInfo:(SeriesInfo*)info;
- (NSUInteger)loadFileNames;
- (void)extractSeriesDicomAttributes;
- (void)readFiles;
- (void)writeFiles;

@end
