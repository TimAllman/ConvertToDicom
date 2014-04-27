//
//  DicomWriter.h
//  BsdRegistration2
//
//  Created by Tim Allman on 2012-11-26.
//  Copyright (c) 2012 Tim Allman. All rights reserved.
//

#ifndef __BsdRegistration2__DicomWriter__
#define __BsdRegistration2__DicomWriter__

#include <itkVersion.h>
#include <itkImage.h>
#include <itkImageSeriesWriter.h>
#include <itkNumericSeriesFileNames.h>
#include <itkGDCMImageIO.h>
#include <itkMetaDataDictionary.h>
#include <itkCastImageFilter.h>
#include <gdcmUIDGenerator.h>

#include "BsdRegistrationDefs.h>
#include "DumpDicomMetaDataDictionaryx.h>
#include "CopyMetaDataDictionary.h>

#include <iostream>
#include <sstream>

template <class TPixel>
class DicomSeriesWriter3D
{
  public:
    typedef unsigned short DicomPixelType;
    typedef itk::Image<TPixel, 3u > InputImageType;
    typedef itk::Image<DicomPixelType, 3u > DicomImage3dType;
    typedef itk::Image<DicomPixelType, 2u > DicomImage2dType;
    typedef itk::ImageSeriesWriter<InputImageType, DicomImage2dType> WriterType;

    DicomSeriesWriter3D(const typename InputImageType::Pointer inputImage,
        std::string outputDirectoryName, unsigned seriesNumber,
        const MetaDataDictionaryArrayType* dicomDictionaryArray)
    {
        // Set up the new metadata dictionary array
        // This is based upon the example on the ITK examples wiki
        // http://www.itk.org/Wiki/ITK/Examples/DICOM/ResampleDICOM
        //
        // Copy over the metadata dictionary array and create a local copy
        MetaDataDictionaryArrayType* dictArray;
        CopyMetaDataDictionaryArray(dicomDictionaryArray, dictArray);
        //DumpDicomMetaDataDictionaryArray(dictArray);
        // To keep the new series in the same study as the original we need
        // to keep the same study UID. But we need new series and frame of
        // reference UID's.
        gdcm::UIDGenerator suid;
        std::string seriesUID = suid.Generate();
        gdcm::UIDGenerator fuid;
        std::string frameOfReferenceUID = fuid.Generate();

        // These are processed images so we show that.
        std::string modality = "MR";
        std::string imageType = "DERIVED";
        std::string conversion = "WSD";
        std::string contentDate = itksys::SystemTools::GetCurrentDateTime("%Y%m%d");
        std::string contentTime = itksys::SystemTools::GetCurrentDateTime("%H%M%S");

        // use for creating strings below.
        std::ostringstream value;

        // Set the orientation attribute from the image direction info.
        Image3DType::DirectionType dir = inputImage->GetDirection();
        value << dir[0][0] << "\\" << dir[0][1] << "\\" << dir[0][2] << "\\"
            << dir[1][0] << "\\" << dir[1][1] << "\\" << dir[1][2];
        std::string imageOrientationPatient = value.str();

        unsigned numSlices = inputImage->GetLargestPossibleRegion().GetSize(2);
        double sliceThickness = inputImage->GetSpacing()[2];
        value.str("");
        value << sliceThickness;
        std::string strSliceThickness = value.str();

        // loop through the slices, setting the new series and frame of reference UIDs
        // as well as slice specific information
        for (unsigned idx = 0; idx < numSlices; ++idx)
        {
            // Get a pointer to this dictionary.
            MetaDataDictionaryType* dict = (*dictArray)[idx];

            // Modality
            // TODO: This should be obtained from the incoming image or the command line.
            itk::EncapsulateMetaData<std::string>(*dict, "0008|0060", modality);

            // ImageOrientationPatient
            itk::EncapsulateMetaData<std::string>(*dict, "0020|0037", imageOrientationPatient);

            // Date of creation of these images
            itk::EncapsulateMetaData<std::string> (*dict, "0008|0023", contentDate);
            itk::EncapsulateMetaData<std::string> (*dict, "0008|0033", contentTime);

            // These are processed images
            itk::EncapsulateMetaData<std::string> (*dict, "0008|0008", imageType);
            itk::EncapsulateMetaData<std::string> (*dict, "0008|0064", conversion);

            // Set the UID's for the series, SOP  and frame of reference
            itk::EncapsulateMetaData<std::string>(*dict, "0020|000e", seriesUID);
            itk::EncapsulateMetaData<std::string>(*dict, "0020|0052", frameOfReferenceUID);

            gdcm::UIDGenerator sopuid;
            std::string sopInstanceUID = sopuid.Generate();
            itk::EncapsulateMetaData<std::string>(*dict, "0008|0018", sopInstanceUID);
            itk::EncapsulateMetaData<std::string>(*dict, "0002|0003", sopInstanceUID);

            // Image Number, starting at 1
            value.str("");
            value << idx + 1;
            itk::EncapsulateMetaData<std::string>(*dict, "0020|0013", value.str());

            // Slice thickness
            itk::EncapsulateMetaData<std::string>(*dict, "0018|0050", strSliceThickness);

            // Spacing Between Slices
            itk::EncapsulateMetaData<std::string>(*dict, "0018|0088", strSliceThickness);

            // Series Description - Append new description to current series description
            std::string oldSeriesDesc;
            itk::ExposeMetaData<std::string>(*dict, "0008|103e", oldSeriesDesc);
            value.str("");
            value << oldSeriesDesc << ": Registered";
            // This is an long string and there is a 64 character limit in the
            // standard
            std::string::size_type lengthOfDesc = value.str().length();
            std::string seriesDesc(value.str(), 0, lengthOfDesc > 64 ? 64 : lengthOfDesc);
            itk::EncapsulateMetaData<std::string>(*dict, "0008|103e", seriesDesc);

            // Series Number
            value.str("");
            value << seriesNumber;
            itk::EncapsulateMetaData<std::string>(*dict, "0020|0011", value.str());

            // Derivation Description - How this image was derived
            value.str("");
            value << "Converted to DICOM from NRRD using " << ITK_SOURCE_VERSION;
            // Deal with a 1024 character max length.
            lengthOfDesc = value.str().length();
            std::string derivationDesc(value.str(), 0, lengthOfDesc > 1024 ? 1024 : lengthOfDesc);
            itk::EncapsulateMetaData<std::string>(*dict, "0008|2111", derivationDesc);
         }

        // Set the regions to encompass the whole image
        inputImage->SetRegions(inputImage->GetLargestPossibleRegion());

        // define the filenames generator type and instance
        typedef itk::NumericSeriesFileNames NameGeneratorType;
        NameGeneratorType::Pointer nameGenerator = NameGeneratorType::New();
        value.str("");
        value << outputDirectoryName << "/IM-" << seriesNumber << "-%04d.dcm";
        nameGenerator->SetSeriesFormat(value.str());
        nameGenerator->SetStartIndex(1);
        nameGenerator->SetEndIndex(numSlices);

        //
        // create a Dicom series writer
        itk::GDCMImageIO::Pointer dicomIo = itk::GDCMImageIO::New();
        dicomIo->KeepOriginalUIDOn();

        writer = WriterType::New();
        writer->SetImageIO(dicomIo);
        writer->SetFileNames(nameGenerator->GetFileNames());
        writer->SetMetaDataDictionaryArray(dictArray);
        writer->SetInput(inputImage);


        // Add some things to the default dictionary
//        itk::MetaDataDictionary& dictionary = dicomIo->GetMetaDataDictionary();
//        dictionary = dicomDictionary;
//        itk::EncapsulateMetaData<std::string > (dictionary, "0008|0060", std::string("MR"));
//        itk::EncapsulateMetaData<std::string > (dictionary, "0010|0010", std::string("Registered"));
//        itk::EncapsulateMetaData<std::string > (dictionary, "0010|0020", std::string("Patient's ID"));
//        itk::EncapsulateMetaData<std::string > (dictionary, "0032|4000", std::string("Converted by ITK"));
//
//        writer->SetMetaDataDictionaryArray(dictionary);
//
        //DumpDicomMetaDataDictionaryArray(dictArray);
    }

    void WriteFileSeries()
    {

        try
        {
            writer->Update();
        }
        catch (itk::ExceptionObject& ex)
        {
            std::cerr << "ExceptionObject caught !" << std::endl;
            std::cerr << ex << std::endl;
        }
    }

  private:
    typename WriterType::Pointer writer;
    const typename InputImageType::Pointer image;

};

#endif /* defined(__BsdRegistration2__DicomWriter__) */
