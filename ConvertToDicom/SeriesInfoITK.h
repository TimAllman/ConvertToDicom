//
//  SeriesInfoITK.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-05-26.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#ifndef __ConvertToDicom__SeriesInfoITK__
#define __ConvertToDicom__SeriesInfoITK__

#include <string>

#include <itkMetaDataDictionary.h>

#include <log4cplus/logger.h>

@class SeriesInfo;

/**
 * C++ class that contains the same information as SeriesInfo.
 * Provides a convenient transition from ObjC to C++.
 * Most of the members are not documented as their names are self explanatory.
 */
class SeriesInfoITK
{
public:
    /**
     * Constructor
     * @param info The Objective-C instance we wish to copy.
     */
    explicit SeriesInfoITK(const SeriesInfo* info);

    std::string patientsName() const;
    std::string patientsID() const;
    std::string patientsDOB() const;
    std::string patientsSex() const;
    std::string studyDescription() const;
    std::string studyID() const;
    std::string studyModality() const;
    std::string studyDate() const;
    std::string studyTime() const;
    std::string studyStudyUID() const;
    std::string seriesNumber() const;
    std::string seriesDescription() const;
    float imageSliceSpacing() const;
    float imagePatientPositionX() const;
    float imagePatientPositionY() const;
    float imagePatientPositionZ() const;
    std::string imagePatientPosition() const;
    std::string imagePatientOrientation() const;

    std::string inputDir() const;
    std::string outputDir() const;
    unsigned inputNumberOfImages() const;
    unsigned slicesPerImage() const;
    unsigned numberOfImages() const;

    /**
     * Get the increment in time between images in time series.
     * @return The increment in time between images in time series.
     */
    float timeIncrement() const;

    /**
     * Get the list of acquisition times for the images in time series.
     * @return The list of acquisition times for the images in time series.
     */
    const std::vector<std::string>& acqTimes() const;

    /**
     * Get the parameters as a DICOM dictionary.
     * @return The dictionary.
     */
    itk::MetaDataDictionary dictionary() const;

private:
    /**
     * Load the parameters copied from the SeriesInfo instance into a DICOM dictionary.
     * @return The loaded dictionary.
     */
    itk::MetaDataDictionary makeDictionary() const;

    std::string patientsName_;
    std::string patientsID_;
    std::string patientsDOB_;
    std::string patientsSex_;
    std::string studyDescription_;
    std::string studyID_;
    std::string studyModality_;
    std::string studyDate_;
    std::string studyTime_;
    std::string studyStudyUID_;
    std::string seriesNumber_;
    std::string seriesDescription_;
    float imageSliceSpacing_;
    float imagePatientPositionX_;
    float imagePatientPositionY_;
    float imagePatientPositionZ_;
    std::string imagePatientPosition_;
    std::string imagePatientOrientation_;

    std::string inputDir_;
    std::string outputDir_;
    unsigned numberOfImages_;
    unsigned slicesPerImage_;
    float timeIncrement_;
    std::vector<std::string> acqTimes_;

    mutable itk::MetaDataDictionary dict;

    log4cplus::Logger logger_;
};

#endif /* defined(__ConvertToDicom__SeriesInfoITK__) */
