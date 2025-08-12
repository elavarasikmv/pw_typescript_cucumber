const express = require('express');
const path = require('path');
const fs = require('fs');
const { spawn } = require('child_process');

const app = express();
const port = process.env.PORT || 8080;

// Middleware
app.use(express.json());
app.use(express.static('public'));

// Create directories if they don't exist
const ensureDirectories = () => {
    const dirs = ['test-results', 'logs', 'public'];
    dirs.forEach(dir => {
        if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir, { recursive: true });
        }
    });
};

ensureDirectories();

// Health check endpoint with browser verification
app.get('/health', async (req, res) => {
    const healthStatus = {
        status: 'healthy',
        timestamp: new Date().toISOString(),
        nodeVersion: process.version,
        environment: process.env.NODE_ENV || 'development',
        playwright: {}
    };

    try {
        // Check Playwright availability
        const { chromium } = require('playwright');
        
        try {
            // Check if executable exists
            const executablePath = chromium.executablePath();
            healthStatus.playwright.executablePath = executablePath;
            healthStatus.playwright.available = true;
            
            // Quick browser test (only if requested)
            if (req.query.testBrowser === 'true') {
                console.log('🔍 Running health check browser test...');
                const browser = await chromium.launch({ 
                    headless: true,
                    args: ['--no-sandbox', '--disable-dev-shm-usage', '--disable-gpu']
                });
                await browser.close();
                healthStatus.playwright.browserTest = 'passed';
                console.log('✅ Health check browser test passed');
            }
            
        } catch (playwrightError) {
            healthStatus.playwright.available = false;
            healthStatus.playwright.error = playwrightError.message;
            healthStatus.status = 'warning';
        }
        
    } catch (requireError) {
        healthStatus.playwright.available = false;
        healthStatus.playwright.error = 'Playwright not installed';
        healthStatus.status = 'warning';
    }

    res.json(healthStatus);
});

// Root endpoint
app.get('/', (req, res) => {
    const html = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Playwright Cucumber Framework</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
        .status { background: #d4edda; color: #155724; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .endpoints { background: #e9ecef; padding: 20px; border-radius: 5px; }
        .endpoints a { color: #007bff; text-decoration: none; }
        .endpoints a:hover { text-decoration: underline; }
        .info { margin: 10px 0; }
        button { background: #007bff; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; margin: 5px; }
        button:hover { background: #0056b3; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎭 Playwright Cucumber Framework</h1>
        
        <div class="status">
            <strong>✅ Service Status:</strong> Running successfully!
        </div>
        
        <div class="info">
            <strong>Timestamp:</strong> ${new Date().toLocaleString()}<br>
            <strong>Node.js Version:</strong> ${process.version}<br>
            <strong>Environment:</strong> ${process.env.NODE_ENV || 'development'}<br>
            <strong>Platform:</strong> Azure App Service
        </div>
        
        <div class="endpoints">
            <h2>🔗 Available Endpoints:</h2>
            <ul>
                <li><a href="/health">/health</a> - Health check endpoint</li>
                <li><a href="/test-results">/test-results</a> - View test results and logs</li>
                <li><strong>/run-tests</strong> - Run Playwright tests (POST request)</li>
            </ul>
            
            <h3>🚀 Quick Actions:</h3>
            <button onclick="runTests()">Run Tests</button>
            <button onclick="viewResults()">View Results</button>
            <button onclick="checkHealth()">Health Check</button>
            <button onclick="openTestInterface()">🎯 Test Interface</button>
        </div>
        
        <div id="output" style="margin-top: 20px;"></div>
    </div>

    <script>
        function runTests() {
            const output = document.getElementById('output');
            output.innerHTML = '<div style="background: #fff3cd; padding: 15px; border-radius: 5px;">🏃‍♂️ Running tests... Please wait...</div>';
            
            fetch('/run-tests', { method: 'POST' })
                .then(response => response.text())
                .then(data => {
                    output.innerHTML = '<div style="background: #d4edda; padding: 15px; border-radius: 5px;"><h3>Test Results:</h3><pre>' + data + '</pre></div>';
                })
                .catch(error => {
                    output.innerHTML = '<div style="background: #f8d7da; padding: 15px; border-radius: 5px;">❌ Error: ' + error + '</div>';
                });
        }
        
        function viewResults() {
            window.open('/test-results', '_blank');
        }
        
        function checkHealth() {
            fetch('/health')
                .then(response => response.json())
                .then(data => {
                    document.getElementById('output').innerHTML = 
                        '<div style="background: #d4edda; padding: 15px; border-radius: 5px;"><h3>Health Check:</h3><pre>' + 
                        JSON.stringify(data, null, 2) + '</pre></div>';
                });
        }
        
        function openTestInterface() {
            window.open('/test-interface.html', '_blank');
        }
    </script>
</body>
</html>`;
    res.send(html);
});

// Run tests endpoint
app.post('/run-tests', (req, res) => {
    console.log('🚀 Starting test execution...');
    
    res.writeHead(200, {
        'Content-Type': 'text/plain; charset=utf-8',
        'Transfer-Encoding': 'chunked'
    });
    
    res.write('🎭 Playwright Cucumber Test Execution\n');
    res.write('=====================================\n\n');
    res.write('⏰ Started at: ' + new Date().toLocaleString() + '\n\n');
    
    // Set environment variables for test execution
    const testEnv = {
        ...process.env,
        HEADLESS: 'true',
        CI: 'true',
        LOG_LEVEL: 'info'
    };
    
    const testProcess = spawn('npm', ['test'], {
        stdio: 'pipe',
        env: testEnv,
        cwd: process.cwd()
    });
    
    testProcess.stdout.on('data', (data) => {
        const output = data.toString();
        console.log('STDOUT:', output);
        res.write(output);
    });
    
    testProcess.stderr.on('data', (data) => {
        const output = data.toString();
        console.log('STDERR:', output);
        res.write('⚠️ ' + output);
    });
    
    testProcess.on('close', (code) => {
        const endTime = new Date().toLocaleString();
        const resultMessage = code === 0 ? '✅ Tests completed successfully!' : '❌ Tests completed with issues.';
        
        res.write(`\n\n${resultMessage}\n`);
        res.write(`⏰ Completed at: ${endTime}\n`);
        res.write(`🔢 Exit code: ${code}\n`);
        res.write('\n📊 Check /test-results for detailed reports and logs.\n');
        
        console.log(`Test execution completed with code: ${code}`);
        res.end();
    });
    
    testProcess.on('error', (error) => {
        console.error('Test process error:', error);
        res.write(`\n❌ Error starting tests: ${error.message}\n`);
        res.end();
    });
});

// View test results
app.get('/test-results', (req, res) => {
    let html = `
<!DOCTYPE html>
<html>
<head>
    <title>Test Results</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .file-list { list-style-type: none; padding: 0; }
        .file-list li { margin: 5px 0; }
        .file-list a { color: #007bff; text-decoration: none; }
        .file-list a:hover { text-decoration: underline; }
        pre { background: #f8f9fa; padding: 15px; border-radius: 5px; overflow-x: auto; }
    </style>
</head>
<body>
    <h1>📊 Test Results & Logs</h1>`;
    
    // Check for test results
    if (fs.existsSync('./test-results')) {
        html += '<div class="section"><h2>📁 Test Results Directory:</h2>';
        try {
            const files = fs.readdirSync('./test-results');
            if (files.length > 0) {
                html += '<ul class="file-list">';
                files.forEach(file => {
                    html += `<li>📄 ${file}</li>`;
                });
                html += '</ul>';
            } else {
                html += '<p>No test result files found.</p>';
            }
        } catch (error) {
            html += `<p>Error reading test results: ${error.message}</p>`;
        }
        html += '</div>';
    }
    
    // Check for logs
    if (fs.existsSync('./logs')) {
        html += '<div class="section"><h2>📋 Log Files:</h2>';
        try {
            const logFiles = fs.readdirSync('./logs');
            if (logFiles.length > 0) {
                html += '<ul class="file-list">';
                logFiles.forEach(file => {
                    html += `<li><a href="/logs/${file}">📄 ${file}</a></li>`;
                });
                html += '</ul>';
            } else {
                html += '<p>No log files found.</p>';
            }
        } catch (error) {
            html += `<p>Error reading logs: ${error.message}</p>`;
        }
        html += '</div>';
    }
    
    // Show latest log content if available
    try {
        const logFiles = fs.readdirSync('./logs').filter(f => f.endsWith('.log'));
        if (logFiles.length > 0) {
            // Get the most recent log file
            const latestLog = logFiles.sort().pop();
            const logContent = fs.readFileSync(path.join('./logs', latestLog), 'utf8');
            const recentLines = logContent.split('\n').slice(-20).join('\n');
            
            html += `<div class="section">
                <h2>📄 Latest Log Content (${latestLog}):</h2>
                <pre>${recentLines}</pre>
            </div>`;
        }
    } catch (error) {
        console.error('Error reading latest log:', error);
    }
    
    if (!fs.existsSync('./test-results') && !fs.existsSync('./logs')) {
        html += '<div class="section"><p>No test results or logs found. <a href="/">Run tests</a> first.</p></div>';
    }
    
    html += '<div class="section"><a href="/">&larr; Back to Home</a></div>';
    html += '</body></html>';
    
    res.send(html);
});

// Serve individual log files
app.get('/logs/:filename', (req, res) => {
    const filename = req.params.filename;
    const logPath = path.join('./logs', filename);
    
    if (fs.existsSync(logPath)) {
        res.setHeader('Content-Type', 'text/plain; charset=utf-8');
        res.sendFile(path.resolve(logPath));
    } else {
        res.status(404).send('Log file not found');
    }
});

// Force browser installation endpoint
app.post('/install-browsers', async (req, res) => {
    console.log('🎭 Starting browser installation...');
    
    try {
        const { spawn } = require('child_process');
        
        res.writeHead(200, {
            'Content-Type': 'text/plain; charset=utf-8',
            'Transfer-Encoding': 'chunked'
        });
        
        res.write('🎭 Installing Playwright browsers...\n');
        res.write('=====================================\n\n');
        
        const installProcess = spawn('npx', ['playwright', 'install', 'chromium', '--with-deps'], {
            stdio: 'pipe',
            env: {
                ...process.env,
                PLAYWRIGHT_BROWSERS_PATH: '/home/site/wwwroot/browsers',
                PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD: 'false'
            }
        });
        
        installProcess.stdout.on('data', (data) => {
            const output = data.toString();
            console.log('INSTALL STDOUT:', output);
            res.write(output);
        });
        
        installProcess.stderr.on('data', (data) => {
            const output = data.toString();
            console.log('INSTALL STDERR:', output);
            res.write('⚠️ ' + output);
        });
        
        installProcess.on('close', (code) => {
            const message = code === 0 ? '✅ Browser installation completed successfully!' : '❌ Browser installation failed.';
            res.write(`\n\n${message}\n`);
            res.write(`Exit code: ${code}\n`);
            res.end();
        });
        
        installProcess.on('error', (error) => {
            console.error('Install process error:', error);
            res.write(`\n❌ Error during installation: ${error.message}\n`);
            res.end();
        });
        
    } catch (error) {
        console.error('Browser installation error:', error);
        res.status(500).json({
            success: false,
            error: error.message,
            timestamp: new Date().toISOString()
        });
    }
});

// Run Playwright web test
app.post('/run-playwright-web', async (req, res) => {
    console.log('🌐 Starting Playwright web test...');
    
    try {
        // Ensure browser installation first
        await ensureBrowsersInstalled();
        
        const webTestPath = path.join(__dirname, 'src', 'tests', 'basic-web-test.js');
        if (!fs.existsSync(webTestPath)) {
            return res.status(404).json({
                success: false,
                error: 'Web test file not found',
                path: webTestPath
            });
        }
        
        const { runBasicWebTest } = require(webTestPath);
        const result = await runBasicWebTest();
        
        res.json({
            success: result.success,
            result: result,
            timestamp: new Date().toISOString()
        });
        
    } catch (error) {
        console.error('Playwright web test error:', error);
        res.status(500).json({
            success: false,
            error: error.message,
            stack: error.stack,
            timestamp: new Date().toISOString()
        });
    }
});

// Run Playwright API test
app.post('/run-playwright-api', async (req, res) => {
    console.log('🔗 Starting Playwright API test...');
    
    try {
        const apiTestPath = path.join(__dirname, 'src', 'tests', 'api-test.js');
        if (!fs.existsSync(apiTestPath)) {
            return res.status(404).json({
                success: false,
                error: 'API test file not found',
                path: apiTestPath
            });
        }
        
        const { runApiTest } = require(apiTestPath);
        const result = await runApiTest();
        
        res.json({
            success: result.success,
            result: result,
            timestamp: new Date().toISOString()
        });
        
    } catch (error) {
        console.error('Playwright API test error:', error);
        res.status(500).json({
            success: false,
            error: error.message,
            stack: error.stack,
            timestamp: new Date().toISOString()
        });
    }
});

// Run all Playwright tests
app.post('/run-playwright-all', async (req, res) => {
    console.log('🚀 Starting all Playwright tests...');
    
    try {
        // Ensure browser installation first
        console.log('🔍 Ensuring browsers are installed...');
        await ensureBrowsersInstalled();
        
        const results = {
            webTest: { success: false, error: 'Not executed' },
            apiTest: { success: false, error: 'Not executed' }
        };
        
        // Run web test
        try {
            const webTestPath = path.join(__dirname, 'src', 'tests', 'basic-web-test.js');
            if (fs.existsSync(webTestPath)) {
                const { runBasicWebTest } = require(webTestPath);
                results.webTest = await runBasicWebTest();
            } else {
                results.webTest = { success: false, error: 'Web test file not found' };
            }
        } catch (webError) {
            console.error('Web test execution error:', webError);
            results.webTest = { 
                success: false, 
                error: webError.message,
                instruction: 'Try running /install-browsers first'
            };
        }
        
        // Run API test
        try {
            const apiTestPath = path.join(__dirname, 'src', 'tests', 'api-test.js');
            if (fs.existsSync(apiTestPath)) {
                const { runApiTest } = require(apiTestPath);
                results.apiTest = await runApiTest();
            } else {
                results.apiTest = { success: false, error: 'API test file not found' };
            }
        } catch (apiError) {
            console.error('API test execution error:', apiError);
            results.apiTest = { success: false, error: apiError.message };
        }
        
        const overallSuccess = results.webTest.success && results.apiTest.success;
        
        res.json({
            success: overallSuccess,
            results: results,
            message: 'All Playwright tests executed',
            timestamp: new Date().toISOString()
        });
        
    } catch (error) {
        console.error('All tests execution error:', error);
        res.status(500).json({
            success: false,
            error: error.message,
            message: 'Failed to execute all tests',
            instruction: 'Try running /install-browsers endpoint first',
            timestamp: new Date().toISOString()
        });
    }
});

// Helper function to ensure browsers are installed
async function ensureBrowsersInstalled() {
    try {
        const { chromium } = require('playwright');
        
        // Try to get executable path to check if browser exists
        try {
            const executablePath = chromium.executablePath();
            console.log(`✅ Browser found at: ${executablePath}`);
            return true;
        } catch (pathError) {
            console.log('⚠️ Browser executable not found, attempting installation...');
            
            // Try to install browsers
            const { spawn } = require('child_process');
            
            return new Promise((resolve, reject) => {
                const installProcess = spawn('npx', ['playwright', 'install', 'chromium'], {
                    stdio: 'pipe',
                    env: {
                        ...process.env,
                        PLAYWRIGHT_BROWSERS_PATH: '/home/site/wwwroot/browsers',
                        PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD: 'false'
                    }
                });
                
                installProcess.on('close', (code) => {
                    if (code === 0) {
                        console.log('✅ Browser installation completed');
                        resolve(true);
                    } else {
                        console.log('❌ Browser installation failed');
                        resolve(false);
                    }
                });
                
                installProcess.on('error', (error) => {
                    console.error('❌ Browser installation process error:', error);
                    resolve(false);
                });
            });
        }
    } catch (requireError) {
        console.error('❌ Playwright not available:', requireError);
        return false;
    }
}

// Error handling middleware
app.use((error, req, res, next) => {
    console.error('Express error:', error);
    res.status(500).json({ 
        error: 'Internal Server Error', 
        message: error.message,
        timestamp: new Date().toISOString()
    });
});

// Start the server
app.listen(port, () => {
    console.log(`🚀 Playwright Cucumber Framework is running!`);
    console.log(`🌐 Server: http://localhost:${port}`);
    console.log(`📊 Health: http://localhost:${port}/health`);
    console.log(`🎭 Ready to run tests!`);
    console.log(`⏰ Started at: ${new Date().toLocaleString()}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('💤 SIGTERM received, shutting down gracefully...');
    process.exit(0);
});

process.on('SIGINT', () => {
    console.log('💤 SIGINT received, shutting down gracefully...');
    process.exit(0);
});

// Serve test interface
app.get('/test-interface.html', (req, res) => {
    const testInterfacePath = path.join(__dirname, 'test-interface.html');
    if (fs.existsSync(testInterfacePath)) {
        res.sendFile(testInterfacePath);
    } else {
        res.status(404).send('Test interface not found');
    }
});

// Add info endpoint to show available endpoints
app.get('/info', (req, res) => {
    const endpoints = [
        'GET /',
        'GET /health',
        'GET /health?testBrowser=true',
        'GET /test-interface.html',
        'GET /test-results',
        'GET /info',
        'POST /install-browsers',
        'POST /run-tests',
        'POST /run-playwright-web',
        'POST /run-playwright-api',
        'POST /run-playwright-all',
        'GET /logs/:filename'
    ];
    
    res.json({
        message: 'Azure Playwright Test Server',
        version: '1.0.0',
        timestamp: new Date().toISOString(),
        availableEndpoints: endpoints,
        testingUrl: `${req.protocol}://${req.get('host')}/test-interface.html`
    });
});
