const http = require('http');

console.log('🧪 Testing application endpoints...');

function testEndpoint(path, description) {
  return new Promise((resolve) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: path,
      method: 'GET',
      timeout: 5000
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        console.log(`✅ ${description}: ${res.statusCode}`);
        if (data) {
          console.log(`   Response: ${data.substring(0, 100)}...`);
        }
        resolve();
      });
    });

    req.on('error', (error) => {
      console.log(`❌ ${description}: ${error.message}`);
      resolve();
    });

    req.end();
  });
}

async function runTests() {
  await testEndpoint('/health', 'Health Check');
  await testEndpoint('/api/inventory', 'Get Inventory');
  console.log('\n🎉 Testing completed!');
  console.log('🌐 Open your browser and go to: http://localhost:3000');
}

runTests();