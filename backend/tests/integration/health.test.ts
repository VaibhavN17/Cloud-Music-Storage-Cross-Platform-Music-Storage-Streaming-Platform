import request from 'supertest';
import { createApp } from '../../src/app';

const app = createApp();

describe('GET /health & /live Endpoints', () => {
  it('should return 200 OK and healthy status for /health', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.status).toBe('pass');
    expect(res.body.requestId).toBeDefined();
  });

  it('should return 200 OK for /live', async () => {
    const res = await request(app).get('/live');
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.status).toBe('alive');
  });
});
