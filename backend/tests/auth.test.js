const request = require('supertest');
const app = require('../src/app');
const db = require('../src/config/db');

describe('Auth API Integration Tests', () => {
  beforeAll(async () => {
    await db.initDbPool();
  });

  afterAll(async () => {
    await db.closeDbPool();
  });

  const testUser = {
    username: `testuser_${Date.now().toString().slice(-6)}`,
    email: `test_${Date.now().toString().slice(-6)}@example.com`,
    password: 'Password123!',
  };

  let authToken = null;
  let createdUserId = null;

  describe('POST /api/auth/register', () => {
    it('fails when required fields are missing', async () => {
      const res = await request(app).post('/api/auth/register').send({});
      expect(res.statusCode).toBe(400);
      expect(res.body).toHaveProperty('error');
    });

    it('fails when email format is invalid', async () => {
      const res = await request(app).post('/api/auth/register').send({
        username: 'validuser',
        email: 'invalid-email',
        password: 'password123',
      });
      expect(res.statusCode).toBe(400);
      expect(res.body.error).toMatch(/valid email/i);
    });

    it('fails when password is too short', async () => {
      const res = await request(app).post('/api/auth/register').send({
        username: 'validuser',
        email: 'user@example.com',
        password: '123',
      });
      expect(res.statusCode).toBe(400);
      expect(res.body.error).toMatch(/at least 6 characters/i);
    });

    it('successfully registers a new user', async () => {
      const res = await request(app).post('/api/auth/register').send(testUser);
      expect(res.statusCode).toBe(201);
      expect(res.body).toHaveProperty('user');
      expect(res.body).toHaveProperty('token');
      expect(res.body.user.username).toBe(testUser.username);
      expect(res.body.user.email).toBe(testUser.email.toLowerCase());
      expect(res.body.user).not.toHaveProperty('password');
      expect(res.body.user).not.toHaveProperty('password_hash');

      createdUserId = res.body.user.id;
      authToken = res.body.token;
    });

    it('fails with 409 when registering with duplicate email or username', async () => {
      const res = await request(app).post('/api/auth/register').send(testUser);
      expect(res.statusCode).toBe(409);
      expect(res.body).toHaveProperty('error');
    });
  });

  describe('POST /api/auth/login', () => {
    it('fails with 400 when identifier or password is missing', async () => {
      const res = await request(app).post('/api/auth/login').send({});
      expect(res.statusCode).toBe(400);
    });

    it('fails with 401 when password is incorrect', async () => {
      const res = await request(app).post('/api/auth/login').send({
        identifier: testUser.username,
        password: 'WrongPassword!',
      });
      expect(res.statusCode).toBe(401);
      expect(res.body.error).toMatch(/invalid/i);
    });

    it('successfully logs in using username', async () => {
      const res = await request(app).post('/api/auth/login').send({
        identifier: testUser.username,
        password: testUser.password,
      });
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('user');
      expect(res.body).toHaveProperty('token');
      expect(res.body.user.username).toBe(testUser.username);
    });

    it('successfully logs in using email', async () => {
      const res = await request(app).post('/api/auth/login').send({
        identifier: testUser.email,
        password: testUser.password,
      });
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('token');
      expect(res.body.user.email).toBe(testUser.email.toLowerCase());
    });
  });

  describe('GET /api/auth/me', () => {
    it('returns 401 when Authorization header is missing', async () => {
      const res = await request(app).get('/api/auth/me');
      expect(res.statusCode).toBe(401);
    });

    it('returns 403 when token is invalid', async () => {
      const res = await request(app)
        .get('/api/auth/me')
        .set('Authorization', 'Bearer invalid_token_xyz');
      expect(res.statusCode).toBe(403);
    });

    it('returns 200 with user profile when valid token is provided', async () => {
      const res = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`);
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('user');
      expect(res.body.user.id).toBe(createdUserId);
      expect(res.body.user.username).toBe(testUser.username);
    });
  });
});
