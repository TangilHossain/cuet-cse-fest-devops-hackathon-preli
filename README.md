# Hackathon Challenge

Your challenge is to take this simple e-commerce backend and turn it into a fully containerized microservices setup using Docker and solid DevOps practices.

---

## Implementation Documentation

This section documents all the work completed for this hackathon project.

### 1. Docker Containerization

**Production Dockerfiles** (multi-stage builds for backend and gateway)
- Separate build and runtime stages to minimize final image size
- Production images optimized for performance and security

**Development Dockerfiles** (with hot-reload support)
- `tsx watch` for TypeScript backend hot-reload
- `nodemon` for Node.js gateway hot-reload
- Volume mounts for live code changes

**Build Context Optimization**
- Added `.dockerignore` files for backend and gateway
- Excludes: node_modules, logs, dist, .git, .gitignore, README.md
- Significantly reduces build context size

**Image Optimization**
- Multi-stage builds reduce final image sizes
- Alpine-based images for smaller footprint
- Non-root users in production containers

### 2. Docker Compose Configuration

**Development Environment** (`compose.development.yaml`)
- Hot-reload volumes for live code updates
- Health checks on all services
- Full logging output for debugging
- Relaxed resource constraints for development

**Production Environment** (`compose.production.yaml`)
- Security hardening with proper configurations
- Resource limits (CPU: 0.5-1.0, Memory: 256M-1G)
- Network isolation: separate public and internal networks
- Log rotation (10MB max, 3 files per service)
- Restart policies: `on-failure` with retry limits

**Network Isolation**
- Public network: Only Gateway exposed (port 5921)
- Internal network: Backend (3847) and MongoDB (27017) private
- Production: `internal: true` flag prevents external access
- Services communicate via internal Docker network

**Health Checks Configuration**
- Gateway: HTTP GET `/health`
- Backend: HTTP GET `/api/health`  
- MongoDB: Custom MongoDB health check
- Dependency ordering: `depends_on` with `condition: service_healthy`

### 3. Security Implementations

**Network Isolation**
- Production: `internal: true` for internal network
- Only Gateway publicly accessible
- Backend and MongoDB protected from external access

**Container Hardening**
- `no-new-privileges: true` - prevents privilege escalation
- `cap_drop: ALL` - removes all Linux capabilities
- `read_only: true` - read-only root filesystem in production

**Rate Limiting**
- Production: 100 requests/minute (express-rate-limit)
- Development: 1000 requests/minute (permissive for testing)
- Prevents API abuse and DDoS attacks

**Security Headers**
- Helmet middleware for HTTP security headers
- CORS configuration with environment-based restrictions
- Proper content-type validation

**Secret Management**
- `.env` file with 600 permissions (readable only by owner)
- Excluded from git via `.gitignore`
- Environment variable examples: `.env.example`, `.env.production.example`
- No secrets hardcoded in source code

### 4. Data Persistence

**Named Volumes**
- `mongo_data_dev` - Development MongoDB data
- `mongo_data_prod` - Production MongoDB data
- `mongo_config` - MongoDB configuration files
- `node_modules_dev`, `node_modules_prod` - Dependency caching for faster rebuilds

**Persistence Verification**
- Data survives container restarts
- Tested with container stop/start cycles
- Volume data independent of container lifecycle

**Backup Functionality**
- `make db-backup` - Database backup via Makefile
- Backup stored locally for recovery purposes

### 5. Gateway Service Enhancements

**Code Refactoring**
- Reduced cognitive complexity from 21 to <15
- Extracted helper functions for maintainability

**Helper Functions**
- `prepareProxyHeaders()` - Standardize header handling
- `handleProxyError()` - Unified error processing
- `sendGenericError()` - Consistent error responses

**Error Handling**
- ECONNREFUSED - Backend connection refused
- ETIMEDOUT - Connection timeout handling
- Connection pooling issues
- Descriptive error messages for debugging

**Logging & Metrics**
- Request/response logging with timestamps
- Performance metrics for each request
- Error tracking and reporting

**Health Endpoints**
- `/health` - Gateway health status
- `/api/health` - Backend health via gateway proxy
- Proper HTTP status codes (200 for healthy, 503 for unhealthy)

**Graceful Shutdown**
- SIGTERM handler - Clean container shutdown
- SIGINT handler - Keyboard interrupt handling
- Proper resource cleanup on exit

### 6. Production Optimizations

**Build Optimization**
- `npm ci` - Reproducible, locked dependency installation
- `npm cache clean --force` - Reduce image size
- Multi-stage builds - Separate build and runtime

**Resource Management**
- CPU limits: 0.5-1.0 cores per service
- Memory limits: 256M-1G per service
- Production: stricter constraints than development

**Restart Policies**
- Development: `unless-stopped` - restart unless manually stopped
- Production: `on-failure:5` - restart on failure, max 5 retries

**Alpine Images**
- `node:18-alpine` base image
- Smaller footprint (40-50% size reduction)
- Faster deployments

**Non-root Users**
- Production containers run as non-root user
- Reduced security risk from container escape

### 7. Makefile CLI Commands

**Environment Management**
```bash
make dev-up              # Start development with hot-reload
make prod-up             # Start production optimized containers
make dev-down            # Stop development containers
make prod-down           # Stop production containers
make dev-rebuild         # Rebuild dev images
make prod-rebuild        # Rebuild prod images
```

**Service Access**
```bash
make backend-shell       # Interactive shell into backend
make gateway-shell       # Interactive shell into gateway
make mongo-shell         # Connect to MongoDB CLI
```

**Monitoring & Debugging**
```bash
make logs                # Stream logs from all services
make logs-gateway        # Gateway logs only
make logs-backend        # Backend logs only
make logs-mongo          # MongoDB logs only
make health              # Check health of all services
make ps                  # List running containers
```

**Testing Commands**
```bash
make test-gateway        # Test gateway connectivity
make test-backend        # Test backend API
make test-all            # Run all tests
make test-security       # Verify backend not exposed
```

**Database Operations**
```bash
make db-backup           # Backup MongoDB data
make db-reset            # Reset database to clean state
```

**Cleanup Commands**
```bash
make clean               # Remove containers and images
make clean-all           # Remove containers, images, and volumes
make clean-volumes       # Remove named volumes only
```

### 8. Configuration Files

**Updated .gitignore**
- `node_modules/` - Dependencies
- `dist/` - Build output
- `.env` - Environment secrets
- `logs/` - Application logs
- IDE files - .vscode, .idea, etc.

**.env.example**
- Template with placeholders
- Documented variable purposes
- Example values for reference

**.env.production.example**
- Production-specific variables
- Security recommendations
- Resource limit guidelines

**Environment Variables**
- `MONGO_INITDB_ROOT_USERNAME` - Database admin user
- `MONGO_INITDB_ROOT_PASSWORD` - Database admin password
- `MONGO_URI` - MongoDB connection string
- `MONGO_DATABASE` - Database name
- `BACKEND_PORT=3847` - Backend service port
- `GATEWAY_PORT=5921` - Gateway service port
- `NODE_ENV` - Environment (development/production)
- `MONGO_DB_NAME` - Additional database identifier

### 9. Code Quality & Best Practices

**SonarQube Compliance**
- Cognitive complexity reduced from 21 to <15
- Code organization improved
- Proper naming conventions
- DRY principle applied

**TypeScript Configuration**
- Maintained type safety
- Proper type definitions
- Error handling with types

**Error Handling**
- Comprehensive try-catch blocks
- Specific error messages
- Proper HTTP status codes
- Error logging

**Health Checks**
- Comprehensive status reporting
- All services verified
- Dependencies checked
- Recovery time tracked

**Environment-Specific Configuration**
- Different settings for dev vs production
- Resource constraints varied
- Security levels adjusted
- Logging levels appropriate

### 10. Testing & Verification

**Health Checks**
- Gateway `/health` endpoint responding
- Backend `/api/health` accessible via gateway
- MongoDB connectivity verified
- All services reporting healthy status

**API Functionality**
- Product creation working via Gateway
- Product retrieval functioning correctly
- Data stored in MongoDB
- Gateway routing working properly

**Security Verification**
- Backend NOT directly accessible on port 3847
- MongoDB NOT exposed to external network
- Only Gateway accessible on port 5921
- Network isolation confirmed

**Data Persistence**
- Data survives container restarts
- Volumes persist data correctly
- No data loss across stop/start cycles

**Environment Status**
- Development environment fully operational
- Production environment fully operational
- Both environments tested and working
- Health checks passing in both modes

---
---

## Problem Statement

The backend setup consisting of:

- A service for managing products
- A gateway that forwards API requests

The system must be containerized, secure, optimized, and maintain data persistence across container restarts.

## Architecture

```
                    ┌─────────────────┐
                    │   Client/User   │
                    └────────┬────────┘
                             │
                             │ HTTP (port 5921)
                             │
                    ┌────────▼────────┐
                    │    Gateway      │
                    │  (port 5921)    │
                    │   [Exposed]     │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │                 │
         ┌──────────▼──────────┐      │
         │   Private Network   │      │
         │  (Docker Network)   │      │
         └──────────┬──────────┘      │
                    │                 │
         ┌──────────┴──────────┐      │
         │                     │      │
    ┌────▼────┐         ┌──────▼──────┐
    │ Backend │         │   MongoDB   │
    │(port    │◄────────┤  (port      │
    │ 3847)   │         │  27017)     │
    │[Not     │         │ [Not        │
    │Exposed] │         │ Exposed]    │
    └─────────┘         └─────────────┘
```

**Key Points:**
- Gateway is the only service exposed to external clients (port 5921)
- All external requests must go through the Gateway
- Backend and MongoDB should not be exposed to public network

## Project Structure

**DO NOT CHANGE THE PROJECT STRUCTURE.** The following structure must be maintained:

```
.
├── backend/
│   ├── Dockerfile
│   ├── Dockerfile.dev
│   └── src/
├── gateway/
│   ├── Dockerfile
│   ├── Dockerfile.dev
│   └── src/
├── docker/
│   ├── compose.development.yaml
│   └── compose.production.yaml
├── Makefile
└── README.md
```

## Environment Variables

Create a `.env` file in the root directory with the following variables (do not commit actual values):

```env
MONGO_INITDB_ROOT_USERNAME=
MONGO_INITDB_ROOT_PASSWORD=
MONGO_URI=
MONGO_DATABASE=
BACKEND_PORT=3847 # DO NOT CHANGE
GATEWAY_PORT=5921 # DO NOT CHANGE 
NODE_ENV=
```

## Expectations (Open ended, DO YOUR BEST!!!)

- Separate Dev and Prod configs
- Data Persistence
- Follow security basics (limit network exposure, sanitize input) 
- Docker Image Optimization
- Makefile CLI Commands for smooth dev and prod deploy experience (TRY TO COMPLETE THE COMMANDS COMMENTED IN THE Makefile)

**ADD WHAT EVER BEST PRACTICES YOU KNOW**

## Testing

Use the following curl commands to test your implementation.

### Health Checks

Check gateway health:
```bash
curl http://localhost:5921/health
```

Check backend health via gateway:
```bash
curl http://localhost:5921/api/health
```

### Product Management

Create a product:
```bash
curl -X POST http://localhost:5921/api/products \
  -H 'Content-Type: application/json' \
  -d '{"name":"Test Product","price":99.99}'
```

Get all products:
```bash
curl http://localhost:5921/api/products
```

### Security Test

Verify backend is not directly accessible (should fail or be blocked):
```bash
curl http://localhost:3847/api/products
```

## Submission Process

1. **Fork the Repository**
   - Fork this repository to your GitHub account
   - The repository must remain **private** during the contest

2. **Make Repository Public**
   - In the **last 5 minutes** of the contest, make your repository **public**
   - Repositories that remain private after the contest ends will not be evaluated

3. **Submit Repository URL**
   - Submit your repository URL at [arena.bongodev.com](https://arena.bongodev.com)
   - Ensure the URL is correct and accessible

4. **Code Evaluation**
   - All submissions will be both **automated and manually evaluated**
   - Plagiarism and code copying will result in disqualification

## Rules

- **NO COPYING**: All code must be your original work. Copying code from other participants or external sources will result in immediate disqualification.

- **NO POST-CONTEST COMMITS**: Pushing any commits to the git repository after the contest ends will result in **disqualification**. All work must be completed and committed before the contest deadline.

- **Repository Visibility**: Keep your repository private during the contest, then make it public in the last 5 minutes.

- **Submission Deadline**: Ensure your repository is public and submitted before the contest ends.

Good luck!


