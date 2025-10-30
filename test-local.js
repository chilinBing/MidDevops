// Quick test script to verify API endpoints
const http = require('http');

const testEndpoints = [
  { path: '/health', method: 'GET', description: 'Health check' },
  { path: '/api/inventory', method: 'GET', description: 'Get all inventory items' }
];

function makeRequest(options) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        resolve({
          statusCode: res.statusCode,
          data: data,
          headers: res.headers
        });
      });
    });
    
    req.on('error', reject);
    req.end();
  });
}

async function testAPI() {
  console.log('🧪 Testing API endpoints...\n');
  
  for (const endpoint of testEndpoints) {
    try {
      const options = {
        hostname: 'localhost',
        port: 3000,
        path: endpoint.path,
        method: endpoint.method,
        timeout: 5000
      };
      
      console.log(`Testing ${endpoint.method} ${endpoint.path} - ${endpoint.description}`);
      const response = await makeRequest(options);
      
      if (response.statusCode === 200) {
        console.log(`✅ Success: ${response.statusCode}`);
      } else {
        console.log(`⚠️  Warning: ${response.statusCode}`);
      }
      
      console.log(`Response: ${response.data.substring(0, 100)}...\n`);
      
    } catch (error) {
      console.log(`❌ Error testing ${endpoint.path}: ${error.message}\n`);
    }
  }
}

// Run tests
testAPI().then(() => {
  console.log('🎉 API testing completed!');
}).catch(error => {
  console.error('❌ Test suite failed:', error);
});