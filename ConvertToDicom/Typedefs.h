/*
 * File:   Typedefs.h
 * Author: tim
 *
 * Created on June 29, 2013, 10:07 AM
 */

#ifndef TYPEDEFS_H
#define	TYPEDEFS_H

#include <itkImage.h>

typedef unsigned short InternalPixelType;

typedef itk::Image<InternalPixelType, 2u> Image2DType;
typedef itk::Image<InternalPixelType, 3u> Image3DType;

#endif	/* TYPEDEFS_H */

