import { PrismaClient } from '@prisma/client';
import { logger } from './logger.js';

declare global {
  // eslint-disable-next-line no-var
  var prismaGlobal: PrismaClient | undefined;
}

export const prisma =
  globalThis.prismaGlobal ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query', 'info', 'warn', 'error'] : ['error'],
  });

if (process.env.NODE_ENV !== 'production') {
  globalThis.prismaGlobal = prisma;
}

prisma.$connect()
  .then(() => logger.info('✅ Prisma connected to PostgreSQL'))
  .catch((err) => logger.error({ err }, '❌ Prisma connection error'));
