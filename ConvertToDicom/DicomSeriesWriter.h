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
#include "ErrorCodes.h"

#include <log4cplus/logger.h>

class SeriesInfoITK;

class DicomSeriesWriter
{
public:
    typedef unsigned short DicomPixelType;

    DicomSeriesWriter(const SeriesInfoITK& seriesInfoITK, std::vector<Image2DType::Pointer>& images,
                      std::string outputDirectoryName);

    ErrorCode WriteFileSeries();

private:
    void CopyDictionary(itk::MetaDataDictionary& fromDict, itk::MetaDataDictionary& toDict);
    void PrepareMetaDataDictionaryArray();
    std::string IncrementImagePositionPatient();
    Image3DType::Pointer MergeSlices();

    const SeriesInfoITK& seriesInfo;
    std::vector<Image2DType::Pointer>& images;
    std::string outputDirectory;

    std::vector<std::string> fileNames;
    std::vector<itk::MetaDataDictionary*> dictArray;

    log4cplus::Logger logger_;
};

#endif /* defined(__ConvertToDicom__DicomFileWriter__) */
