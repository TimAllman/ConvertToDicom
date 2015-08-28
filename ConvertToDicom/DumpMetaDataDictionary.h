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

