#!/bin/bash

# Local Development Setup Script
set -e

echo "🛠️  Setting up local development environment..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Install dependencies
install_dependencies() {
    print_status "Installing Node.js dependencies..."
    npm install
    print_status "Dependencies installed ✓"
}

# Setup MongoDB with Docker
setup_mongodb() {
    print_status "Setting up MongoDB with Docker..."
    
    # Check if MongoDB container is already running
    if docker ps | grep -q "mongodb-local"; then
        print_warning "MongoDB container already running"
    else
        # Run MongoDB container
        docker run -d \
            --name mongodb-local \
            -p 27017:27017 \
            -e MONGO_INITDB_ROOT_USERNAME=admin \
            -e MONGO_INITDB_ROOT_PASSWORD=password123 \
            -e MONGO_INITDB_DATABASE=inventory \
            -v mongodb_data:/data/db \
            mongo:7.0
        
        print_status "MongoDB container started ✓"
    fi
    
    # Wait for MongoDB to be ready
    print_status "Waiting for MongoDB to be ready..."
    sleep 10
}

# Create environment file
create_env_file() {
    if [ ! -f .env ]; then
        print_status "Creating .env file..."
        cp .env.example .env
        print_status ".env file created ✓"
    else
        print_warning ".env file already exists"
    fi
}

# Start development server
start_dev_server() {
    print_status "Starting development server..."
    npm run dev
}

# Main function
main() {
    echo "🏗️  Local Development Setup"
    echo "=========================="
    
    install_dependencies
    create_env_file
    setup_mongodb
    
    read -p "Do you want to start the development server? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        start_dev_server
    else
        print_status "Setup completed! Run 'npm run dev' to start the server."
        print_status "Access the application at: http://localhost:3000"
    fi
}

# Run main function
main "$@"