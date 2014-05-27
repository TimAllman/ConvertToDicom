//
//  DicomSeriesWriter.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-28.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#ifndef __ConvertToDicom__DicomFileWriter__
#define __ConvertToDicom__DicomFileWriter__

#include "Typedefs.h"

class DicomInfo;

class DicomSeriesWriter
{
public:
    typedef unsigned short DicomPixelType;

    DicomSeriesWriter(const DicomInfo& dicomInfo, std::vector<Image2DType::Pointer>& images,
                        std::string outputDirectoryName, unsigned seriesNumber);

    void WriteFileSeries();

private:
    const DicomInfo& dicomInfo;
    std::vector<Image2DType::Pointer>& images;
    std::string outputDirectory;
    unsigned seriesNumber;
    
    std::vector<std::string> fileNames;
};

#endif /* defined(__ConvertToDicom__DicomFileWriter__) */
