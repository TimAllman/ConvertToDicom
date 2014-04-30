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
#include <itkImageFileWriter.h>
#include <itkNumericSeriesFileNames.h>
#include <itkGDCMImageIO.h>
#include <itkMetaDataDictionary.h>
#include <itkMetaDataObject.h>
#include <itkCastImageFilter.h>

#include <itksys/SystemTools.hxx>

#include <gdcmUIDGenerator.h>

#include "DumpMetaDataDictionary.h"

#include <iostream>
#include <sstream>


DicomSeriesWriter::DicomSeriesWriter(std::vector<Image2DType::Pointer>& images,
                                     std::string outputDirectoryName, unsigned seriesNumber)
: images(images), outputDirectory(outputDirectoryName), seriesNumber(seriesNumber)
{
}

void DicomSeriesWriter::WriteFileSeries()
{
    // Set up the new metadata dictionary array
    // This is based upon the example on the ITK examples wiki
    // http://www.itk.org/Wiki/ITK/Examples/DICOM/ResampleDICOM
    //

    Image2DType::Pointer firstImage = images[0];
    std::cout << DumpMetaDataDictionary(firstImage->GetMetaDataDictionary());

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

    // TODO allow user to set this
    // Set the orientation attribute from the image direction info.
    Image2DType::DirectionType dir = firstImage->GetDirection();
    value << dir[0][0] << "\\" << dir[0][1] << "\\" << dir[0][2] << "\\"
    << dir[1][0] << "\\" << dir[1][1] << "\\" << dir[1][2];
    std::string imageOrientationPatient = value.str();

    unsigned numSlices = static_cast<unsigned>(images.size());
    //double sliceThickness = firstImage->GetSpacing()[2];
    double sliceThickness = 1.0;
    value.str("");
    value << sliceThickness;
    std::string strSliceThickness = value.str();

    // define the filenames generator type and instance
    typedef itk::NumericSeriesFileNames NameGeneratorType;
    NameGeneratorType::Pointer nameGenerator = NameGeneratorType::New();
    value.str("");
    value << outputDirectory << "/IM-" << seriesNumber << "-%04d.dcm";
    nameGenerator->SetSeriesFormat(value.str());
    nameGenerator->SetStartIndex(1);
    nameGenerator->SetEndIndex(numSlices);
    fileNames = nameGenerator->GetFileNames();

    // loop through the slices, setting the new series and frame of reference UIDs
    // as well as slice specific information
    for (unsigned idx = 0; idx < numSlices; ++idx)
    {
        Image2DType::Pointer curSlice = images[idx];

        // Get a pointer to this dictionary.
        MetaDataDictionaryType dict = curSlice->GetMetaDataDictionary();

        // Modality
        // TODO: This should be obtained from the incoming image or the command line.
        itk::EncapsulateMetaData<std::string>(dict, "0008|0060", modality);

        // ImageOrientationPatient
        itk::EncapsulateMetaData<std::string>(dict, "0020|0037", imageOrientationPatient);

        // Date of creation of these images
        itk::EncapsulateMetaData<std::string>(dict, "0008|0023", contentDate);
        itk::EncapsulateMetaData<std::string>(dict, "0008|0033", contentTime);

        // These are processed images
        itk::EncapsulateMetaData<std::string>(dict, "0008|0008", imageType);
        itk::EncapsulateMetaData<std::string>(dict, "0008|0064", conversion);

        // Set the UID's for the series, SOP  and frame of reference
        itk::EncapsulateMetaData<std::string>(dict, "0020|000e", seriesUID);
        itk::EncapsulateMetaData<std::string>(dict, "0020|0052", frameOfReferenceUID);

        gdcm::UIDGenerator sopuid;
        std::string sopInstanceUID = sopuid.Generate();
        itk::EncapsulateMetaData<std::string>(dict, "0008|0018", sopInstanceUID);
        itk::EncapsulateMetaData<std::string>(dict, "0002|0003", sopInstanceUID);

        // Image Number, starting at 1
        value.str("");
        value << idx + 1;
        itk::EncapsulateMetaData<std::string>(dict, "0020|0013", value.str());

        // Slice thickness
        itk::EncapsulateMetaData<std::string>(dict, "0018|0050", strSliceThickness);

        // Spacing Between Slices
        itk::EncapsulateMetaData<std::string>(dict, "0018|0088", strSliceThickness);

        // Series Description - Append new description to current series description
        std::string oldSeriesDesc;
        itk::ExposeMetaData<std::string>(dict, "0008|103e", oldSeriesDesc);
        value.str("");
        value << oldSeriesDesc << ": Converted to DICOM";
        // This is a long string and there is a 64 character limit in the standard
        std::string::size_type lengthOfDesc = value.str().length();
        std::string seriesDesc(value.str(), 0, lengthOfDesc > 64 ? 64 : lengthOfDesc);
        itk::EncapsulateMetaData<std::string>(dict, "0008|103e", seriesDesc);

        // Series Number
        value.str("");
        value << seriesNumber;
        itk::EncapsulateMetaData<std::string>(dict, "0020|0011", value.str());

        // Derivation Description - How this image was derived
        value.str("");
        value << "Converted to DICOM using " << ITK_SOURCE_VERSION;
        // Deal with a 1024 character max length.
        lengthOfDesc = value.str().length();
        std::string derivationDesc(value.str(), 0, lengthOfDesc > 1024 ? 1024 : lengthOfDesc);
        itk::EncapsulateMetaData<std::string>(dict, "0008|2111", derivationDesc);

        // Set the regions to encompass the whole image
        curSlice->SetRegions(curSlice->GetLargestPossibleRegion());

        //
        // create a Dicom series writer
        itk::GDCMImageIO::Pointer dicomIo = itk::GDCMImageIO::New();
        dicomIo->SetPixelType(itk::ImageIOBase::SCALAR);

        itk::ImageFileWriter<Image2DType>::Pointer writer = itk::ImageFileWriter<Image2DType>::New();
        writer->SetImageIO(dicomIo);
        writer->SetFileName(fileNames[idx]);
        writer->SetMetaDataDictionary(dict);
        writer->SetInput(curSlice);


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
}

