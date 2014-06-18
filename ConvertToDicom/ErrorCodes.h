//
//  ErrorCodes.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-06-17.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#ifndef ConvertToDicom_ErrorCodes_h
#define ConvertToDicom_ErrorCodes_h

typedef enum : unsigned
{
    SUCCESS,                  // All is well.
    ERROR,                    // General error.
    ERROR_FILE_NOT_FOUND,     // File(s) not found.
    ERROR_READING_FILE,       // Problem reading existing file(s).
    ERROR_WRITING_FILE,       // Problem creating or writing file(s).
    ERROR_CREATING_DIRECTORY, // Problem creating a directory.
    ERROR_DIRECTORY_NOT_EMPTY // Directory contains files when it shouldn't.
} ErrorCode;

#endif
