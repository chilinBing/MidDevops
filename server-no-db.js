const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(express.static('public'));

// In-memory storage for testing (replace with MongoDB later)
let inventoryItems = [
  {
    _id: '1',
    name: "Laptop Computer",
    description: "High-performance laptop for development work",
    quantity: 15,
    price: 999.99,
    category: "Electronics",
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    _id: '2',
    name: "Office Chair",
    description: "Ergonomic office chair with lumbar support",
    quantity: 8,
    price: 299.99,
    category: "Furniture",
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    _id: '3',
    name: "Wireless Mouse",
    description: "Bluetooth wireless mouse with precision tracking",
    quantity: 25,
    price: 49.99,
    category: "Electronics",
    createdAt: new Date(),
    updatedAt: new Date()
  }
];

let nextId = 4;

console.log('🚀 Starting server without MongoDB (using in-memory storage)');

// Routes

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    database: 'In-Memory Storage (No MongoDB)'
  });
});

// Get all inventory items
app.get('/api/inventory', (req, res) => {
  try {
    res.json(inventoryItems.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt)));
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get single inventory item
app.get('/api/inventory/:id', (req, res) => {
  try {
    const item = inventoryItems.find(item => item._id === req.params.id);
    if (!item) {
      return res.status(404).json({ error: 'Item not found' });
    }
    res.json(item);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create new inventory item
app.post('/api/inventory', (req, res) => {
  try {
    const { name, description, quantity, price, category } = req.body;
    
    // Basic validation
    if (!name || !description || quantity === undefined || price === undefined || !category) {
      return res.status(400).json({ error: 'All fields are required' });
    }
    
    if (quantity < 0 || price < 0) {
      return res.status(400).json({ error: 'Quantity and price must be non-negative' });
    }
    
    const newItem = {
      _id: nextId.toString(),
      name,
      description,
      quantity: parseInt(quantity),
      price: parseFloat(price),
      category,
      createdAt: new Date(),
      updatedAt: new Date()
    };
    
    inventoryItems.push(newItem);
    nextId++;
    
    res.status(201).json(newItem);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Update inventory item
app.put('/api/inventory/:id', (req, res) => {
  try {
    const { name, description, quantity, price, category } = req.body;
    const itemIndex = inventoryItems.findIndex(item => item._id === req.params.id);
    
    if (itemIndex === -1) {
      return res.status(404).json({ error: 'Item not found' });
    }
    
    // Basic validation
    if (!name || !description || quantity === undefined || price === undefined || !category) {
      return res.status(400).json({ error: 'All fields are required' });
    }
    
    if (quantity < 0 || price < 0) {
      return res.status(400).json({ error: 'Quantity and price must be non-negative' });
    }
    
    inventoryItems[itemIndex] = {
      ...inventoryItems[itemIndex],
      name,
      description,
      quantity: parseInt(quantity),
      price: parseFloat(price),
      category,
      updatedAt: new Date()
    };
    
    res.json(inventoryItems[itemIndex]);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Delete inventory item
app.delete('/api/inventory/:id', (req, res) => {
  try {
    const itemIndex = inventoryItems.findIndex(item => item._id === req.params.id);
    
    if (itemIndex === -1) {
      return res.status(404).json({ error: 'Item not found' });
    }
    
    const deletedItem = inventoryItems.splice(itemIndex, 1)[0];
    res.json({ message: 'Item deleted successfully', item: deletedItem });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`✅ Server running on port ${PORT}`);
  console.log(`🌐 Application: http://localhost:${PORT}`);
  console.log(`💾 Storage: In-Memory (${inventoryItems.length} sample items)`);
  console.log(`🔗 API: http://localhost:${PORT}/api/inventory`);
  console.log('\n📝 Note: Using in-memory storage. Data will be lost on restart.');
  console.log('💡 To use MongoDB, set up Docker or install MongoDB locally.');
});