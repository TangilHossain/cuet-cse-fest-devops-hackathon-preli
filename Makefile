# Makefile for CUET CSE Fest DevOps Hackathon
# Gateway Microservices Architecture
# =============================================================================

.PHONY: help
.DEFAULT_GOAL := help

# Environment files
ENV_FILE := .env
DEV_COMPOSE := docker/compose.development.yaml
PROD_COMPOSE := docker/compose.production.yaml

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

# =============================================================================
# Help / Documentation
# =============================================================================

help: ## Display this help message
	@echo "$(BLUE)CUET CSE Fest DevOps Hackathon - Makefile Commands$(NC)"
	@echo "======================================================"
	@echo ""
	@echo "$(GREEN)Development Commands:$(NC)"
	@echo "  make dev-up              - Start development environment"
	@echo "  make dev-down            - Stop development environment"
	@echo "  make dev-build           - Build development containers"
	@echo "  make dev-logs            - View all development logs"
	@echo "  make dev-restart         - Restart development services"
	@echo "  make dev-ps              - Show running development containers"
	@echo ""
	@echo "$(GREEN)Production Commands:$(NC)"
	@echo "  make prod-up             - Start production environment"
	@echo "  make prod-down           - Stop production environment"
	@echo "  make prod-build          - Build production containers"
	@echo "  make prod-logs           - View all production logs"
	@echo "  make prod-restart        - Restart production services"
	@echo "  make prod-ps             - Show running production containers"
	@echo ""
	@echo "$(GREEN)Gateway Commands:$(NC)"
	@echo "  make gateway-dev-up      - Start gateway in development"
	@echo "  make gateway-dev-down    - Stop gateway in development"
	@echo "  make gateway-dev-logs    - View gateway development logs"
	@echo "  make gateway-dev-rebuild - Rebuild gateway development container"
	@echo "  make gateway-prod-build  - Build gateway production image"
	@echo "  make gateway-prod-up     - Start gateway in production"
	@echo "  make gateway-prod-down   - Stop gateway in production"
	@echo "  make gateway-prod-logs   - View gateway production logs"
	@echo "  make gateway-health      - Check gateway health"
	@echo "  make gateway-restart     - Restart gateway service"
	@echo "  make gateway-shell       - Open shell in gateway container"
	@echo ""
	@echo "$(GREEN)Backend Commands:$(NC)"
	@echo "  make backend-shell       - Open shell in backend container"
	@echo "  make backend-logs        - View backend logs"
	@echo "  make backend-restart     - Restart backend service"
	@echo "  make backend-build       - Build backend TypeScript"
	@echo "  make backend-type-check  - Type check backend code"
	@echo ""
	@echo "$(GREEN)Database Commands:$(NC)"
	@echo "  make mongo-shell         - Open MongoDB shell"
	@echo "  make db-reset            - Reset MongoDB database"
	@echo "  make db-backup           - Backup MongoDB database"
	@echo ""
	@echo "$(GREEN)Testing Commands:$(NC)"
	@echo "  make test-gateway        - Test gateway endpoints"
	@echo "  make test-backend        - Test backend via gateway"
	@echo "  make test-all            - Run all tests"
	@echo ""
	@echo "$(GREEN)Cleanup Commands:$(NC)"
	@echo "  make clean               - Remove containers and networks"
	@echo "  make clean-all           - Remove everything including volumes"
	@echo "  make clean-volumes       - Remove all volumes"
	@echo ""
	@echo "$(GREEN)Utility Commands:$(NC)"
	@echo "  make status              - Show status of all services"
	@echo "  make health              - Check health of all services"
	@echo "  make logs                - View logs for all services"
	@echo ""

# =============================================================================
# Development Environment
# =============================================================================

dev-up: ## Start development environment
	@echo "$(GREEN)Starting development environment...$(NC)"
	docker compose -f $(DEV_COMPOSE) --env-file $(ENV_FILE) up -d
	@echo "$(GREEN)Development environment started!$(NC)"
	@echo "Gateway available at: http://localhost:5921"

dev-down: ## Stop development environment
	@echo "$(YELLOW)Stopping development environment...$(NC)"
	docker compose -f $(DEV_COMPOSE) down

dev-build: ## Build development containers
	@echo "$(GREEN)Building development containers...$(NC)"
	docker compose -f $(DEV_COMPOSE) --env-file $(ENV_FILE) build

dev-logs: ## View development logs
	docker compose -f $(DEV_COMPOSE) logs -f

dev-restart: ## Restart development services
	@echo "$(YELLOW)Restarting development services...$(NC)"
	docker compose -f $(DEV_COMPOSE) restart

dev-ps: ## Show running development containers
	docker compose -f $(DEV_COMPOSE) ps

# =============================================================================
# Production Environment
# =============================================================================

prod-up: ## Start production environment
	@echo "$(GREEN)Starting production environment...$(NC)"
	docker compose -f $(PROD_COMPOSE) --env-file $(ENV_FILE) up -d
	@echo "$(GREEN)Production environment started!$(NC)"
	@echo "Gateway available at: http://localhost:5921"

prod-down: ## Stop production environment
	@echo "$(YELLOW)Stopping production environment...$(NC)"
	docker compose -f $(PROD_COMPOSE) down

prod-build: ## Build production containers
	@echo "$(GREEN)Building production containers...$(NC)"
	docker compose -f $(PROD_COMPOSE) --env-file $(ENV_FILE) build

prod-logs: ## View production logs
	docker compose -f $(PROD_COMPOSE) logs -f

prod-restart: ## Restart production services
	@echo "$(YELLOW)Restarting production services...$(NC)"
	docker compose -f $(PROD_COMPOSE) restart

prod-ps: ## Show running production containers
	docker compose -f $(PROD_COMPOSE) ps

# =============================================================================
# Gateway Service Commands
# =============================================================================

gateway-dev-up: ## Start gateway in development
	@echo "$(GREEN)Starting gateway (development)...$(NC)"
	docker compose -f $(DEV_COMPOSE) --env-file $(ENV_FILE) up -d gateway

gateway-dev-down: ## Stop gateway in development
	docker compose -f $(DEV_COMPOSE) stop gateway

gateway-dev-logs: ## View gateway development logs
	docker compose -f $(DEV_COMPOSE) logs -f gateway

gateway-dev-rebuild: ## Rebuild gateway development container
	@echo "$(GREEN)Rebuilding gateway (development)...$(NC)"
	docker compose -f $(DEV_COMPOSE) --env-file $(ENV_FILE) up -d --build gateway

gateway-prod-build: ## Build gateway production image
	@echo "$(GREEN)Building gateway (production)...$(NC)"
	docker compose -f $(PROD_COMPOSE) --env-file $(ENV_FILE) build gateway

gateway-prod-up: ## Start gateway in production
	@echo "$(GREEN)Starting gateway (production)...$(NC)"
	docker compose -f $(PROD_COMPOSE) --env-file $(ENV_FILE) up -d gateway

gateway-prod-down: ## Stop gateway in production
	docker compose -f $(PROD_COMPOSE) stop gateway

gateway-prod-logs: ## View gateway production logs
	docker compose -f $(PROD_COMPOSE) logs -f gateway

gateway-health: ## Check gateway health
	@echo "$(BLUE)Checking gateway health...$(NC)"
	@curl -s http://localhost:5921/health | jq . || echo "$(RED)Gateway not responding$(NC)"

gateway-restart: ## Restart gateway service
	@echo "$(YELLOW)Restarting gateway...$(NC)"
	docker compose -f $(DEV_COMPOSE) restart gateway

gateway-shell: ## Open shell in gateway container
	@echo "$(BLUE)Opening shell in gateway container...$(NC)"
	docker compose -f $(DEV_COMPOSE) exec gateway sh

# =============================================================================
# Backend Service Commands
# =============================================================================

backend-shell: ## Open shell in backend container
	@echo "$(BLUE)Opening shell in backend container...$(NC)"
	docker compose -f $(DEV_COMPOSE) exec backend sh

backend-logs: ## View backend logs
	docker compose -f $(DEV_COMPOSE) logs -f backend

backend-restart: ## Restart backend service
	@echo "$(YELLOW)Restarting backend...$(NC)"
	docker compose -f $(DEV_COMPOSE) restart backend

backend-build: ## Build backend TypeScript
	@echo "$(GREEN)Building backend TypeScript...$(NC)"
	cd backend && npm run build

backend-type-check: ## Type check backend code
	@echo "$(BLUE)Type checking backend...$(NC)"
	cd backend && npm run type-check

# =============================================================================
# Database Commands
# =============================================================================

mongo-shell: ## Open MongoDB shell
	@echo "$(BLUE)Opening MongoDB shell...$(NC)"
	docker compose -f $(DEV_COMPOSE) exec mongo mongosh -u $${MONGO_INITDB_ROOT_USERNAME} -p $${MONGO_INITDB_ROOT_PASSWORD} --authenticationDatabase admin

db-reset: ## Reset MongoDB database (WARNING: deletes all data)
	@echo "$(RED)WARNING: This will delete all data!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker compose -f $(DEV_COMPOSE) exec mongo mongosh -u $${MONGO_INITDB_ROOT_USERNAME} -p $${MONGO_INITDB_ROOT_PASSWORD} --authenticationDatabase admin --eval "db.getSiblingDB('$${MONGO_DB_NAME}').dropDatabase()"; \
		echo "$(GREEN)Database reset complete$(NC)"; \
	fi

db-backup: ## Backup MongoDB database
	@echo "$(GREEN)Backing up MongoDB...$(NC)"
	@mkdir -p backups
	docker compose -f $(DEV_COMPOSE) exec mongo mongodump --username $${MONGO_INITDB_ROOT_USERNAME} --password $${MONGO_INITDB_ROOT_PASSWORD} --authenticationDatabase admin --db $${MONGO_DB_NAME} --out /tmp/backup
	docker compose -f $(DEV_COMPOSE) cp mongo:/tmp/backup ./backups/backup-$$(date +%Y%m%d-%H%M%S)
	@echo "$(GREEN)Backup complete$(NC)"

# =============================================================================
# Testing Commands
# =============================================================================

test-gateway: ## Test gateway endpoints
	@echo "$(BLUE)Testing gateway endpoints...$(NC)"
	@echo "\n$(GREEN)1. Testing gateway health:$(NC)"
	curl -s http://localhost:5921/health | jq .
	@echo "\n$(GREEN)2. Testing backend health via gateway:$(NC)"
	curl -s http://localhost:5921/api/health | jq .

test-backend: ## Test backend via gateway
	@echo "$(BLUE)Testing backend via gateway...$(NC)"
	@echo "\n$(GREEN)1. Creating test product:$(NC)"
	curl -X POST http://localhost:5921/api/products \
		-H "Content-Type: application/json" \
		-d '{"name":"Test Product","price":99.99}' | jq .
	@echo "\n$(GREEN)2. Fetching all products:$(NC)"
	curl -s http://localhost:5921/api/products | jq .

test-all: test-gateway test-backend ## Run all tests
	@echo "$(GREEN)All tests completed!$(NC)"

# =============================================================================
# Cleanup Commands
# =============================================================================

clean: ## Remove containers and networks
	@echo "$(YELLOW)Cleaning up containers and networks...$(NC)"
	docker compose -f $(DEV_COMPOSE) down
	docker compose -f $(PROD_COMPOSE) down
	@echo "$(GREEN)Cleanup complete$(NC)"

clean-all: ## Remove everything including volumes and images
	@echo "$(RED)WARNING: This will remove all data!$(NC)"
	docker compose -f $(DEV_COMPOSE) down -v --rmi all
	docker compose -f $(PROD_COMPOSE) down -v --rmi all
	@echo "$(GREEN)Complete cleanup done$(NC)"

clean-volumes: ## Remove all volumes
	@echo "$(YELLOW)Removing volumes...$(NC)"
	docker compose -f $(DEV_COMPOSE) down -v
	docker compose -f $(PROD_COMPOSE) down -v
	@echo "$(GREEN)Volumes removed$(NC)"

# =============================================================================
# Utility Commands
# =============================================================================

status: dev-ps ## Show status of all services

health: ## Check health of all services
	@echo "$(BLUE)Checking service health...$(NC)"
	@echo "\n$(GREEN)Gateway:$(NC)"
	@curl -s http://localhost:5921/health | jq . || echo "$(RED)Not responding$(NC)"
	@echo "\n$(GREEN)Backend (via gateway):$(NC)"
	@curl -s http://localhost:5921/api/health | jq . || echo "$(RED)Not responding$(NC)"

logs: ## View logs for all services
	docker compose -f $(DEV_COMPOSE) logs -f

# =============================================================================
# Quick Start Aliases
# =============================================================================

start: dev-up ## Alias for dev-up

stop: dev-down ## Alias for dev-down

restart: dev-restart ## Alias for dev-restart

build: dev-build ## Alias for dev-build
