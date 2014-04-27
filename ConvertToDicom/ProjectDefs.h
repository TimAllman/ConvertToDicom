//
//  ProjectDefs.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-24.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#ifndef ConvertToDicom_ProjectDefs_h
#define ConvertToDicom_ProjectDefs_h

#include <itkImage.h>
#include <itkImageSeriesReader.h>
#include <itkImageSeriesWriter.h>

typedef unsigned short PixelType;

typedef itk::Image<PixelType, 2> Image2DType;
typedef itk::Image<PixelType, 3> Image3DType;
typedef itk::ImageSeriesReader<Image3DType> ReaderType;
typedef itk::ImageSeriesWriter<Image3DType, Image2DType> WriterType;

#endif
