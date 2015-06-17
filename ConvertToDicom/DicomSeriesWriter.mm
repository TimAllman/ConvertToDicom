//
//  DicomSeriesWriter.cpp
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-28.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//


#include "DicomSeriesWriter.h"

#include <itkVersion.h>
#include <itkImage.h>
#include <itkImageSeriesWriter.h>
#include <itkNumericSeriesFileNames.h>
#include <itkGDCMImageIO.h>
#include <itkMetaDataDictionary.h>
#include <itkMetaDataObject.h>
#include <itkTileImageFilter.h>

#include <vnl/vnl_vector_fixed.h>
#include <vnl/vnl_matrix_fixed.h>

#include <itksys/SystemTools.hxx>

#include <gdcmUIDGenerator.h>

#include "DumpMetaDataDictionary.h"
#include "SeriesInfoITK.h"

#include "LoggerName.h"
#include <log4cplus/loggingmacros.h>

#include <iostream>
#include <sstream>

DicomSeriesWriter::DicomSeriesWriter(const SeriesInfoITK& dicomParams,
                                     std::vector<Image2DType::Pointer>& images,
                                     std::string outputDirectoryName)
: seriesInfo(dicomParams), images(images), outputDirectory(outputDirectoryName),
  logger_(log4cplus::Logger::getInstance(std::string(LOGGER_NAME) + ".DicomSeriesWriter"))
{
    std::string name = std::string(LOGGER_NAME) + ".DicomSeriesWriter";
    LOG4CPLUS_TRACE(logger_, "Enter");
}

ErrorCode DicomSeriesWriter::WriteFileSeries()
{
    LOG4CPLUS_TRACE(logger_, "Enter");
    // Set up the new metadata dictionary array
    // This is based upon the example on the ITK examples wiki
    // http://www.itk.org/Wiki/ITK/Examples/DICOM/ResampleDICOM
    //

    PrepareMetaDataDictionaryArray();

    //
    // create a Dicom series writer
    itk::GDCMImageIO::Pointer dicomIo = itk::GDCMImageIO::New();
    dicomIo->SetPixelType(itk::ImageIOBase::SCALAR);
    dicomIo->KeepOriginalUIDOn();

    // define the filenames generator type and instance
    typedef itk::NumericSeriesFileNames NameGeneratorType;
    NameGeneratorType::Pointer nameGenerator = NameGeneratorType::New();

    std::stringstream value;
    value.str("");
    value << outputDirectory << "/IM-" << seriesInfo.seriesNumber() << "-%04d.dcm";
    nameGenerator->SetSeriesFormat(value.str());
    nameGenerator->SetStartIndex(1);
    nameGenerator->SetEndIndex(images.size());
    fileNames = nameGenerator->GetFileNames();

    // We want to empty the output directory so we remove it and recreate it.
    itksys::SystemTools::RemoveADirectory(outputDirectory);
    itksys::SystemTools::MakeDirectory(outputDirectory);

    typedef itk::ImageSeriesWriter<Image3DType, Image2DType> WriterType;
    WriterType::Pointer writer = WriterType::New();
    writer->SetImageIO(dicomIo);
    writer->SetFileNames(fileNames);
    writer->SetMetaDataDictionaryArray(&dictArray);
    Image3DType::Pointer image = MergeSlices();
    writer->SetInput(image);

    try
    {
        writer->Update();
    }
    catch (itk::ExceptionObject& ex)
    {
        LOG4CPLUS_ERROR(logger_, "ExceptionObject caught. " << ex.what());
        return ERROR_WRITING_FILE;
    }

    return SUCCESS;
}

void DicomSeriesWriter::CopyDictionary(const itk::MetaDataDictionary& fromDict,
                                       itk::MetaDataDictionary& toDict)
{
    LOG4CPLUS_TRACE(logger_, "Enter");

    typedef itk::MetaDataDictionary DictionaryType;

    DictionaryType::ConstIterator itr = fromDict.Begin();
    DictionaryType::ConstIterator end = fromDict.End();
    typedef itk::MetaDataObject< std::string > MetaDataStringType;

    while (itr != end)
    {
        itk::MetaDataObjectBase::Pointer  entry = itr->second;

        MetaDataStringType::Pointer entryvalue = dynamic_cast<MetaDataStringType *>(entry.GetPointer()) ;
        if (entryvalue)
        {
            std::string tagkey = itr->first;
            std::string tagvalue = entryvalue->GetMetaDataObjectValue();
            itk::EncapsulateMetaData<std::string>(toDict, tagkey, tagvalue);
        }
        ++itr;
    }
}

void DicomSeriesWriter::PrepareMetaDataDictionaryArray()
{
    LOG4CPLUS_TRACE(logger_, "Enter");

    // It may have been used in a previous run.
    dictArray.clear();

    itk::MetaDataDictionary seriesDict = seriesInfo.dictionary();
    LOG4CPLUS_TRACE(logger_, DumpDicomMetaDataDictionary(seriesDict));

    //
    // To keep the new series in the same study as the original we need
    // to keep the same study UID. But we need new series and frame of
    // reference UID's.
    gdcm::UIDGenerator uidGen;
    std::string seriesUID = uidGen.Generate();
    itk::EncapsulateMetaData<std::string>(seriesDict, "0020|000e", seriesUID);
    itk::EncapsulateMetaData<std::string>(seriesDict, "0020|000e", seriesUID);

    std::string frameOfReferenceUID = uidGen.Generate();
    itk::EncapsulateMetaData<std::string>(seriesDict,"0020|0052", frameOfReferenceUID);

    std::string sopInstanceUID = uidGen.Generate();
    //itk::EncapsulateMetaData<std::string>(seriesDict, "0008|0018", sopInstanceUID);
    itk::EncapsulateMetaData<std::string>(seriesDict, "0002|0003", sopInstanceUID);

    std::stringstream sstr;
    unsigned numTimes = seriesInfo.numberOfImages();
    if (numTimes > 1)
    {
        sstr.str("");
        sstr << numTimes;
        std::string numTemporalPositions = sstr.str();
        itk::EncapsulateMetaData<std::string>(seriesDict, "0020|0105", numTemporalPositions);
    }

    // These are converted images so we show that.
    itk::EncapsulateMetaData<std::string>(seriesDict, "0008|0008", "ORIGINAL");
    itk::EncapsulateMetaData<std::string>(seriesDict, "0008|0064", "WSD");

//    // Derivation Description - How this image was derived
//    std::ostringstream value;
//    value.str("");
//    value << "Converted to DICOM using " << ITK_SOURCE_VERSION;
//    // Deal with a 1024 character max length.
//    unsigned lengthOfDesc = static_cast<unsigned>(value.str().length());
//    std::string derivationDesc(value.str(), 0, lengthOfDesc > 1024 ? 1024 : lengthOfDesc);
//    itk::EncapsulateMetaData<std::string>(seriesDict, "0008|2111", derivationDesc);

    // loop through the images, then the slices
    for (unsigned imageIdx = 0; imageIdx < numTimes; ++imageIdx)
    {
        itk::MetaDataDictionary imageDict;
        CopyDictionary(seriesDict, imageDict);

        if (numTimes > 1)
        {
            // Temporal Position
            sstr.str("");
            sstr << imageIdx+1;
            std::string temporalPosition = sstr.str();
            itk::EncapsulateMetaData<std::string>(imageDict, "0020|0100", temporalPosition);

            // Instance Number (same as temporal position)
            itk::EncapsulateMetaData<std::string>(imageDict, "0020|0013", temporalPosition);
        }

        std::string acqTime = seriesInfo.acqTimes()[imageIdx];
        itk::EncapsulateMetaData<std::string>(imageDict, "0008|0032", acqTime);

        // Now go through the slices
        itk::MetaDataDictionary* sliceDict = new itk::MetaDataDictionary;
        CopyDictionary(imageDict, *sliceDict);

        for (unsigned sliceIdx = 0; sliceIdx < seriesInfo.slicesPerImage(); ++sliceIdx)
        {
            std::string imagePositionPatient = seriesInfo.imagePatientPosition();
            itk::EncapsulateMetaData<std::string>(*sliceDict, "0020|0032", imagePositionPatient);
            imagePositionPatient = IncrementImagePositionPatient();

//            std::string sopInstanceUID = uidGen.Generate();
//            itk::EncapsulateMetaData<std::string>(*sliceDict, "0008|0018", sopInstanceUID);
            //itk::EncapsulateMetaData<std::string>(seriesDict, "0002|0003", sopInstanceUID);
        }

        LOG4CPLUS_TRACE(logger_, DumpDicomMetaDataDictionary(*sliceDict));

        dictArray.push_back(sliceDict);
    }
}

std::string DicomSeriesWriter::IncrementImagePositionPatient()
{
    LOG4CPLUS_TRACE(logger_, "Enter");

    vnl_matrix_fixed<float, 3, 3> rot;   // the rotation matrix
    vnl_vector_fixed<float, 3> ipp;      // the IPP (column) vector

    // Create the rotation matrix from IOP
    sscanf(seriesInfo.imagePatientOrientation().c_str(), "%f\\%f\\%f\\%f\\%f\\%f",
           &rot(0, 0), &rot(0, 1), &rot(0, 2), &rot(1, 0), &rot(1, 1), &rot(1, 2));

    // Compute the remaining orthogonal vector to complete the matrix
    rot(2,0) = rot(0, 1) * rot(1, 2) - rot(0, 2) * rot(1, 1);
    rot(2,1) = rot(0, 2) * rot(1, 0) - rot(0, 0) * rot(1, 2);
    rot(2,2) = rot(0, 0) * rot(1, 1) - rot(0, 1) * rot(1, 0);

    // IPP as a vector
    ipp[0] = seriesInfo.imagePatientPositionX();
    ipp[1] = seriesInfo.imagePatientPositionY();
    ipp[2] = seriesInfo.imagePatientPositionZ();

    ipp = rot * ipp;                            // rotate ipp into image coordinates
    ipp[2] += seriesInfo.imageSliceSpacing();   // increment Z component
    ipp = rot.inplace_transpose() * ipp;        // rotate back into patient coordinates

    char ippStr[32];
    sprintf(ippStr, "%.2f\\%.2f\\%.2f", ipp(0), ipp(1), ipp(2));

    LOG4CPLUS_DEBUG(logger_, "Incremented IPP = " << ippStr);

    return ippStr;

    /* extracted from osirix, reflected in above code
    float vec[3];
    vec[0] = iop[1]*iop[5] - iop[2]*iop[4];
    vec[1] = iop[2]*iop[3] - iop[0]*iop[5];
    vec[2] = iop[0]*iop[4] - iop[1]*iop[3];
     */
}

Image3DType::Pointer DicomSeriesWriter::MergeSlices()
{
    LOG4CPLUS_TRACE(logger_, "Enter");

    // Concatenate the whole bunch of slices into one image.
    typedef itk::TileImageFilter<Image2DType, Image3DType> TileFilterType;
    TileFilterType::Pointer tileFilter = TileFilterType::New();

    itk::FixedArray<unsigned int, 3> layout;
    layout[0] = 1;
    layout[1] = 1;
    layout[2] = 0;

    LOG4CPLUS_DEBUG(logger_, "Layout = " << layout);

    tileFilter->SetLayout(layout);
    tileFilter->SetDefaultPixelValue(0);
    unsigned long numSlices = images.size();
    for (unsigned idx = 0; idx < numSlices; ++idx)
    {
        tileFilter->SetInput(idx, images[idx]);
    }

    tileFilter->Update();

    Image3DType::Pointer image3d = tileFilter->GetOutput();
    return image3d;
}
