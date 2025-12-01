const express = require('express');
const axios = require('axios');
const helmet = require('helmet');
const cors = require('cors');
const rateLimit = require('express-rate-limit');

const app = express();

// Load configuration from environment variables
const GATEWAY_PORT = process.env.GATEWAY_PORT || 5921;
const BACKEND_PORT = process.env.BACKEND_PORT || 3800;
const BACKEND_BASE_URL = process.env.BACKEND_URL || `http://backend:${BACKEND_PORT}`;
const NODE_ENV = process.env.NODE_ENV || 'development';

// Security: Helmet middleware for security headers
app.use(helmet({
  contentSecurityPolicy: false, // Allow for API gateway
  xPoweredBy: false
}));

// CORS configuration - restrict in production
const corsOptions = {
  origin: NODE_ENV === 'production' 
    ? ['http://localhost:5921'] // Adjust for production domains
    : '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization']
};
app.use(cors(corsOptions));

// Rate limiting - protect against abuse
const limiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: NODE_ENV === 'production' ? 100 : 1000, // Limit requests per window
  message: {
    error: 'Too many requests',
    message: 'Please try again later'
  },
  standardHeaders: true,
  legacyHeaders: false
});
app.use(limiter);

// JSON parsing middleware with size limit
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request logging middleware
app.use((req, res, next) => {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] ${req.method} ${req.url} - IP: ${req.ip}`);
  next();
});

/**
 * Proxy request handler - forwards requests to backend service
 */
async function proxyRequest(req, res) {
  const startTime = Date.now();
  
  // Forward request to backend (keep /api prefix as backend expects it)
  const backendPath = req.url;
  const targetUrl = `${BACKEND_BASE_URL}${backendPath}`;

  try {
    console.log(`[PROXY] ${req.method} ${req.url} -> ${targetUrl}`);

    // Prepare headers for backend request
    const headers = {
      'Content-Type': req.headers['content-type'] || 'application/json'
    };

    // Forward client information headers
    if (req.ip) {
      headers['X-Forwarded-For'] = req.ip;
    }
    headers['X-Forwarded-Proto'] = req.protocol;
    headers['X-Forwarded-Host'] = req.hostname;

    // Make request to backend
    const response = await axios({
      method: req.method,
      url: targetUrl,
      params: req.query,
      data: req.body,
      headers,
      timeout: 30000, // 30 second timeout
      validateStatus: () => true, // Accept all status codes
      maxContentLength: 50 * 1024 * 1024, // 50MB
      maxBodyLength: 50 * 1024 * 1024
    });

    const duration = Date.now() - startTime;
    console.log(`[PROXY] ${req.method} ${req.url} <- ${response.status} (${duration}ms)`);

    // Forward response status and headers
    res.status(response.status);
    
    const headersToForward = ['content-type', 'content-length'];
    for (const header of headersToForward) {
      if (response.headers[header]) {
        res.setHeader(header, response.headers[header]);
      }
    }

    // Send response data
    res.json(response.data);
    
  } catch (error) {
    const duration = Date.now() - startTime;
    
    // Log error details (sanitize in production)
    if (NODE_ENV === 'development') {
      console.error('[PROXY ERROR]', {
        message: error.message,
        code: error.code,
        url: targetUrl,
        duration: `${duration}ms`
      });
    } else {
      console.error('[PROXY ERROR]', error.message);
    }

    // Handle different error types
    if (axios.isAxiosError(error)) {
      if (error.code === 'ECONNREFUSED') {
        return res.status(503).json({
          error: 'Backend service unavailable',
          message: 'The backend service is currently unavailable. Please try again later.'
        });
      }
      
      if (error.code === 'ETIMEDOUT' || error.code === 'ECONNABORTED') {
        return res.status(504).json({
          error: 'Backend service timeout',
          message: 'The backend service did not respond in time. Please try again later.'
        });
      }
      
      if (error.response) {
        return res.status(error.response.status).json(error.response.data);
      }
    }

    // Generic error response
    if (res.headersSent) {
      return;
    }
    
    res.status(502).json({
      error: 'Bad Gateway',
      message: 'An error occurred while processing your request.'
    });
  }
}

// Gateway health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'gateway',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Backend health check endpoint (proxied)
app.get('/api/health', async (req, res) => {
  try {
    const response = await axios.get(`${BACKEND_BASE_URL}/api/health`, {
      timeout: 5000
    });
    res.json({
      gateway: 'ok',
      backend: response.data
    });
  } catch (error) {
    res.status(503).json({
      gateway: 'ok',
      backend: 'unavailable',
      error: error.message
    });
  }
});

// Proxy all /api/* requests to backend (except /api/health which is handled above)
app.all('/api/*', proxyRequest);

// 404 handler for unknown routes
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: 'The requested endpoint does not exist',
    path: req.url
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('[UNHANDLED ERROR]', err);
  
  if (res.headersSent) {
    return next(err);
  }
  
  res.status(500).json({
    error: 'Internal Server Error',
    message: NODE_ENV === 'development' ? err.message : 'An unexpected error occurred'
  });
});

// Start server
const server = app.listen(GATEWAY_PORT, () => {
  console.log('='.repeat(60));
  console.log(`Gateway Service Started`);
  console.log(`Environment: ${NODE_ENV}`);
  console.log(`Gateway Port: ${GATEWAY_PORT}`);
  console.log(`Backend URL: ${BACKEND_BASE_URL}`);
  console.log(`Time: ${new Date().toISOString()}`);
  console.log('='.repeat(60));
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});
