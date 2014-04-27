//
//  FileReader.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-25.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#ifndef __ConvertToDicom__FileReader__
#define __ConvertToDicom__FileReader__

#include "Typedefs.h"

class FileReader
{
public:
    FileReader();

    ~FileReader();

    Image2DType::Pointer ReadImage(const std::string& name);

private:

};

#endif /* defined(__ConvertToDicom__FileReader__) */
