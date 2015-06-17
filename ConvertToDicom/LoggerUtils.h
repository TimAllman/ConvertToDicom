/*
 * File:   Logger.h
 * Author: tim
 *
 * Created on February 27, 2013, 9:32 AM
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

