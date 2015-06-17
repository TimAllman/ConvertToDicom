//
//  ErrorCodes.c
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-12-10.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#include "ErrorCodes.h"

const char* ErrorCodeAsString(ErrorCode code)
{
    switch (code)
    {
        case SUCCESS:
            return "Success";
            break;
        case ERROR:
            return "Error";
            break;
        case ERROR_FILE_NOT_FOUND:
            return "File not found";
            break;
        case ERROR_READING_FILE:
            return "Error reading file";
            break;
        case ERROR_WRITING_FILE:
            return "Error writing file";
            break;
        case ERROR_CREATING_DIRECTORY:
            return "Error creating directory";
            break;
        case ERROR_DIRECTORY_NOT_EMPTY:
            return "Directory not empty";
            break;
        default:
            return "Unknown ErrorCode value";
            break;
    };
}