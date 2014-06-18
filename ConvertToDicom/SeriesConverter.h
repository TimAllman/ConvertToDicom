//
//  SeriesConverter.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-24.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ErrorCodes.h"
#import "WindowController.h"
@class SeriesInfo;
@class Logger;

@interface SeriesConverter : NSObject
{
    Logger* logger_;
    NSMutableArray* fileNames;
}

@property (retain) NSURL* inputDir;
@property (retain) NSURL* outputDir;
@property (retain) WindowController* windowController;
@property (retain) SeriesInfo* seriesInfo;

- (id)init;
- (ErrorCode)loadFileNames;
- (ErrorCode)extractSeriesDicomAttributes;
- (ErrorCode)readFiles;
- (ErrorCode)writeFiles;

@end
