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

/**
 * Class to write a DICOM series using itk::ImageSeriesWriter.
 */
class DicomSeriesWriter
{
public:
    typedef unsigned short DicomPixelType; ///< Always write with this pixel type.

/**
 * Class constructor.
 * @param seriesInfoITK Instance of SeriesInfoITK containing all of the information needed.
 * @param images The DICOM images to write.
 * @param outputDirectoryName The output directory. This the deepest directory 
 * in the tree and is the place into which will be written the files
 */
    explicit DicomSeriesWriter(const SeriesInfoITK& seriesInfoITK, std::vector<Image2DType::Pointer>& images,
                      std::string outputDirectoryName);

    /**
     * Do the file writing.
     * @return Suitable value in ErrorCode enum.
     */
    ErrorCode WriteFileSeries();

private:
    
    void CopyDictionary(const itk::MetaDataDictionary& fromDict, itk::MetaDataDictionary& toDict);
    void PrepareMetaDataDictionaryArray();
    std::string IncrementImagePositionPatient(const std::string& imagePositionPatient);
    Image3DType::Pointer MergeSlices();

    const SeriesInfoITK& seriesInfo;
    std::vector<Image2DType::Pointer>& images;
    std::string outputDirectory;

    std::vector<std::string> fileNames;
    std::vector<itk::MetaDataDictionary*> dictArray;

    log4cplus::Logger logger_;
};

#endif /* defined(__ConvertToDicom__DicomFileWriter__) */
