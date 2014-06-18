//
//  SetupLogger.cpp
//  TestLib
//
//  Created by Tim Allman on 2013-11-04.
//  Copyright (c) 2013 Tim Allman. All rights reserved.
//

#include "LoggerUtils.h"

#include <log4cplus/loglevel.h>
#include <log4cplus/logger.h>
#include <log4cplus/consoleappender.h>
#include <log4cplus/fileappender.h>
#include <log4cplus/loggingmacros.h>

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

    // The console appender
    log4cplus::SharedAppenderPtr consoleAppender(new log4cplus::ConsoleAppender);
    std::string consoleAppName = loggerName + ".console";
    consoleAppender->setName(consoleAppName);
    consoleAppender->setThreshold(log4cplus::INFO_LOG_LEVEL);
    std::string consolePattern = "%-5p (%d{%q}) [%b:%L] %m%n";
    std::auto_ptr<log4cplus::Layout> layout(new log4cplus::PatternLayout(consolePattern));
    consoleAppender->setLayout(layout);

    logger.addAppender(consoleAppender);

    // Generate the name of the rolling file in $HOME/Library/Logs
    std::string homeDir = getenv("HOME");
    std::string logFileName = loggerName + ".log";

    std::string logFilePath;
    if (filePath.size() == 0)
        logFilePath = homeDir + "/Library/Logs/" + logFileName;

    std::string logFileAppName = loggerName + ".file";
    log4cplus::SharedAppenderPtr
        logFileApp(new log4cplus::RollingFileAppender(logFilePath, 1000000, 5, false));
    logFileApp->setName(logFileAppName);
    std::string filePattern = "%-5p [%d{%y-%m-%d %H:%M:%S:%q}][%b:%L] %m%n";
    std::auto_ptr<log4cplus::Layout> fileLayout(new log4cplus::PatternLayout(filePattern));
    logFileApp->setLayout(fileLayout);
    logFileApp->setThreshold(log4cplus::TRACE_LOG_LEVEL);
    logger.addAppender(logFileApp);

    // Force this to the console.
    LOG4CPLUS_INFO(logger, "Logging to file: " << logFilePath << ", Level: " << LogLevelToString(level));
}

void ResetLoggerLevel(const char* name, int level)
{
    log4cplus::Logger logger = log4cplus::Logger::getInstance(name);
    logger.setLogLevel(level);
}

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
