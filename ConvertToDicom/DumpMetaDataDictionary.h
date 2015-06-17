/*
 * File:   DumpMetaDataDictionary.h
 * Author: tim
 *
 * Created on December 21, 2012, 9:45 AM
 */

#ifndef DUMPMETADATADICTIONARY_H
#define	DUMPMETADATADICTIONARY_H

#include <itkMetaDataDictionary.h>

/**
 * Generate a std::string representation of a itk::MetaDataDictionary. Useful for debugging.
 * @param dict Reference to the itk::MetaDataDictionary.
 *
 * @return std::string representation of the itk::MetaDataDictionary.
 */
std::string DumpMetaDataDictionary(const itk::MetaDataDictionary& dict);
 
/**
 * Generate a std::string representation of a itk::MetaDataDictionary tailored for DICOM.
 * Useful for debugging.
 * @param dict Reference to the itk::MetaDataDictionary.
 *
 * @return std::string representation of the itk::MetaDataDictionary.
 */
std::string DumpDicomMetaDataDictionary(const itk::MetaDataDictionary& dict);

#endif	/* DUMPMETADATADICTIONARY_H */

