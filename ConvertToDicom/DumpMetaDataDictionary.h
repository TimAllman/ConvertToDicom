/*
 * File:   DumpMetaDataDictionary.h
 * Author: tim
 *
 * Created on December 21, 2012, 9:45 AM
 */

#ifndef DUMPMETADATADICTIONARY_H
#define	DUMPMETADATADICTIONARY_H

#include <itkMetaDataDictionary.h>

std::string DumpDicomMetaDataDictionary(const itk::MetaDataDictionary& dict);

std::string DumpMetaDataDictionary(const itk::MetaDataDictionary& dict);

#endif	/* DUMPMETADATADICTIONARY_H */

