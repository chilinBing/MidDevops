#!/bin/bash

# Docker MongoDB Setup Script for Inventory Management System
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}[DOCKER]${NC} $1"
}

# Check if Docker is running
check_docker() {
    print_status "Checking Docker installation..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    
    print_status "Docker is running ✓"
}

# Check if Docker Compose is available
check_docker_compose() {
    print_status "Checking Docker Compose..."
    
    if docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
    elif command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    else
        print_error "Docker Compose is not available"
        exit 1
    fi
    
    print_status "Docker Compose available: $COMPOSE_CMD ✓"
}

# Setup environment file
setup_env() {
    print_status "Setting up environment configuration..."
    
    if [ ! -f .env ]; then
        cp .env.example .env
        print_status "Created .env file from template"
        
        # Update .env for Docker Compose
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sed -i '' 's|MONGODB_URI=mongodb://localhost:27017/inventory|MONGODB_URI=mongodb://admin:password123@mongodb:27017/inventory?authSource=admin|g' .env
        else
            # Linux
            sed -i 's|MONGODB_URI=mongodb://localhost:27017/inventory|MONGODB_URI=mongodb://admin:password123@mongodb:27017/inventory?authSource=admin|g' .env
        fi
        
        print_status "Updated .env for Docker Compose"
    else
        print_warning ".env file already exists"
    fi
}

# Clean up existing containers
cleanup_containers() {
    print_status "Cleaning up existing containers..."
    
    # Stop and remove containers if they exist
    docker stop inventory-mongodb inventory-app 2>/dev/null || true
    docker rm inventory-mongodb inventory-app 2>/dev/null || true
    
    print_status "Cleanup completed"
}

# Start services with Docker Compose
start_services() {
    print_header "Starting services with Docker Compose..."
    
    # Build and start services
    $COMPOSE_CMD up --build -d
    
    print_status "Services started successfully!"
}

# Wait for services to be ready
wait_for_services() {
    print_status "Waiting for services to be ready..."
    
    # Wait for MongoDB
    print_status "Waiting for MongoDB to be ready..."
    timeout=60
    while [ $timeout -gt 0 ]; do
        if docker exec inventory-mongodb mongosh --eval "db.adminCommand('ping')" --quiet &>/dev/null; then
            print_status "MongoDB is ready ✓"
            break
        fi
        sleep 2
        timeout=$((timeout-2))
    done
    
    if [ $timeout -le 0 ]; then
        print_error "MongoDB failed to start within 60 seconds"
        exit 1
    fi
    
    # Wait for Application
    print_status "Waiting for application to be ready..."
    timeout=60
    while [ $timeout -gt 0 ]; do
        if curl -f http://localhost:3000/health &>/dev/null; then
            print_status "Application is ready ✓"
            break
        fi
        sleep 2
        timeout=$((timeout-2))
    done
    
    if [ $timeout -le 0 ]; then
        print_error "Application failed to start within 60 seconds"
        exit 1
    fi
}

# Show service status
show_status() {
    print_header "Service Status:"
    $COMPOSE_CMD ps
    
    echo ""
    print_header "Application URLs:"
    echo "🌐 Application: http://localhost:3000"
    echo "🗄️  MongoDB: mongodb://admin:password123@localhost:27017/inventory?authSource=admin"
    
    echo ""
    print_header "Useful Commands:"
    echo "📊 View logs: $COMPOSE_CMD logs -f"
    echo "🔍 MongoDB shell: docker exec -it inventory-mongodb mongosh -u admin -p password123 --authenticationDatabase admin"
    echo "🛑 Stop services: $COMPOSE_CMD down"
    echo "🗑️  Remove volumes: $COMPOSE_CMD down -v"
}

# Test the application
test_application() {
    print_status "Testing application endpoints..."
    
    # Test health endpoint
    if curl -f http://localhost:3000/health &>/dev/null; then
        print_status "Health check: ✓"
    else
        print_error "Health check failed"
    fi
    
    # Test API endpoint
    if curl -f http://localhost:3000/api/inventory &>/dev/null; then
        print_status "API endpoint: ✓"
    else
        print_error "API endpoint failed"
    fi
}

# Main function
main() {
    echo "🐳 Docker MongoDB Setup for Inventory Management System"
    echo "======================================================"
    
    check_docker
    check_docker_compose
    setup_env
    
    read -p "Do you want to clean up existing containers? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cleanup_containers
    fi
    
    start_services
    wait_for_services
    test_application
    show_status
    
    echo ""
    print_status "🎉 Setup completed successfully!"
    print_status "Your inventory management system is now running with Docker!"
}

# Handle script interruption
trap 'echo -e "\n${RED}Setup interrupted${NC}"; exit 1' INT

# Run main function
main "$@"