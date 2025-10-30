# API Documentation

## Base URL
- **Local Development**: `http://localhost:3000`
- **Production**: `https://your-domain.com`

## Authentication
Currently, the API does not require authentication. In production, consider implementing JWT or OAuth2.

## Endpoints

### Health Check
Check if the service is running and healthy.

**GET** `/health`

**Response:**
```json
{
  "status": "OK",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### Inventory Items

#### Get All Items
Retrieve all inventory items.

**GET** `/api/inventory`

**Response:**
```json
[
  {
    "_id": "65a5f1234567890abcdef123",
    "name": "Laptop Computer",
    "description": "High-performance laptop for development",
    "quantity": 10,
    "price": 999.99,
    "category": "Electronics",
    "createdAt": "2024-01-15T10:00:00.000Z",
    "updatedAt": "2024-01-15T10:00:00.000Z"
  }
]
```

#### Get Single Item
Retrieve a specific inventory item by ID.

**GET** `/api/inventory/:id`

**Parameters:**
- `id` (string): MongoDB ObjectId of the item

**Response:**
```json
{
  "_id": "65a5f1234567890abcdef123",
  "name": "Laptop Computer",
  "description": "High-performance laptop for development",
  "quantity": 10,
  "price": 999.99,
  "category": "Electronics",
  "createdAt": "2024-01-15T10:00:00.000Z",
  "updatedAt": "2024-01-15T10:00:00.000Z"
}
```

**Error Response (404):**
```json
{
  "error": "Item not found"
}
```

#### Create New Item
Add a new item to the inventory.

**POST** `/api/inventory`

**Request Body:**
```json
{
  "name": "Wireless Mouse",
  "description": "Ergonomic wireless mouse with USB receiver",
  "quantity": 25,
  "price": 29.99,
  "category": "Electronics"
}
```

**Response (201):**
```json
{
  "_id": "65a5f1234567890abcdef124",
  "name": "Wireless Mouse",
  "description": "Ergonomic wireless mouse with USB receiver",
  "quantity": 25,
  "price": 29.99,
  "category": "Electronics",
  "createdAt": "2024-01-15T10:30:00.000Z",
  "updatedAt": "2024-01-15T10:30:00.000Z"
}
```

**Validation Rules:**
- `name`: Required, string
- `description`: Required, string
- `quantity`: Required, number ≥ 0
- `price`: Required, number ≥ 0
- `category`: Required, string

#### Update Item
Update an existing inventory item.

**PUT** `/api/inventory/:id`

**Parameters:**
- `id` (string): MongoDB ObjectId of the item

**Request Body:**
```json
{
  "name": "Updated Item Name",
  "description": "Updated description",
  "quantity": 15,
  "price": 39.99,
  "category": "Electronics"
}
```

**Response:**
```json
{
  "_id": "65a5f1234567890abcdef123",
  "name": "Updated Item Name",
  "description": "Updated description",
  "quantity": 15,
  "price": 39.99,
  "category": "Electronics",
  "createdAt": "2024-01-15T10:00:00.000Z",
  "updatedAt": "2024-01-15T11:00:00.000Z"
}
```

#### Delete Item
Remove an item from the inventory.

**DELETE** `/api/inventory/:id`

**Parameters:**
- `id` (string): MongoDB ObjectId of the item

**Response:**
```json
{
  "message": "Item deleted successfully",
  "item": {
    "_id": "65a5f1234567890abcdef123",
    "name": "Deleted Item",
    "description": "This item was deleted",
    "quantity": 5,
    "price": 19.99,
    "category": "Other"
  }
}
```

## Error Responses

### 400 Bad Request
```json
{
  "error": "Validation error message"
}
```

### 404 Not Found
```json
{
  "error": "Item not found"
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal server error message"
}
```

## Data Models

### Inventory Item
```javascript
{
  _id: ObjectId,           // Auto-generated MongoDB ID
  name: String,            // Item name (required)
  description: String,     // Item description (required)
  quantity: Number,        // Available quantity (required, ≥ 0)
  price: Number,          // Item price (required, ≥ 0)
  category: String,       // Item category (required)
  createdAt: Date,        // Auto-generated creation timestamp
  updatedAt: Date         // Auto-updated modification timestamp
}
```

## Categories
Available categories for inventory items:
- Electronics
- Clothing
- Books
- Home & Garden
- Sports
- Other

## Rate Limiting
Currently, no rate limiting is implemented. Consider adding rate limiting in production environments.

## CORS
CORS is enabled for all origins in development. Configure appropriately for production.

## Example Usage

### JavaScript/Fetch
```javascript
// Get all items
const response = await fetch('/api/inventory');
const items = await response.json();

// Create new item
const newItem = {
  name: 'New Product',
  description: 'Product description',
  quantity: 10,
  price: 49.99,
  category: 'Electronics'
};

const response = await fetch('/api/inventory', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(newItem)
});

const createdItem = await response.json();
```

### cURL Examples
```bash
# Get all items
curl -X GET http://localhost:3000/api/inventory

# Create new item
curl -X POST http://localhost:3000/api/inventory \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Item",
    "description": "Test description",
    "quantity": 5,
    "price": 19.99,
    "category": "Other"
  }'

# Update item
curl -X PUT http://localhost:3000/api/inventory/ITEM_ID \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Item",
    "description": "Updated description",
    "quantity": 10,
    "price": 29.99,
    "category": "Electronics"
  }'

# Delete item
curl -X DELETE http://localhost:3000/api/inventory/ITEM_ID
```