//
//  ImageReader.cpp
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-27.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#include "Typedefs.h"
#include "ImageReader.h"

#include <itkImage.h>
#include <itkImageIOBase.h>
#include <itkImageFileReader.h>
#include <itkExtractImageFilter.h>


ImageReader::ImageVector ImageReader::ReadImage(const std::string& fileName)
{
    itk::ImageIOBase::Pointer imageIO =
        itk::ImageIOFactory::CreateImageIO(fileName.c_str(), itk::ImageIOFactory::ReadMode);

    // If
    if (imageIO.IsNull())
    {
        std::cout << "Image not created from file: " << fileName << "\n";
        return ImageVector();
    };


    imageIO->SetFileName(fileName);
    imageIO->ReadImageInformation();

    //std::cout << "Image file type: " << imageIO->GetFileTypeAsString(imageIO->GetFileType()) << "\n";

    typedef itk::ImageIOBase::IOComponentType ScalarPixelType;
    //const ScalarPixelType pixelType = imageIO->GetComponentType();
    //std::cout << "Pixel Type is " << imageIO->GetComponentTypeAsString(pixelType) << "\n";

    const size_t numDimensions =  imageIO->GetNumberOfDimensions();
    //std::cout << "numDimensions: " << numDimensions << "\n"; // '2'

    //std::cout << "component size: " << imageIO->GetComponentSize() << "\n"; // '8'
    //std::cout << "pixel type (string): " << imageIO->GetPixelTypeAsString(imageIO->GetPixelType()) << "\n";
    //std::cout << "pixel type: " << imageIO->GetPixelType() << "\n"; // '5'

    //    std::cout << "dimensions: ";
    //    for (unsigned idx = 0; idx < numDimensions; ++idx)
    //        std::cout << imageIO->GetDimensions(idx) << ", ";
    //    std::cout << std::endl;



    ImageVector images;

    if (numDimensions == 2)
    {
        typedef itk::ImageFileReader<Image2DType> ReaderType;
        ReaderType::Pointer reader = ReaderType::New();

        reader->SetFileName(fileName);
        reader->Update();
        Image2DType::Pointer image = reader->GetOutput();

        images.push_back(image);
    }
    else
    {
        typedef itk::ImageFileReader<Image3DType> ReaderType;
        ReaderType::Pointer reader = ReaderType::New();

        reader->SetFileName(fileName);
        reader->Update();
        Image3DType::Pointer image = reader->GetOutput();

        Image3DType::RegionType inputRegion = image->GetLargestPossibleRegion();
        Image3DType::SizeType size = inputRegion.GetSize();
        unsigned numSlices = static_cast<unsigned>(size[2]);

        for (unsigned sliceIdx = 0; sliceIdx < numSlices; ++sliceIdx)
        {
            // Generate the regiion that we want
            Image3DType::SizeType sliceSize = size;
            sliceSize[2] = 0;
            Image3DType::IndexType sliceStart = inputRegion.GetIndex();
            sliceStart[2] = sliceIdx;
            Image3DType::RegionType sliceRegion;
            sliceRegion.SetIndex(sliceStart);
            sliceRegion.SetSize(sliceSize);

            // Create and set up the filter to extract a slice
            typedef itk::ExtractImageFilter<Image3DType, Image2DType> ExtractFiltertype;
            ExtractFiltertype::Pointer filter = ExtractFiltertype::New();
            filter->SetInput(image);
            filter->SetExtractionRegion(sliceRegion);
            filter->SetDirectionCollapseToIdentity();

            // Get the result
            Image2DType::Pointer slice = filter->GetOutput();
            filter->Update();
            images.push_back(slice);
        }
    }

    return images;
}

