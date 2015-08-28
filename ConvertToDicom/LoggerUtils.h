/*
 * File:   Logger.h
 * Author: Tim Allman
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

#ifndef SETUP_LOGGER_H
#define	SETUP_LOGGER_H

#include <string>

/**
 * Set up the Log4m logger. 
 * @param loggerName The name of the logger.
 * @param level The initial level of the logger. This can be a log4cplus level or a Log4m level and
 * affects only the rolling file appender. There will be a console appender which is always set
 * to LOG4M_LEVEL_INFO. If level is LOG4M_LEVEL_NOT_SET then [NSUserDefaults standardUserDefaults]
 * will be checked with the key @"LoggingLevel" and the value loaded if it is found. If it is not 
 * found LOG4M_LEVEL_TRACE will be used.
 * This can be changed with ResetLoggerLevel().
 * @param logFilePath The complete path of the logger file. If the string is empty the default is
 * $(HOME)/Library/Logs/loggerName.log
 */
void SetupLogger(const std::string& loggerName, int level, const std::string& logFilePath = "");

/**
 * Reset the logger level
 * @param name The name of the logger
 * @param level The new level. This is a Log4m or log4cplus level.
 */
void ResetLoggerLevel(const char* name, int level);

#endif	/* LOGGER_H */

