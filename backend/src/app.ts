import express, { Express } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import { env } from './config/env';
import { requestIdMiddleware } from './middlewares/requestIdMiddleware';
import { errorMiddleware } from './middlewares/errorMiddleware';
import healthRoutes from './routes/health.routes';
import swaggerUi from 'swagger-ui-express';
import { openApiSpec } from './docs/openapi';
import authRoutes from './routes/auth.routes';
import userRoutes from './routes/user.routes';
import folderRoutes from './routes/folder.routes';
import trackRoutes from './routes/track.routes';
import uploadRoutes from './routes/upload.routes';
import streamingRoutes from './routes/streaming.routes';
import playlistRoutes from './routes/playlist.routes';
import searchRoutes from './routes/search.routes';
import publicRoutes from './routes/public.routes';
import adminRoutes from './routes/admin.routes';
import collaborationRoutes from './routes/collaboration.routes';

// Polyfill BigInt serialization for JSON responses
// eslint-disable-next-line @typescript-eslint/no-explicit-any
(BigInt.prototype as any).toJSON = function () {
  return Number(this);
};

export const createApp = (): Express => {
  const app = express();

  // Security & Core Middlewares
  app.use(helmet());
  app.use(cors({ origin: '*', credentials: true }));
  app.use(compression());
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));
  app.use(requestIdMiddleware);

  // Health checks & Swagger API Docs
  app.use('/', healthRoutes);
  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(openApiSpec));

  // API Version 1 Mounting
  const apiRouter = express.Router();

  apiRouter.use('/auth', authRoutes);
  apiRouter.use('/users', userRoutes);
  apiRouter.use('/me', userRoutes);
  apiRouter.use('/folders', folderRoutes);
  apiRouter.use('/tracks', trackRoutes);
  apiRouter.use('/uploads', uploadRoutes);
  apiRouter.use('/streaming', streamingRoutes);
  apiRouter.use('/playback', streamingRoutes);
  apiRouter.use('/playlists', playlistRoutes);
  apiRouter.use('/search', searchRoutes);
  apiRouter.use('/public', publicRoutes);
  apiRouter.use('/admin', adminRoutes);
  apiRouter.use('/collaboration', collaborationRoutes);

  app.use(env.API_PREFIX, apiRouter);

  // 404 Handler
  app.use((_req, res) => {
    res.status(404).json({
      success: false,
      message: 'Endpoint not found',
      data: null,
      error: { code: 'NOT_FOUND' },
      timestamp: new Date().toISOString(),
      requestId: (res.getHeader('x-request-id') as string) || 'req_unknown',
    });
  });

  // Centralized Error Middleware
  app.use(errorMiddleware);

  return app;
};
