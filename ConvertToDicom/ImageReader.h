//
//  FileReader.h
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

#ifndef __ConvertToDicom__ImageReader__
#define __ConvertToDicom__ImageReader__

#include "Typedefs.h"

#include <log4cplus/logger.h>

#include <vector>

/**
 * Reads an image on disk, creating a std::vector of slices.
 */
class ImageReader
{
public:
    /** Used as a return type for ReadImage */
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
