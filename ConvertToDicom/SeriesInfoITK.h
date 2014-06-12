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

@class SeriesInfo;

class SeriesInfoITK
{
public:
    SeriesInfoITK(const SeriesInfo* info);

    itk::MetaDataDictionary dictionary() const;

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
    unsigned numberOfImages() const;
    unsigned slicesPerImage() const;
    float timeIncrement() const;
    const std::vector<std::string>& acqTimes() const;

private:
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
};

#endif /* defined(__ConvertToDicom__SeriesInfoITK__) */
