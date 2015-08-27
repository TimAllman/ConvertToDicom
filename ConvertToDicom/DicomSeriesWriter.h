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
 * Class to write a DICOM series. This class uses itk::ImageSeriesWriter and its arguments to
 * write a DICOM series. The series is always written as 2D slices. The logical order of the slices
 * is the same as the alphabetical order of the files which contain them.
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
 * in the tree and is the place into which the files will be written.
 */
    explicit DicomSeriesWriter(const SeriesInfoITK& seriesInfoITK, std::vector<Image2DType::Pointer>& images,
                      std::string outputDirectoryName);

    /**
     * Do the file writing.
     * @return Suitable value in ErrorCode enum.
     */
    ErrorCode WriteFileSeries();

private:
    /**
     * Copy the contents of one itk::MetaDataDictionary instance to another. The contents of the receiving
     * dictionary on entry are generally preserved although entries may be overwritten.
     * @param fromDict The source dictionary.
     * @param toDict The destination dictionary.
     */
    void CopyDictionary(const itk::MetaDataDictionary& fromDict, itk::MetaDataDictionary& toDict);

    /**
     * Initialise the itk::MetaDataDictionaryArray for the itk::ImageSeriesWriter. This adds all of the
     * entries needed to write the series. NOTE: Any enhancement that requires adding entries to
     * the itk::MetaDataDictionaryArray should do it by first extending the SeriesInfoITK class
     * and using it to add the appropriate entries.
     */
    void PrepareMetaDataDictionaryArray();

    /**
     * Create a 3D volume from the 2D slices contained in images.
     * @return ITK smart pointer to the 3D image.
     */
    Image3DType::Pointer MergeSlices();

    const SeriesInfoITK& seriesInfo;           ///< The SeriesInfoITK passed in the constructor.
    std::vector<Image2DType::Pointer>& images; ///< The array of slices.
    std::string outputDirectory;               ///< The output directory passed in the constructor.

    std::vector<std::string> fileNames;        ///< The file names of the generated DICOM files.
    std::vector<itk::MetaDataDictionary*> dictArray; ///< Array of itk::MetaDataDictionary instances.

    log4cplus::Logger logger_; ///< Logger for this class.
};

#endif /* defined(__ConvertToDicom__DicomFileWriter__) */
