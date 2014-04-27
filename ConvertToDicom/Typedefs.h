/*
 * File:   Typedefs.h
 * Author: tim
 *
 * Created on June 29, 2013, 10:07 AM
 */

#ifndef TYPEDEFS_H
#define	TYPEDEFS_H

#include <itkImage.h>
#include <itkImageSeriesReader.h>
#include <itkImageSeriesWriter.h>
#include <itkNumericSeriesFileNames.h>
#include <itkGDCMImageIO.h>
#include <itkNrrdImageIO.h>
#include <itkMetaDataDictionary.h>
#include <itkDirectory.h>

typedef unsigned short PixelType;

typedef itk::Image<PixelType, 2u> Image2DType;
typedef itk::Image<PixelType, 3u> Image3DType;
//typedef itk::ImageSeriesReader<Image3DType> ReaderType;
//typedef itk::ImageSeriesWriter<Image3DType, Image2DType> WriterType;
//
//typedef itk::NumericSeriesFileNames NameGeneratorType;
//typedef ReaderType::DictionaryArrayType DictionaryArrayType;
//typedef ReaderType::DictionaryArrayRawPointer DictionaryArrayPointerType;

#endif	/* TYPEDEFS_H */

