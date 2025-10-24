#!/bin/bash
# CSR Generator - One-Command Launcher
# This script builds and runs the CSR generator with a single command

set -e

echo "🔐 CSR Generator - Starting..."
echo

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed"
    echo "Please install Docker from https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if container is already running
if docker ps -a --format '{{.Names}}' | grep -q '^csr-generator$'; then
    echo "⚠️  Container 'csr-generator' already exists"
    read -p "Do you want to remove it and start fresh? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  Removing existing container..."
        docker rm -f csr-generator
    else
        echo "ℹ️  Starting existing container..."
        docker start csr-generator
        echo
        echo "✅ CSR Generator is running!"
        echo "🌐 Access it at: http://localhost:5000"
        exit 0
    fi
fi

# Build the Docker image
echo "🔨 Building Docker image..."
docker build -t csr-generator . -q

# Create output directory if it doesn't exist
mkdir -p output

# Run the container
echo "🚀 Starting CSR Generator..."
docker run -d \
    -p 5000:5000 \
    -v "$(pwd)/output:/app/output" \
    --name csr-generator \
    csr-generator

# Wait for the application to start
echo "⏳ Waiting for application to start..."
sleep 3

# Check if the container is running
if docker ps --format '{{.Names}}' | grep -q '^csr-generator$'; then
    echo
    echo "✅ CSR Generator is running!"
    echo "🌐 Access it at: http://localhost:5000"
    echo
    echo "Commands:"
    echo "  Stop:    docker stop csr-generator"
    echo "  Start:   docker start csr-generator"
    echo "  Logs:    docker logs csr-generator"
    echo "  Remove:  docker rm -f csr-generator"
    echo
    echo "📁 Generated CSR files will be saved in: $(pwd)/output"
else
    echo "❌ Error: Container failed to start"
    echo "Check logs with: docker logs csr-generator"
    exit 1
fi
