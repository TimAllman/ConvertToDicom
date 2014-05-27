//
//  DicomInfo.mm
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-05-26.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#include "DicomInfo.h"
#include "SeriesInfo.h"

DicomInfo::DicomInfo(const SeriesInfo* info)
{
    patientsName_ = [info.patientsName UTF8String];
    patientsID_ = [info.patientsID UTF8String];

    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]initWithDateFormat:@"yyyyMMdd"
                                                           allowNaturalLanguage:NO];
    NSString* dob = [dateFormatter stringFromDate:info.patientsDOB];
    patientsDOB_ = [dob UTF8String];
    patientsSex_ = [info.patientsSex UTF8String];
    studyDescription_ = [info.studyDescription UTF8String];
    studyID_ = [info.studyID UTF8String];
    studyModality_ = [info.studyModality UTF8String];
    studyDate_ = [[dateFormatter stringFromDate:info.studyDateTime] UTF8String];
    [dateFormatter setDateFormat:@"HHmmss"];
    studyTime_ = [[dateFormatter stringFromDate:info.studyDateTime] UTF8String];
    studyStudyUID_ = [info.studyStudyUID UTF8String];

    float thickness = [info.imageSliceThickness floatValue];
    imageSliceThickness_ = [[NSString stringWithFormat:@"%.2f", thickness] UTF8String];

    float xpos = [info.imagePatientPositionX floatValue];
    float ypos = [info.imagePatientPositionY floatValue];
    float zpos = [info.imagePatientPositionZ floatValue];
    NSString* ipp = [NSString stringWithFormat:@"%.2f\\%.2f\\%.2f", xpos, ypos, zpos];
    imagePatientPosition_ = [ipp UTF8String];
    imagePatientOrientation_ = [info.imagePatientOrientation UTF8String];
}

std::string DicomInfo::patientsName() const
{
    return patientsName_;
}

std::string DicomInfo::patientsID() const
{
    return patientsID_;
}

std::string DicomInfo::patientsDOB() const
{
    return patientsDOB_;
}

std::string DicomInfo::patientsSex() const
{
    return patientsSex_;
}

std::string DicomInfo::studyDescription() const
{
    return studyDescription_;
}

std::string DicomInfo::studyID() const
{
    return studyID_;
}

std::string DicomInfo::studyModality() const
{
    return studyModality_;
}

std::string DicomInfo::studyDate() const
{
    return studyDate_;
}

std::string DicomInfo::studyTime() const
{
    return studyTime_;
}

std::string DicomInfo::studyStudyUID() const
{
    return studyStudyUID_;
}

std::string DicomInfo::imageSliceThickness() const
{
    return imageSliceThickness_;
}

std::string DicomInfo::imagePatientPosition() const
{
    return imagePatientPosition_;
}

std::string DicomInfo::imagePatientOrientation() const
{
    return imagePatientOrientation_;
}

