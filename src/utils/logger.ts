import winston from 'winston';
import DailyRotateFile from 'winston-daily-rotate-file';
import path from 'path';

// Create logs directory if it doesn't exist
const logsDir = path.join(process.cwd(), 'logs');

// Define custom logger interface
interface CustomLogger extends winston.Logger {
  testStart: (testName: string, scenario?: string) => void;
  testEnd: (testName: string, status: 'PASSED' | 'FAILED', duration?: number) => void;
  stepStart: (stepName: string) => void;
  stepEnd: (stepName: string, status: 'PASSED' | 'FAILED') => void;
  screenshot: (filePath: string, testName: string) => void;
  pageNavigation: (url: string, testName: string) => void;
  browserAction: (action: string, element: string, testName: string) => void;
  assertion: (assertion: string, result: 'PASSED' | 'FAILED', testName: string) => void;
}

// Define log levels and colors
const logLevels = {
  error: 0,
  warn: 1,
  info: 2,
  http: 3,
  debug: 4,
};

const logColors = {
  error: 'red',
  warn: 'yellow',
  info: 'green',
  http: 'magenta',
  debug: 'blue',
};

winston.addColors(logColors);

// Define log format
const logFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss:ms' }),
  winston.format.colorize({ all: true }),
  winston.format.printf(
    (info) => `${info.timestamp} ${info.level}: ${info.message}`
  )
);

// Define log format for files (without colors)
const fileLogFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss:ms' }),
  winston.format.printf(
    (info) => `${info.timestamp} ${info.level}: ${info.message}`
  )
);

// Create transports
const transports = [
  // Console transport
  new winston.transports.Console({
    format: logFormat,
    level: process.env.LOG_LEVEL || 'info',
  }),
  
  // Daily rotating file for all logs
  new DailyRotateFile({
    filename: path.join(logsDir, 'application-%DATE%.log'),
    datePattern: 'YYYY-MM-DD',
    maxSize: '20m',
    maxFiles: '14d',
    format: fileLogFormat,
    level: 'debug',
  }),
  
  // Daily rotating file for errors only
  new DailyRotateFile({
    filename: path.join(logsDir, 'error-%DATE%.log'),
    datePattern: 'YYYY-MM-DD',
    maxSize: '20m',
    maxFiles: '30d',
    format: fileLogFormat,
    level: 'error',
  }),
  
  // Daily rotating file for test execution
  new DailyRotateFile({
    filename: path.join(logsDir, 'test-execution-%DATE%.log'),
    datePattern: 'YYYY-MM-DD',
    maxSize: '50m',
    maxFiles: '7d',
    format: fileLogFormat,
    level: 'info',
  }),
];

// Create the logger
const baseLogger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  levels: logLevels,
  transports,
  exitOnError: false,
});

// Handle uncaught exceptions and rejections
baseLogger.exceptions.handle(
  new winston.transports.File({ 
    filename: path.join(logsDir, 'exceptions.log'),
    format: fileLogFormat,
  })
);

baseLogger.rejections.handle(
  new winston.transports.File({ 
    filename: path.join(logsDir, 'rejections.log'),
    format: fileLogFormat,
  })
);

// Create custom logger with extended methods
const logger = baseLogger as CustomLogger;

// Add custom methods for test logging
(logger as any).testStart = (testName: string, scenario?: string) => {
  logger.info(`🚀 TEST START: ${testName}${scenario ? ` - ${scenario}` : ''}`);
};

(logger as any).testEnd = (testName: string, status: 'PASSED' | 'FAILED', duration?: number) => {
  const durationText = duration ? ` (${duration}ms)` : '';
  const emoji = status === 'PASSED' ? '✅' : '❌';
  logger.info(`${emoji} TEST ${status}: ${testName}${durationText}`);
};

(logger as any).stepStart = (stepName: string) => {
  logger.debug(`📝 STEP: ${stepName}`);
};

(logger as any).stepEnd = (stepName: string, status: 'PASSED' | 'FAILED') => {
  const emoji = status === 'PASSED' ? '✓' : '✗';
  logger.debug(`${emoji} STEP ${status}: ${stepName}`);
};

(logger as any).screenshot = (filePath: string, testName: string) => {
  logger.info(`📸 SCREENSHOT: ${testName} -> ${filePath}`);
};

(logger as any).pageNavigation = (url: string, testName: string) => {
  logger.info(`🌐 NAVIGATION: ${testName} -> ${url}`);
};

(logger as any).browserAction = (action: string, element: string, testName: string) => {
  logger.debug(`🖱️ ACTION: ${testName} -> ${action} on ${element}`);
};

(logger as any).assertion = (assertion: string, result: 'PASSED' | 'FAILED', testName: string) => {
  const emoji = result === 'PASSED' ? '✓' : '✗';
  logger.debug(`${emoji} ASSERTION: ${testName} -> ${assertion}`);
};

// Azure App Service specific logging
if (process.env.WEBSITE_HOSTNAME) {
  logger.info(`🔷 Running in Azure App Service: ${process.env.WEBSITE_HOSTNAME}`);
  
  // Add Azure-specific transport for stdout (appears in Azure logs)
  logger.add(new winston.transports.Console({
    format: winston.format.combine(
      winston.format.timestamp(),
      winston.format.simple()
    ),
    level: 'info'
  }));
}

export default logger;
