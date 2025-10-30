class InventoryManager {
    constructor() {
        this.apiBase = '/api/inventory';
        this.currentEditId = null;
        this.initializeEventListeners();
        this.loadInventory();
    }

    initializeEventListeners() {
        // Form submission
        document.getElementById('itemForm').addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleFormSubmit();
        });

        // Refresh button
        document.getElementById('refreshBtn').addEventListener('click', () => {
            this.loadInventory();
        });

        // Cancel edit button
        document.getElementById('cancelBtn').addEventListener('click', () => {
            this.cancelEdit();
        });
    }

    async handleFormSubmit() {
        const formData = this.getFormData();
        
        try {
            if (this.currentEditId) {
                await this.updateItem(this.currentEditId, formData);
                this.showMessage('Item updated successfully!', 'success');
                this.cancelEdit();
            } else {
                await this.createItem(formData);
                this.showMessage('Item added successfully!', 'success');
            }
            
            this.clearForm();
            this.loadInventory();
        } catch (error) {
            this.showMessage(`Error: ${error.message}`, 'error');
        }
    }

    getFormData() {
        return {
            name: document.getElementById('name').value.trim(),
            description: document.getElementById('description').value.trim(),
            quantity: parseInt(document.getElementById('quantity').value),
            price: parseFloat(document.getElementById('price').value),
            category: document.getElementById('category').value
        };
    }

    async createItem(itemData) {
        const response = await fetch(this.apiBase, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(itemData)
        });

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Failed to create item');
        }

        return response.json();
    }

    async updateItem(id, itemData) {
        const response = await fetch(`${this.apiBase}/${id}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(itemData)
        });

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Failed to update item');
        }

        return response.json();
    }

    async deleteItem(id) {
        const response = await fetch(`${this.apiBase}/${id}`, {
            method: 'DELETE'
        });

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Failed to delete item');
        }

        return response.json();
    }

    async loadInventory() {
        const inventoryList = document.getElementById('inventoryList');
        const emptyState = document.getElementById('emptyState');
        
        try {
            inventoryList.innerHTML = '<div class="loading">Loading inventory...</div>';
            
            const response = await fetch(this.apiBase);
            if (!response.ok) {
                throw new Error('Failed to load inventory');
            }
            
            const items = await response.json();
            
            if (items.length === 0) {
                inventoryList.innerHTML = '';
                emptyState.style.display = 'block';
            } else {
                emptyState.style.display = 'none';
                this.renderInventoryItems(items);
            }
        } catch (error) {
            inventoryList.innerHTML = `<div class="error">Error loading inventory: ${error.message}</div>`;
        }
    }

    renderInventoryItems(items) {
        const inventoryList = document.getElementById('inventoryList');
        
        inventoryList.innerHTML = items.map(item => `
            <div class="inventory-item" data-id="${item._id}">
                <div class="item-header">
                    <div class="item-name">${this.escapeHtml(item.name)}</div>
                    <div class="item-category">${this.escapeHtml(item.category)}</div>
                </div>
                
                <div class="item-description">
                    ${this.escapeHtml(item.description)}
                </div>
                
                <div class="item-details">
                    <div class="detail-item">
                        <span class="detail-label">Quantity:</span>
                        <span class="detail-value">${item.quantity}</span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Price:</span>
                        <span class="detail-value">$${item.price.toFixed(2)}</span>
                    </div>
                </div>
                
                <div class="item-actions">
                    <button class="edit-btn" onclick="inventoryManager.editItem('${item._id}')">
                        ✏️ Edit
                    </button>
                    <button class="delete-btn" onclick="inventoryManager.confirmDelete('${item._id}', '${this.escapeHtml(item.name)}')">
                        🗑️ Delete
                    </button>
                </div>
            </div>
        `).join('');
    }

    async editItem(id) {
        try {
            const response = await fetch(`${this.apiBase}/${id}`);
            if (!response.ok) {
                throw new Error('Failed to load item details');
            }
            
            const item = await response.json();
            this.populateForm(item);
            this.currentEditId = id;
            
            // Update UI
            document.getElementById('submitBtn').textContent = 'Update Item';
            document.getElementById('cancelBtn').style.display = 'inline-block';
            
            // Scroll to form
            document.querySelector('.form-section').scrollIntoView({ behavior: 'smooth' });
        } catch (error) {
            this.showMessage(`Error loading item: ${error.message}`, 'error');
        }
    }

    populateForm(item) {
        document.getElementById('name').value = item.name;
        document.getElementById('description').value = item.description;
        document.getElementById('quantity').value = item.quantity;
        document.getElementById('price').value = item.price;
        document.getElementById('category').value = item.category;
    }

    cancelEdit() {
        this.currentEditId = null;
        document.getElementById('submitBtn').textContent = 'Add Item';
        document.getElementById('cancelBtn').style.display = 'none';
        this.clearForm();
    }

    async confirmDelete(id, itemName) {
        if (confirm(`Are you sure you want to delete "${itemName}"?`)) {
            try {
                await this.deleteItem(id);
                this.showMessage('Item deleted successfully!', 'success');
                this.loadInventory();
            } catch (error) {
                this.showMessage(`Error deleting item: ${error.message}`, 'error');
            }
        }
    }

    clearForm() {
        document.getElementById('itemForm').reset();
    }

    showMessage(message, type) {
        // Create a simple toast notification
        const toast = document.createElement('div');
        toast.className = `toast toast-${type}`;
        toast.textContent = message;
        toast.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 12px 20px;
            border-radius: 8px;
            color: white;
            font-weight: 600;
            z-index: 1000;
            animation: slideIn 0.3s ease;
            background: ${type === 'success' ? '#38a169' : '#e53e3e'};
        `;
        
        document.body.appendChild(toast);
        
        setTimeout(() => {
            toast.style.animation = 'slideOut 0.3s ease';
            setTimeout(() => {
                document.body.removeChild(toast);
            }, 300);
        }, 3000);
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// Add CSS animations
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    
    @keyframes slideOut {
        from { transform: translateX(0); opacity: 1; }
        to { transform: translateX(100%); opacity: 0; }
    }
`;
document.head.appendChild(style);

// Initialize the application
const inventoryManager = new InventoryManager();