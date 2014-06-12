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
    NSMutableArray* fileNames;
}

@property (retain) NSURL* inputDir;
@property (retain) NSURL* outputDir;
@property (retain) NSWindow* parentWindow;
@property (retain) SeriesInfo* seriesInfo;

- (id)init;
- (NSUInteger)loadFileNames;
- (BOOL)extractSeriesDicomAttributes;
- (void)readFiles;
- (void)writeFiles;

@end
