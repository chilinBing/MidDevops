// Test MongoDB connection script
const mongoose = require('mongoose');
require('dotenv').config();

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://admin:password123@localhost:27017/inventory?authSource=admin';

console.log('🧪 Testing MongoDB Connection...');
console.log('📍 Connection URI:', MONGODB_URI.replace(/\/\/.*@/, '//***:***@'));

async function testConnection() {
  try {
    console.log('🔄 Connecting to MongoDB...');
    
    await mongoose.connect(MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 5000,
    });
    
    console.log('✅ Successfully connected to MongoDB!');
    console.log('📊 Database:', mongoose.connection.name);
    console.log('🏠 Host:', mongoose.connection.host);
    console.log('🔌 Port:', mongoose.connection.port);
    
    // Test basic operations
    console.log('\n🧪 Testing basic operations...');
    
    // Create a test collection
    const TestModel = mongoose.model('Test', new mongoose.Schema({
      message: String,
      timestamp: { type: Date, default: Date.now }
    }));
    
    // Insert test document
    const testDoc = new TestModel({ message: 'Connection test successful!' });
    await testDoc.save();
    console.log('✅ Insert operation: SUCCESS');
    
    // Read test document
    const foundDoc = await TestModel.findOne({ message: 'Connection test successful!' });
    console.log('✅ Read operation: SUCCESS');
    console.log('📄 Document:', foundDoc.message);
    
    // Clean up test document
    await TestModel.deleteOne({ _id: foundDoc._id });
    console.log('✅ Delete operation: SUCCESS');
    
    // Test inventory collection
    console.log('\n📦 Checking inventory collection...');
    const collections = await mongoose.connection.db.listCollections().toArray();
    const inventoryCollection = collections.find(col => col.name === 'inventoryitems');
    
    if (inventoryCollection) {
      const count = await mongoose.connection.db.collection('inventoryitems').countDocuments();
      console.log(`✅ Inventory collection exists with ${count} items`);
    } else {
      console.log('ℹ️  Inventory collection not found (will be created on first use)');
    }
    
    console.log('\n🎉 All tests passed! MongoDB is ready for use.');
    
  } catch (error) {
    console.error('❌ MongoDB connection failed:');
    console.error('Error:', error.message);
    
    if (error.message.includes('ECONNREFUSED')) {
      console.log('\n💡 Troubleshooting tips:');
      console.log('1. Make sure MongoDB is running: docker compose up -d mongodb');
      console.log('2. Check if port 27017 is available: netstat -an | grep 27017');
      console.log('3. Verify Docker containers: docker ps');
    }
    
    if (error.message.includes('Authentication failed')) {
      console.log('\n💡 Authentication troubleshooting:');
      console.log('1. Check username/password in connection string');
      console.log('2. Verify MongoDB user exists: docker exec -it inventory-mongodb mongosh');
      console.log('3. Check authSource parameter in connection string');
    }
    
    process.exit(1);
  } finally {
    await mongoose.connection.close();
    console.log('🔌 Connection closed');
  }
}

// Handle script interruption
process.on('SIGINT', async () => {
  console.log('\n⚠️  Test interrupted');
  await mongoose.connection.close();
  process.exit(0);
});

// Run the test
testConnection();