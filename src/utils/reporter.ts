import fs from 'fs';
import path from 'path';
import { formatISO } from 'date-fns';

/**
 * Simple reporter to log test results
 */
export class Reporter {
  /**
   * Save test result to a file
   * @param testName Test name
   * @param status Test status (passed/failed)
   * @param error Error message if test failed
   */
  static logTestResult(testName: string, status: string, error?: string): void {
    const timestamp = formatISO(new Date());
    const logDir = path.join(process.cwd(), 'test-results', 'logs');
    
    if (!fs.existsSync(logDir)) {
      fs.mkdirSync(logDir, { recursive: true });
    }
    
    const logFile = path.join(logDir, 'test-results.log');
    const logEntry = `[${timestamp}] Test: ${testName} - Status: ${status}${error ? ` - Error: ${error}` : ''}\n`;
    
    fs.appendFileSync(logFile, logEntry);
  }
}