//
//  SeriesInfoITK.mm
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-05-26.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#include "SeriesInfoITK.h"

#import "SeriesInfo.h"

#include <itkMetaDataObject.h>

#include <iomanip>

SeriesInfoITK::SeriesInfoITK(const SeriesInfo* info)
{
    inputDir_ = [info.inputDir UTF8String];
    outputDir_ = [info.outputDir UTF8String];
    numberOfImages_ = [info.numberOfImages unsignedIntValue];
    slicesPerImage_ = [info.slicesPerImage unsignedIntValue];
    timeIncrement_ = [info.timeIncrement floatValue];
    for (NSString* timeStr in info.acqTimes)
        acqTimes_.push_back([timeStr UTF8String]);

    patientsName_ = [info.patientsName UTF8String];
    patientsID_ = [[info.patientsID stringValue] UTF8String];

    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString* dob = [dateFormatter stringFromDate:info.patientsDOB];
    patientsDOB_ = [dob UTF8String];
    patientsSex_ = [info.patientsSex UTF8String];
    studyDescription_ = [info.studyDescription UTF8String];
    studyID_ = [[info.studyID stringValue] UTF8String];
    studyModality_ = [info.studyModality UTF8String];
    studyDate_ = [[dateFormatter stringFromDate:info.studyDateTime] UTF8String];
    [dateFormatter setDateFormat:@"HHmmss"];
    studyTime_ = [[dateFormatter stringFromDate:info.studyDateTime] UTF8String];
    studyStudyUID_ = [info.studyStudyUID UTF8String];

    seriesDescription_ = [info.seriesDescription UTF8String];
    seriesNumber_ = [[info.seriesNumber stringValue] UTF8String];

    imageSliceSpacing_ = [info.imageSliceSpacing floatValue];
    imagePatientPositionX_ = [info.imagePatientPositionX floatValue];
    imagePatientPositionY_ = [info.imagePatientPositionY floatValue];
    imagePatientPositionZ_ = [info.imagePatientPositionZ floatValue];
    NSString* ipp = [NSString stringWithFormat:@"%.2f\\%.2f\\%.2f",
                     imagePatientPositionX_, imagePatientPositionY_, imagePatientPositionZ_];
    imagePatientPosition_ = [ipp UTF8String];
    imagePatientOrientation_ = [info.imagePatientOrientation UTF8String];

    dict = dictionary();
}

itk::MetaDataDictionary SeriesInfoITK::dictionary() const
{
    // fill the dictionary from our Dicom info.

    if (dict.GetKeys().size() == 0)
    {
        itk::EncapsulateMetaData<std::string>(dict, "0010|0010", patientsName_);
        itk::EncapsulateMetaData<std::string>(dict, "0010|0020", patientsID_);
        itk::EncapsulateMetaData<std::string>(dict, "0010|0030", patientsDOB_);
        itk::EncapsulateMetaData<std::string>(dict, "0010|0040", patientsSex_);
        
        itk::EncapsulateMetaData<std::string>(dict, "0008|1030", studyDescription_);
        itk::EncapsulateMetaData<std::string>(dict, "0020|0010", studyID_);
        itk::EncapsulateMetaData<std::string>(dict, "0020|000d", studyStudyUID_);
        itk::EncapsulateMetaData<std::string>(dict, "0008|0060", studyModality_);
        itk::EncapsulateMetaData<std::string>(dict, "0020|0011", seriesNumber_);
        itk::EncapsulateMetaData<std::string>(dict, "0008|103e", seriesDescription_);

        // although the date is called studyDate, save as study and series dates.
        itk::EncapsulateMetaData<std::string>(dict, "0008|0020", studyDate_);
        itk::EncapsulateMetaData<std::string>(dict, "0008|0021", studyDate_);

        // same for times
        itk::EncapsulateMetaData<std::string>(dict, "0008|0030", studyTime_);
        itk::EncapsulateMetaData<std::string>(dict, "0008|0031", studyTime_);

        std::stringstream sstr;
        sstr << std::setprecision(2) << imageSliceSpacing_;
        std::string spacing = sstr.str();
        itk::EncapsulateMetaData<std::string>(dict, "0018|0050", spacing);
        itk::EncapsulateMetaData<std::string>(dict, "0020|0037", imagePatientOrientation_);
    }

    return dict;
}

std::string SeriesInfoITK::patientsName() const
{
    return patientsName_;
}

std::string SeriesInfoITK::patientsID() const
{
    return patientsID_;
}

std::string SeriesInfoITK::patientsDOB() const
{
    return patientsDOB_;
}

std::string SeriesInfoITK::patientsSex() const
{
    return patientsSex_;
}

std::string SeriesInfoITK::studyDescription() const
{
    return studyDescription_;
}

std::string SeriesInfoITK::studyID() const
{
    return studyID_;
}

std::string SeriesInfoITK::studyModality() const
{
    return studyModality_;
}

std::string SeriesInfoITK::studyDate() const
{
    return studyDate_;
}

std::string SeriesInfoITK::studyTime() const
{
    return studyTime_;
}

std::string SeriesInfoITK::studyStudyUID() const
{
    return studyStudyUID_;
}

std::string SeriesInfoITK::seriesNumber() const
{
    return seriesNumber_;
}

std::string SeriesInfoITK::seriesDescription() const
{
    return seriesDescription_;
}

float SeriesInfoITK::imageSliceSpacing() const
{
    return imageSliceSpacing_;
}

float SeriesInfoITK::imagePatientPositionX() const
{
    return imagePatientPositionX_;
}

float SeriesInfoITK::imagePatientPositionY() const
{
    return imagePatientPositionY_;
}

float SeriesInfoITK::imagePatientPositionZ() const
{
    return imagePatientPositionZ_;
}

std::string SeriesInfoITK::imagePatientPosition() const
{
    return imagePatientPosition_;
}

std::string SeriesInfoITK::imagePatientOrientation() const
{
    return imagePatientOrientation_;
}

std::string SeriesInfoITK::inputDir() const
{
    return inputDir_;
}

std::string SeriesInfoITK::outputDir() const
{
    return outputDir_;
}

unsigned SeriesInfoITK::numberOfImages() const
{
    return numberOfImages_;
}

unsigned SeriesInfoITK::slicesPerImage() const
{
    return slicesPerImage_;
}

float SeriesInfoITK::timeIncrement() const
{
    return timeIncrement_;
}

const std::vector<std::string>& SeriesInfoITK::acqTimes() const
{
    return acqTimes_;
}

