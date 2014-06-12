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

class SeriesInfoITK;

class DicomSeriesWriter
{
public:
    typedef unsigned short DicomPixelType;

    DicomSeriesWriter(const SeriesInfoITK& seriesInfoITK, std::vector<Image2DType::Pointer>& images,
                      std::string outputDirectoryName);

    void WriteFileSeries();

private:
    void CopyDictionary(itk::MetaDataDictionary& fromDict, itk::MetaDataDictionary& toDict);
    void PrepareMetaDataDictionaryArray();
    std::string IncrementImagePositionPatient();
    Image3DType::Pointer MergeSlices();
    bool CheckOutputDirectoryExistence();
    bool MakeOutputDirectory();

    const SeriesInfoITK& seriesInfo;
    std::vector<Image2DType::Pointer>& images;
    std::string outputDirectory;

    std::vector<std::string> fileNames;
    std::vector<itk::MetaDataDictionary*> dictArray;
};

#endif /* defined(__ConvertToDicom__DicomFileWriter__) */
