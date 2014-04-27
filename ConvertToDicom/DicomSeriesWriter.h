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

//#include <iostream>
//
//#include <itkVersion.h>
//#include <itkImage.h>
//#include <itkImageSeriesWriter.h>
//#include <itkNumericSeriesFileNames.h>
//#include <itkGDCMImageIO.h>
//#include <itkMetaDataDictionary.h>
//#include <itkCastImageFilter.h>
//#include <gdcmUIDGenerator.h>
//
//#include "BsdRegistrationDefs.h"
#include "DumpMetaDataDictionary.h"
//#include "CopyMetaDataDictionary.h"
//
//#include <iostream>
//#include <sstream>
//
//template <class TPixel>
class DicomSeriesWriter
{
public:
    typedef unsigned short DicomPixelType;

    DicomSeriesWriter(std::vector<Image2DType::Pointer>& images,
                        std::string outputDirectoryName, unsigned seriesNumber);

    void WriteFileSeries();

private:
    std::vector<Image2DType::Pointer>& images;
    std::string outputDirectory;
    unsigned seriesNumber;
    
    std::vector<std::string> fileNames;
};

#endif /* defined(__ConvertToDicom__DicomFileWriter__) */
