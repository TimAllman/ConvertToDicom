//
//  FileReader.cpp
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-27.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#include "FileReader.h"

#include <itkImageFileReader.h>
#include <itkNrrdImageIOFactory.h>
#include <itkJPEGImageIOFactory.h>
#include <itkBioRadImageIOFactory.h>
#include <itkBMPImageIOFactory.h>
#include <itkGDCMImageIOFactory.h>
#include <itkGE4ImageIOFactory.h>
#include <itkGE5ImageIOFactory.h>
#include <itkGEAdwImageIOFactory.h>
#include <itkGiplImageIOFactory.h>
#include <itkHDF5ImageIOFactory.h>
#include <itkImageIOFactory.h>
#include <itkJPEGImageIOFactory.h>
#include <itkLSMImageIOFactory.h>
#include <itkMetaImageIOFactory.h>
#include <itkMRCImageIOFactory.h>
#include <itkNiftiImageIOFactory.h>
#include <itkNrrdImageIOFactory.h>
#include <itkPNGImageIOFactory.h>
#include <itkSiemensVisionImageIOFactory.h>
#include <itkStimulateImageIOFactory.h>
#include <itkTIFFImageIOFactory.h>
#include <itkVTKImageIOFactory.h>


FileReader::FileReader()
{
    itk::BioRadImageIOFactory::RegisterOneFactory();
    itk::BMPImageIOFactory::RegisterOneFactory();
    itk::GDCMImageIOFactory::RegisterOneFactory();
    itk::GE4ImageIOFactory::RegisterOneFactory();
    itk::GE5ImageIOFactory::RegisterOneFactory();
    itk::GEAdwImageIOFactory::RegisterOneFactory();
    itk::GiplImageIOFactory::RegisterOneFactory();
    itk::HDF5ImageIOFactory::RegisterOneFactory();
    itk::JPEGImageIOFactory::RegisterOneFactory();
    itk::LSMImageIOFactory::RegisterOneFactory();
    itk::MetaImageIOFactory::RegisterOneFactory();
    itk::MRCImageIOFactory::RegisterOneFactory();
    itk::NiftiImageIOFactory::RegisterOneFactory();
    itk::NrrdImageIOFactory::RegisterOneFactory();
    itk::PNGImageIOFactory::RegisterOneFactory();
    itk::SiemensVisionImageIOFactory::RegisterOneFactory();
    itk::StimulateImageIOFactory::RegisterOneFactory();
    itk::TIFFImageIOFactory::RegisterOneFactory();
    itk::VTKImageIOFactory::RegisterOneFactory();
}

FileReader::~FileReader()
{
    //itk::ObjectFactoryBase::UnRegisterAllFactories();
}

Image2DType::Pointer FileReader::ReadImage(const std::string& name)
{
    typedef itk::ImageFileReader<Image2DType> ReaderType;
    ReaderType::Pointer reader = ReaderType::New();

    reader->SetFileName(name);
    reader->Update();
    Image2DType::Pointer image = reader->GetOutput();

    itk::ImageIOBase::Pointer imageIO = reader->GetImageIO();

    typedef itk::ImageIOBase::IOComponentType ScalarPixelType;
    const ScalarPixelType pixelType = imageIO->GetComponentType();
    std::cout << "Pixel Type is " << imageIO->GetComponentTypeAsString(pixelType) << std::endl;

    const size_t numDimensions =  imageIO->GetNumberOfDimensions();
    std::cout << "numDimensions: " << numDimensions << std::endl; // '2'

    std::cout << "component size: " << imageIO->GetComponentSize() << std::endl; // '8'
    std::cout << "pixel type (string): " << imageIO->GetPixelTypeAsString(imageIO->GetPixelType()) << std::endl;
    std::cout << "pixel type: " << imageIO->GetPixelType() << std::endl; // '5'

    return image;
}

