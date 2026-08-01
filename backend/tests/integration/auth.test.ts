import request from 'supertest';
import { createApp } from '../../src/app';

const app = createApp();

describe('Auth API /api/v1/auth', () => {
  it('should reject signup with invalid body', async () => {
    const res = await request(app).post('/api/v1/auth/signup').send({
      email: 'invalid-email',
      password: '123',
    });

    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('VALIDATION_FAILED');
  });

  it('should reject login with missing credentials', async () => {
    const res = await request(app).post('/api/v1/auth/login').send({});

    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
  });
});
