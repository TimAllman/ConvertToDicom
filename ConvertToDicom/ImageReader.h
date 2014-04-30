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

#include <vector>

class ImageReader
{
public:
    typedef std::vector<Image2DType::Pointer> ImageVector;
    
    ImageReader();

    ~ImageReader();

    ImageVector ReadImage(const std::string& name);

private:

};

#endif /* defined(__ConvertToDicom__FileReader__) */
