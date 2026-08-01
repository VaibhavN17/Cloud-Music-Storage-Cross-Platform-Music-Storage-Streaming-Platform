export const openApiSpec = {
  openapi: '3.0.0',
  info: {
    title: 'Cloud Music Storage API',
    version: '1.0.0',
    description: 'Enterprise-grade Cross-Platform Cloud Music Storage & Streaming REST API v1',
  },
  servers: [
    {
      url: 'http://localhost:5000/api/v1',
      description: 'Local Development Server',
    },
  ],
  components: {
    securitySchemes: {
      BearerAuth: {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
      },
    },
  },
  security: [{ BearerAuth: [] }],
  paths: {
    '/health': {
      get: {
        summary: 'Basic health check',
        responses: {
          '200': { description: 'Service operational' },
        },
      },
    },
    '/ready': {
      get: {
        summary: 'Dependency readiness check',
        responses: {
          '200': { description: 'All dependencies operational' },
          '503': { description: 'One or more dependencies down' },
        },
      },
    },
    '/auth/signup': {
      post: {
        summary: 'Register new user account',
        responses: {
          '201': { description: 'User account created' },
        },
      },
    },
    '/auth/login': {
      post: {
        summary: 'Authenticate with email & password',
        responses: {
          '200': { description: 'Login successful' },
        },
      },
    },
    '/tracks': {
      get: {
        summary: 'List user tracks with pagination and filtering',
        responses: {
          '200': { description: 'Tracks list retrieved' },
        },
      },
    },
    '/uploads/presigned-url': {
      post: {
        summary: 'Generate R2 presigned upload URL',
        responses: {
          '200': { description: 'Presigned URL generated' },
        },
      },
    },
  },
};
