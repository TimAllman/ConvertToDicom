//
//  ImageReader.cpp
//  ConvertToDicom
//

/* ConvertToDicom converts a series of images to DICOM format from any format recognized
 * by ITK (http://www.itk.org).
 * Copyright (C) 2014  Tim Allman
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "Typedefs.h"
#include "ImageReader.h"
#include "LoggerName.h"

#include <itkImage.h>
#include <itkImageIOBase.h>
#include <itkImageFileReader.h>
#include <itkExtractImageFilter.h>

#include <log4cplus/loggingmacros.h>

ImageReader::ImageReader()
    :logger_(log4cplus::Logger::getInstance(std::string(LOGGER_NAME) + ".ReadImage"))
{
}

ImageReader::ImageVector ImageReader::ReadImage(const std::string& fileName)
{
    LOG4CPLUS_TRACE(logger_, "Enter");

    itk::ImageIOBase::Pointer imageIO =
        itk::ImageIOFactory::CreateImageIO(fileName.c_str(), itk::ImageIOFactory::ReadMode);

    // If
    if (imageIO.IsNull())
    {
        LOG4CPLUS_ERROR(logger_, "Image not created from file: " << fileName);
        return ImageVector();
    };


    imageIO->SetFileName(fileName);
    imageIO->ReadImageInformation();

    LOG4CPLUS_DEBUG(logger_, "Image file type: " << imageIO->GetFileTypeAsString(imageIO->GetFileType()));

    typedef itk::ImageIOBase::IOComponentType ScalarPixelType;
    const ScalarPixelType pixelType = imageIO->GetComponentType();
    LOG4CPLUS_DEBUG(logger_, "Pixel Type is " << imageIO->GetComponentTypeAsString(pixelType));

    const size_t numDimensions =  imageIO->GetNumberOfDimensions();
    LOG4CPLUS_DEBUG(logger_, "numDimensions: " << numDimensions);

    LOG4CPLUS_DEBUG(logger_, "component size: " << imageIO->GetComponentSize());
    LOG4CPLUS_DEBUG(logger_, "pixel type (string): "
                    << imageIO->GetPixelTypeAsString(imageIO->GetPixelType()));
    LOG4CPLUS_DEBUG(logger_, "pixel type: " << imageIO->GetPixelType());

    std::stringstream str;

    str << "dimensions: ";
    for (unsigned idx = 0; idx < numDimensions; ++idx)
        str << imageIO->GetDimensions(idx) << ", ";

    LOG4CPLUS_DEBUG(logger_, str.str());

    ImageVector images;

    if (numDimensions == 2)
    {
        typedef itk::ImageFileReader<Image2DType> ReaderType;
        ReaderType::Pointer reader = ReaderType::New();

        reader->SetFileName(fileName);
        Image2DType::Pointer image = reader->GetOutput();

        try
        {
            reader->Update();
        }
        catch (itk::ImageFileReaderException& ex)
        {
            LOG4CPLUS_ERROR(logger_, "Exception caught reading image. " << ex.what());
        }

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
            try
            {
                filter->Update();
            }
            catch (itk::ImageFileReaderException& ex)
            {
                LOG4CPLUS_ERROR(logger_, "Exception caught reading slice " << sliceIdx << ". " << ex.what());
                images.clear();
                return images;
            }

            images.push_back(slice);
        }
    }

    return images;
}

