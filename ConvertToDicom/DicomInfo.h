//
//  DicomInfo.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-05-26.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#ifndef __ConvertToDicom__DicomInfo__
#define __ConvertToDicom__DicomInfo__

#include <string>

//#include "SeriesInfo.h"

@class SeriesInfo;

class DicomInfo
{
public:
    DicomInfo(const SeriesInfo* info);

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
    std::string imageSliceThickness() const;
    std::string imagePatientPosition() const;
    std::string imagePatientOrientation() const;

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
    std::string imageSliceThickness_;
    std::string imagePatientPosition_;
    std::string imagePatientOrientation_;
};

#endif /* defined(__ConvertToDicom__DicomInfo__) */
