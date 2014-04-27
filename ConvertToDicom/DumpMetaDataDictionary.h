/*
 * File:   DumpMetaDataDictionary.h
 * Author: tim
 *
 * Created on December 21, 2012, 9:45 AM
 */

#ifndef DUMPMETADATADICTIONARY_H
#define	DUMPMETADATADICTIONARY_H

#include <itkMetaDataDictionary.h>

typedef itk::MetaDataDictionary MetaDataDictionaryType;

std::string DumpDicomMetaDataDictionary(const MetaDataDictionaryType& dict);

std::string DumpMetaDataDictionary(const MetaDataDictionaryType& dict);

#endif	/* DUMPMETADATADICTIONARY_H */

