//
//  SetupLogger.cpp
//  ConvertToDicom
//

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

#include "LoggerUtils.h"

#include <log4cplus/loglevel.h>
#include <log4cplus/logger.h>
#include <log4cplus/consoleappender.h>
#include <log4cplus/fileappender.h>
#include <log4cplus/loggingmacros.h>

#import "UserDefaults.h"

std::string LogLevelToString(int level);

void SetupLogger(const std::string& loggerName, int level, const std::string& filePath)
{
    static bool setup = false;
    if (setup)
        return;
    setup = true;

    // The logger is set to log all messages. We use the appenders to restrict the output(s).
    log4cplus::Logger logger = log4cplus::Logger::getInstance(loggerName);
    logger.setLogLevel(level);

    // The console appender.
    log4cplus::SharedAppenderPtr consoleAppender(new log4cplus::ConsoleAppender);
    std::string consoleAppName = loggerName + ".console";
    consoleAppender->setName(consoleAppName);
    consoleAppender->setThreshold(log4cplus::INFO_LOG_LEVEL);
    std::string consolePattern = "%-5p (%d{%q}) [%b:%L] %m%n";
    std::auto_ptr<log4cplus::Layout> layout(new log4cplus::PatternLayout(consolePattern));
    consoleAppender->setLayout(layout);

    logger.addAppender(consoleAppender);

    // Generate the name of the rolling file, by default in $HOME/Library/Logs
    std::string logFilePath;
    std::string logFileName = loggerName + ".log";
    if (filePath.size() == 0)
    {
        logFilePath = std::string(getenv("HOME")) + "/Library/Logs/";
    }
    else
    {
        logFilePath = filePath + "/";
    }
    logFilePath += logFileName;

    // Set up the Rolling File Appender format
    std::string logFileAppName = loggerName + ".file";
    log4cplus::SharedAppenderPtr
        logFileApp(new log4cplus::RollingFileAppender(logFilePath, 1000000, 5, false));
    logFileApp->setName(logFileAppName);
    std::string filePattern = "%-5p [%d{%y-%m-%d %H:%M:%S:%q}][%b:%L] %m%n";
    std::auto_ptr<log4cplus::Layout> fileLayout(new log4cplus::PatternLayout(filePattern));
    logFileApp->setLayout(fileLayout);

    // Set up the log file level
    int logLevel = level;
    if (logLevel == log4cplus::NOT_SET_LOG_LEVEL)
    {
        // Load logging level. If LoggingLevelKey is not found in the defaults, integerForKey returns
        // 0 which is log4cplus::TRACE_LOG_LEVEL
        NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
        logLevel = (int)[defs integerForKey:LoggingLevelKey];
    }

    logFileApp->setThreshold(logLevel);
    logger.addAppender(logFileApp);

    // Force this to the console.
    LOG4CPLUS_INFO(logger, "Logging to file: " << logFilePath << ", Level: " << LogLevelToString(logLevel));
}

void ResetLoggerLevel(const char* name, int level)
{
    log4cplus::Logger logger = log4cplus::Logger::getInstance(name);
    logger.setLogLevel(level);
}

/**
 * Convert the log level to a human readable string.
 * @param level The log4m and log4cplus logging level.
 * @return The level as a string or "Unknown" if level is invalid
 */
std::string LogLevelToString(int level)
{
    std::string retVal;

    switch (level)
    {
        case log4cplus::OFF_LOG_LEVEL:
            retVal = "OFF";
            break;
        case log4cplus::FATAL_LOG_LEVEL:
            retVal = "FATAL";
            break;
        case log4cplus::ERROR_LOG_LEVEL:
            retVal = "ERROR";
            break;
        case log4cplus::WARN_LOG_LEVEL:
            retVal = "WARN";
            break;
        case log4cplus::INFO_LOG_LEVEL:
            retVal = "INFO";
            break;
        case log4cplus::DEBUG_LOG_LEVEL:
            retVal = "DEBUG";
            break;
        case log4cplus::TRACE_LOG_LEVEL:
            retVal = "TRACE";
            break;
        case log4cplus::NOT_SET_LOG_LEVEL:
            retVal = "NOT SET";
            break;
        default:
            retVal = "Unknown";
            break;
    }

    return retVal;
}
