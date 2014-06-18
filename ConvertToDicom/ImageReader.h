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

class ImageReader
{
public:
    typedef std::vector<Image2DType::Pointer> ImageVector;
    
    ImageVector ReadImage(const std::string& name);

private:
    log4cplus::Logger logger_;
};

#endif /* defined(__ConvertToDicom__FileReader__) */
