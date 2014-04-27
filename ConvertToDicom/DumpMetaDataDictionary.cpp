/*
 * File:   DumpMetaDataDictionary.h
 * Author: tim
 *
 * Created on December 21, 2012, 9:45 AM
 */

#include <sstream>

#include "Typedefs.h"
#include "DumpMetaDataDictionary.h"

#include <itkGDCMImageIO.h>
#include <itkMetaDataObject.h>
//#include <itkImageSeriesReader.h>

std::string DumpDicomMetaDataDictionary(const MetaDataDictionaryType& dict)
{
    typedef itk::MetaDataObject<std::string> MetaDataStringType;

    std::ostringstream stream;

    stream << "DumpDicomMetaDataDictionary" << std::endl
    <<"***************************" << std::endl;

    for (MetaDataDictionaryType::ConstIterator iter = dict.Begin(); iter != dict.End(); ++iter)
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

std::string DumpMetaDataDictionary(const MetaDataDictionaryType& dict)
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
    
    for (MetaDataDictionaryType::ConstIterator iter = dict.Begin(); iter != dict.End(); ++iter)
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

/*
 std::string DumpDicomMetaDataDictionaryArray(const MetaDataDictionaryType::MetaDataDictionaryMapType& dict)
{
    std::string retVal;

    for (unsigned idx = 0; idx < dict.size(); idx++)
    {
        std::ostringstream stream;

        stream << std::endl << "****** MetaDataDictionary " << idx << " *******" << std::endl;
        retVal += stream.str();

        const itk::ImageSeriesReader<Image2DType>::DictionaryRawPointer pDict = (*dict)[idx];

        retVal += DumpDicomMetaDataDictionary(pDict);
        std::cout << retVal;
    }

    return retVal;
}
*/
