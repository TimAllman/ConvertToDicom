/*
 * File:   DumpMetaDataDictionary.h
 * Author: tim
*/

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

#include <sstream>

#include "Typedefs.h"
#include "DumpMetaDataDictionary.h"

#include <itkGDCMImageIO.h>
#include <itkMetaDataObject.h>

std::string DumpDicomMetaDataDictionary(const itk::MetaDataDictionary& dict)
{
    typedef itk::MetaDataObject<std::string> MetaDataStringType;

    std::ostringstream stream;

    stream << "DumpDicomMetaDataDictionary" << std::endl
    <<"***************************" << std::endl;

    for (itk::MetaDataDictionary::ConstIterator iter = dict.Begin(); iter != dict.End(); ++iter)
    {
        itk::MetaDataObjectBase::Pointer entry = iter->second;
        MetaDataStringType::Pointer entryValue = dynamic_cast<MetaDataStringType*>(entry.GetPointer());
        if (entryValue)
        {
            std::string key = iter->first;
            std::string label;
            bool found = itk::GDCMImageIO::GetLabelFromTag(key, label);
            if (found)
            {
                std::string tagValue = entryValue->GetMetaDataObjectValue();
                stream << "(" << key << ")" << label << " = " << tagValue << std::endl;
            }
            else
            {
                stream << "label (" << label << ") for key " << key << " not found." << std::endl;
            }
        }
        else
        {
            stream << "Non string entry: " << std::endl;
            entry->Print(stream);
        }
    }

    return stream.str();
}

std::string DumpMetaDataDictionary(const itk::MetaDataDictionary& dict)
{
    typedef itk::MetaDataObject<std::string> MetaDataStringType;

    std::ostringstream stream;

    stream << "DumpMetaDataDictionary" << "\n"
           <<"***************************" << "\n";

    // Dump the keys alone
    stream << " ** Keys **\n";
    std::vector<std::string> keys = dict.GetKeys();
    for (std::vector<std::string>::const_iterator iter = keys.begin(); iter != keys.end(); ++iter)
    {
        stream << "  " << *iter << "\n";
    }
    
    for (itk::MetaDataDictionary::ConstIterator iter = dict.Begin(); iter != dict.End(); ++iter)
    {
        itk::MetaDataObjectBase::Pointer entry = iter->second;
        MetaDataStringType::Pointer entryValue = dynamic_cast<MetaDataStringType*>(entry.GetPointer());

        // Print the strings
        if (entryValue)
        {
            std::string key = iter->first;
            std::string value = entryValue->GetMetaDataObjectValue();
            stream << key << " = " << value << "\n";
        }
        else
        {
            stream << "Non string entry: \n";
            entry->Print(stream);
        }
    }

    stream << std::endl;

    return stream.str();
}

