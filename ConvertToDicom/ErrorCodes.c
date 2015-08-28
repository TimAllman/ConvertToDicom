//
//  ErrorCodes.c
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