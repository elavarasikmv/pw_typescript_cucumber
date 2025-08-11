const { request } = require('playwright');

async function runApiTest() {
    console.log('🌐 Starting API Test...');
    
    let requestContext = null;
    try {
        requestContext = await request.newContext({
            timeout: 30000,
            ignoreHTTPSErrors: true  // Ignore SSL certificate issues
        });
        
        console.log('📡 Testing GET request to JSONPlaceholder...');
        const getResponse = await requestContext.get('https://jsonplaceholder.typicode.com/posts/1');
        console.log(`✅ GET status: ${getResponse.status()}`);
        
        const getData = await getResponse.json();
        console.log(`✅ GET data title: "${getData.title}"`);
        console.log(`✅ GET data userId: ${getData.userId}`);
        
        console.log('📤 Testing POST request...');
        const postResponse = await requestContext.post('https://jsonplaceholder.typicode.com/posts', {
            data: {
                title: 'Azure Playwright Test',
                body: 'Testing API from Azure App Service',
                userId: 1
            }
        });
        console.log(`✅ POST status: ${postResponse.status()}`);
        
        const postData = await postResponse.json();
        console.log(`✅ POST response ID: ${postData.id}`);
        
        console.log('🔍 Testing GET all posts...');
        const allPostsResponse = await requestContext.get('https://jsonplaceholder.typicode.com/posts');
        const allPosts = await allPostsResponse.json();
        console.log(`✅ Total posts retrieved: ${allPosts.length}`);
        
        console.log('✅ API Test completed successfully!');
        return { 
            success: true, 
            message: 'API test passed',
            details: {
                getStatus: getResponse.status(),
                postStatus: postResponse.status(),
                totalPosts: allPosts.length,
                sampleTitle: getData.title
            }
        };
        
    } catch (error) {
        console.error('❌ API Test failed:', error.message);
        return { 
            success: false, 
            error: error.message,
            stack: error.stack
        };
    } finally {
        if (requestContext) {
            await requestContext.dispose();
        }
    }
}

async function runHealthCheckTest() {
    console.log('🏥 Starting Health Check Test...');
    
    let requestContext = null;
    try {
        requestContext = await request.newContext({
            ignoreHTTPSErrors: true  // Ignore SSL certificate issues
        });
        
        // Test our own Azure service
        console.log('📡 Testing our Azure App Service health...');
        const healthResponse = await requestContext.get('https://cts-vibeappwe6512-4.azurewebsites.net/');
        console.log(`✅ Health check status: ${healthResponse.status()}`);
        
        const healthData = await healthResponse.json();
        console.log(`✅ App status: ${healthData.status}`);
        console.log(`✅ App message: ${healthData.message}`);
        
        // Test system info endpoint
        console.log('💻 Testing system info endpoint...');
        const infoResponse = await requestContext.get('https://cts-vibeappwe6512-4.azurewebsites.net/info');
        const infoData = await infoResponse.json();
        console.log(`✅ Node.js version: ${infoData.nodeVersion}`);
        console.log(`✅ Platform: ${infoData.platform}`);
        
        console.log('✅ Health Check Test completed successfully!');
        return { 
            success: true, 
            message: 'Health check test passed',
            details: {
                appStatus: healthData.status,
                nodeVersion: infoData.nodeVersion,
                platform: infoData.platform
            }
        };
        
    } catch (error) {
        console.error('❌ Health Check Test failed:', error.message);
        return { 
            success: false, 
            error: error.message 
        };
    } finally {
        if (requestContext) {
            await requestContext.dispose();
        }
    }
}

module.exports = { runApiTest, runHealthCheckTest };
