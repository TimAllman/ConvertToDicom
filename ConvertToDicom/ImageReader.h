//
//  FileReader.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-25.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#ifndef __ConvertToDicom__ImageReader__
#define __ConvertToDicom__ImageReader__

#include "Typedefs.h"

#include <log4cplus/logger.h>

#include <vector>

/**
 * Reads an image on disk, creating a std::vector of slices
 */
class ImageReader
{
public:
    /// Return type for ReadImage
    typedef std::vector<Image2DType::Pointer> ImageVector;

    /**
     * Default constructor.
     */
    explicit ImageReader();

    /**
     * Read an image (2D or 3D) on disk.
     * @param name The name of the file. May be relative or absolute path name.
     * @return An ImageReader::ImageVector of the image slices.
     */
    ImageVector ReadImage(const std::string& name);

private:
    log4cplus::Logger logger_;
};

#endif /* defined(__ConvertToDicom__FileReader__) */
