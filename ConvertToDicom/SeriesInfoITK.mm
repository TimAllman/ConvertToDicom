//
//  SeriesInfoITK.mm
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-05-26.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#include "SeriesInfoITK.h"
#include "LoggerName.h"
#include "DumpMetaDataDictionary.h"

#import "SeriesInfo.h"

#include <itkMetaDataObject.h>
#include <gdcmUIDGenerator.h>

#include <log4cplus/loggingmacros.h>

#include <iomanip>

SeriesInfoITK::SeriesInfoITK(const SeriesInfo* info)
{
    std::string name = std::string(LOGGER_NAME) + ".SeriesInfoITK";
    logger_ = log4cplus::Logger::getInstance(name);
    LOG4CPLUS_TRACE(logger_, "Enter");

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
    seriesPatientPosition_ = [info.seriesPatientPosition UTF8String];

    imageSliceSpacing_ = [info.imageSliceSpacing floatValue];
    imagePositionPatient_[0] = [info.imagePatientPositionX floatValue];
    imagePositionPatient_[1] = [info.imagePatientPositionY floatValue];
    imagePositionPatient_[2] = [info.imagePatientPositionZ floatValue];
    imageOrientationPatient_ = [info.imagePatientOrientation UTF8String];

    dict = makeDictionary();
}

itk::MetaDataDictionary SeriesInfoITK::makeDictionary() const
{
    LOG4CPLUS_TRACE(logger_, "Enter");

    // fill the dictionary from our Dicom info.
    if (dict.GetKeys().size() == 0)
    {
        itk::EncapsulateMetaData<std::string>(dict, "0010|0010", patientsName_);
        itk::EncapsulateMetaData<std::string>(dict, "0010|0020", patientsID_);
        itk::EncapsulateMetaData<std::string>(dict, "0010|0030", patientsDOB_);
        itk::EncapsulateMetaData<std::string>(dict, "0010|0040", patientsSex_);
        
        itk::EncapsulateMetaData<std::string>(dict, "0008|1030", studyDescription_);
        itk::EncapsulateMetaData<std::string>(dict, "0020|0010", studyID_);
        itk::EncapsulateMetaData<std::string>(dict, "0008|0060", studyModality_);
        itk::EncapsulateMetaData<std::string>(dict, "0008|0020", studyDate_);
        itk::EncapsulateMetaData<std::string>(dict, "0008|0031", studyTime_);
        itk::EncapsulateMetaData<std::string>(dict, "0020|000d", studyStudyUID_);

        gdcm::UIDGenerator suidGen;
        std::string seriesUID = suidGen.Generate();
        gdcm::UIDGenerator fuidGen;
        std::string frameOfReferenceUID = fuidGen.Generate();
        itk::EncapsulateMetaData<std::string>(dict, "0020|000e", seriesUID);
        itk::EncapsulateMetaData<std::string>(dict, "0020|0052", frameOfReferenceUID);
        itk::EncapsulateMetaData<std::string>(dict, "0020|0011", seriesNumber_);
        itk::EncapsulateMetaData<std::string>(dict, "0008|103e", seriesDescription_);
        itk::EncapsulateMetaData<std::string>(dict, "0018|5100", seriesPatientPosition_);
        itk::EncapsulateMetaData<std::string>(dict, "0008|0021", studyDate_); // just use study date
        itk::EncapsulateMetaData<std::string>(dict, "0008|0030", studyTime_); // just use study time

        std::stringstream sstr;
        sstr << std::setprecision(2) << imageSliceSpacing_;
        std::string spacing = sstr.str();
        //itk::EncapsulateMetaData<std::string>(dict, "0018|0050", spacing);
        itk::EncapsulateMetaData<std::string>(dict, "0020|0037", imageOrientationPatient_);
        itk::EncapsulateMetaData<std::string>(dict, "0020|0032", imagePositionPatientString());
    }

    LOG4CPLUS_TRACE(logger_, "Initial MetaDataDictionary:\n" << DumpDicomMetaDataDictionary(dict));

    return dict;
}

itk::MetaDataDictionary SeriesInfoITK::dictionary() const
{
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

std::string SeriesInfoITK::seriesPatientPosition() const
{
    return seriesPatientPosition_;
}

float SeriesInfoITK::imageSliceSpacing() const
{
    return imageSliceSpacing_;
}

vnl_vector_fixed<float, 3> SeriesInfoITK::imagePositionPatient() const
{
    return imagePositionPatient_;
}

std::string SeriesInfoITK::imagePositionPatientString() const
{
    std::stringstream sstr;
    sstr << std::fixed << std::setprecision(2) << imagePositionPatient_[0] << "\\"
    << imagePositionPatient_[1] << "\\" << imagePositionPatient_[2] << "\\";
    return sstr.str();
}

std::string SeriesInfoITK::imagePositionPatientString(unsigned int sliceIdx) const
{
    LOG4CPLUS_TRACE(logger_, "Enter");

    vnl_matrix_fixed<float, 3, 3> rot;   // the rotation matrix
    vnl_vector_fixed<float, 3> ipp;      // the IPP (column) vector

    // Create the rotation matrix from IOP
    sscanf(imageOrientationPatient_.c_str(), "%f\\%f\\%f\\%f\\%f\\%f",
           &rot(0, 0), &rot(0, 1), &rot(0, 2), &rot(1, 0), &rot(1, 1), &rot(1, 2));

    // Compute the remaining orthogonal vector to complete the matrix
    rot(2,0) = rot(0, 1) * rot(1, 2) - rot(0, 2) * rot(1, 1);
    rot(2,1) = rot(0, 2) * rot(1, 0) - rot(0, 0) * rot(1, 2);
    rot(2,2) = rot(0, 0) * rot(1, 1) - rot(0, 1) * rot(1, 0);

    // IPP as a vector
    ipp = imagePositionPatient_;

    LOG4CPLUS_DEBUG(logger_, "Initial IPP = " << imagePositionPatientString());

    ipp = rot * ipp;                            // rotate ipp into image coordinates
    ipp[2] += imageSliceSpacing_ * sliceIdx;    // increment Z component
    ipp = rot.inplace_transpose() * ipp;        // rotate back into patient coordinates

    char  ippStr[30];
    sprintf(ippStr, "%.2f\\%.2f\\%.2f", ipp(0), ipp(1), ipp(2));
    LOG4CPLUS_DEBUG(logger_, "Incremented IPP = " << ippStr);

    return ippStr;

    /* extracted from osirix, reflected in above code
     float vec[3];
     vec[0] = iop[1]*iop[5] - iop[2]*iop[4];
     vec[1] = iop[2]*iop[3] - iop[0]*iop[5];
     vec[2] = iop[0]*iop[4] - iop[1]*iop[3];
     */

}

std::string SeriesInfoITK::imageOrientationPatient() const
{
    return imageOrientationPatient_;
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

