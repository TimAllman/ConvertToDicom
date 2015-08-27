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
#include <iomanip>

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
    LOG4CPLUS_TRACE(logger_, "********** seriesDict - 1 ************");
    LOG4CPLUS_TRACE(logger_, DumpDicomMetaDataDictionary(seriesDict));

    bool isTimeSeries = (seriesInfo.timeIncrement() > 0.0);
    if (isTimeSeries)
    {
        std::stringstream sstr;
        unsigned numTimes = seriesInfo.numberOfImages();
        if (numTimes > 1)
        {
            sstr.str("");
            sstr << numTimes;
            std::string numTemporalPositions = sstr.str();
            itk::EncapsulateMetaData<std::string>(seriesDict, "0020|0105", numTemporalPositions);
        }
    }

    // These are converted images so we show that.
    itk::EncapsulateMetaData<std::string>(seriesDict, "0008|0008", "ORIGINAL");
    itk::EncapsulateMetaData<std::string>(seriesDict, "0008|0064", "WSD");

    LOG4CPLUS_TRACE(logger_, "********** seriesDict - 2 ************");
    LOG4CPLUS_TRACE(logger_, DumpDicomMetaDataDictionary(seriesDict));

    // Derivation Description - How this image was derived
    std::ostringstream value;
    value.str("");
    value << "Converted to DICOM using " << ITK_SOURCE_VERSION;
    // Deal with a 1024 character max length.
    unsigned lengthOfDesc = static_cast<unsigned>(value.str().length());
    std::string derivationDesc(value.str(), 0, lengthOfDesc > 1024 ? 1024 : lengthOfDesc);
    itk::EncapsulateMetaData<std::string>(seriesDict, "0008|2111", derivationDesc);

    // loop through the images, and the slices in each image
    unsigned instanceNumber = 1;
    for (unsigned imageIdx = 0; imageIdx < seriesInfo.numberOfImages(); ++imageIdx)
    {
        itk::MetaDataDictionary imageDict;
        CopyDictionary(seriesDict, imageDict);

        if (isTimeSeries)
        {
            // Temporal Position
            std::stringstream sstr;
            sstr.str("");
            sstr << imageIdx+1;
            std::string temporalPosition = sstr.str();
            itk::EncapsulateMetaData<std::string>(imageDict, "0020|0100", temporalPosition);
        }

        std::string acqTime = seriesInfo.acqTimes()[imageIdx];
        itk::EncapsulateMetaData<std::string>(imageDict, "0008|0032", acqTime);

        float sliceLocation = 0.0;
        for (unsigned sliceIdx = 0; sliceIdx < seriesInfo.slicesPerImage(); ++sliceIdx)
        {
            // Make a new dictionary for the slice and copy over the information already set
            // We need a pointer because the dictionary array is an array of pointers.
            itk::MetaDataDictionary *sliceDict = new itk::MetaDataDictionary();
            CopyDictionary(imageDict, *sliceDict);
            
            gdcm::UIDGenerator sopuidGen;
            std::string sopInstanceUID = sopuidGen.Generate();
            //itk::EncapsulateMetaData<std::string>(*sliceDict, "0008|0018", sopInstanceUID);
            itk::EncapsulateMetaData<std::string>(*sliceDict, "0002|0003", sopInstanceUID);
            
            // Set the IPP for this slice
            std::string imagePositionPatient = seriesInfo.imagePositionPatientString(sliceIdx);
            itk::EncapsulateMetaData<std::string>(*sliceDict, "0020|0032", imagePositionPatient);

            // The relative location of this slice from the first one.
            std::stringstream sstr;
            sstr.str("");
            sstr << std::fixed << std::setprecision(1) << sliceLocation;
            itk::EncapsulateMetaData<std::string>(*sliceDict, "0020|1041",  sstr.str());
            sliceLocation += seriesInfo.imageSliceSpacing();

            sstr.str("");
            sstr << instanceNumber;
            itk::EncapsulateMetaData<std::string>(*sliceDict, "0020|0013", sstr.str());
            ++instanceNumber;

            LOG4CPLUS_TRACE(logger_, "*** Image " << imageIdx << " slice " << sliceIdx << " ***");
            LOG4CPLUS_TRACE(logger_, DumpDicomMetaDataDictionary(*sliceDict));
            dictArray.push_back(sliceDict);
        }
    }
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
