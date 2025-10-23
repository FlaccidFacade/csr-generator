.PHONY: help run start stop restart logs clean build test

help: ## Show this help message
	@echo "CSR Generator - Docker Commands"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

run: ## Build and run the CSR generator (one command)
	@./run.sh

start: ## Start existing container
	@echo "Starting CSR Generator..."
	@docker start csr-generator
	@echo "✅ Running at http://localhost:5000"

stop: ## Stop the container
	@echo "Stopping CSR Generator..."
	@docker stop csr-generator

restart: ## Restart the container
	@echo "Restarting CSR Generator..."
	@docker restart csr-generator
	@echo "✅ Running at http://localhost:5000"

logs: ## View container logs
	@docker logs -f csr-generator

clean: ## Remove container and image
	@echo "Cleaning up..."
	@docker rm -f csr-generator 2>/dev/null || true
	@docker rmi csr-generator 2>/dev/null || true
	@echo "✅ Cleaned up"

build: ## Build the Docker image
	@echo "Building Docker image..."
	@docker build -t csr-generator .
	@echo "✅ Build complete"

test: ## Run tests
	@./test.sh

docker-compose-up: ## Run with docker-compose
	@docker-compose up -d
	@echo "✅ Running at http://localhost:5000"

docker-compose-down: ## Stop docker-compose
	@docker-compose down
