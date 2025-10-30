// MongoDB initialization script
// This script runs when the MongoDB container starts for the first time

// Switch to the inventory database
db = db.getSiblingDB('inventory');

// Create a user for the inventory database
db.createUser({
  user: 'inventoryuser',
  pwd: 'inventorypass',
  roles: [
    {
      role: 'readWrite',
      db: 'inventory'
    }
  ]
});

// Create initial collections with indexes
db.createCollection('inventoryitems');

// Create indexes for better performance
db.inventoryitems.createIndex({ "name": 1 });
db.inventoryitems.createIndex({ "category": 1 });
db.inventoryitems.createIndex({ "createdAt": -1 });

// Insert sample data
db.inventoryitems.insertMany([
  {
    name: "Laptop Computer",
    description: "High-performance laptop for development work",
    quantity: 15,
    price: 999.99,
    category: "Electronics",
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    name: "Office Chair",
    description: "Ergonomic office chair with lumbar support",
    quantity: 8,
    price: 299.99,
    category: "Furniture",
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    name: "Wireless Mouse",
    description: "Bluetooth wireless mouse with precision tracking",
    quantity: 25,
    price: 49.99,
    category: "Electronics",
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    name: "Programming Book",
    description: "Complete guide to modern JavaScript development",
    quantity: 12,
    price: 39.99,
    category: "Books",
    createdAt: new Date(),
    updatedAt: new Date()
  }
]);

print('Database initialized with sample data');
print('Collections created: ' + db.getCollectionNames());
print('Sample items count: ' + db.inventoryitems.countDocuments());