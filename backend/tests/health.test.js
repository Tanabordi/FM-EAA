const request = require('supertest');
const app = require('../src/app');

describe('Backend Skeleton Tests', () => {
  it('GET /health returns 200 and status ok', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('status', 'ok');
  });

  it('POST /api/auth/login returns 501 Not implemented', async () => {
    const res = await request(app).post('/api/auth/login').send({ username: 'test', password: 'password' });
    expect(res.statusCode).toBe(501);
    expect(res.body).toHaveProperty('error', 'Not implemented');
  });

  it('GET /api/fridges returns 501 Not implemented', async () => {
    const res = await request(app).get('/api/fridges');
    expect(res.statusCode).toBe(501);
  });

  it('POST /api/sync returns 501 Not implemented', async () => {
    const res = await request(app).post('/api/sync').send({});
    expect(res.statusCode).toBe(501);
  });

  it('POST /api/ai/scan-label returns 501 Not implemented', async () => {
    const res = await request(app).post('/api/ai/scan-label');
    expect(res.statusCode).toBe(501);
  });
});

