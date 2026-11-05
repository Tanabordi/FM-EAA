process.env.NODE_ENV = 'test';
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
      expect(res.body.error).toMatch(/at least 8 characters/i);
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

  describe('POST /api/auth/google', () => {
    it('returns 400 when idToken is missing', async () => {
      const res = await request(app).post('/api/auth/google').send({});
      expect(res.statusCode).toBe(400);
      expect(res.body.error).toMatch(/idToken.*required/i);
    });

    it('returns 401 when idToken is invalid', async () => {
      const res = await request(app).post('/api/auth/google').send({ idToken: 'invalid_mock_token' });
      expect(res.statusCode).toBe(401);
      expect(res.body.error).toMatch(/Invalid Google token/i);
    });
  });

  describe('POST /api/auth/forgot-password and POST /api/auth/reset-password', () => {
    it('fails when email is missing or invalid', async () => {
      const res1 = await request(app).post('/api/auth/forgot-password').send({});
      expect(res1.statusCode).toBe(400);

      const res2 = await request(app).post('/api/auth/forgot-password').send({ email: 'notanemail' });
      expect(res2.statusCode).toBe(400);
    });

    it('returns 404 when email does not exist', async () => {
      const res = await request(app)
        .post('/api/auth/forgot-password')
        .send({ email: 'nonexistent_user_999999@example.com' });
      expect(res.statusCode).toBe(404);
    });

    it('successfully requests OTP and resets password for existing user', async () => {
      // 1. Request OTP for testUser created earlier
      const forgotRes = await request(app)
        .post('/api/auth/forgot-password')
        .send({ email: testUser.email });
      expect(forgotRes.statusCode).toBe(200);
      expect(forgotRes.body).toHaveProperty('success', true);
      expect(forgotRes.body).toHaveProperty('otp');

      const otp = forgotRes.body.otp;

      // 2. Fails verify with wrong OTP
      const wrongVerifyRes = await request(app)
        .post('/api/auth/verify-otp')
        .send({
          email: testUser.email,
          otp: '000000',
        });
      expect(wrongVerifyRes.statusCode).toBe(400);

      // 3. Succeeds verify with correct OTP
      const correctVerifyRes = await request(app)
        .post('/api/auth/verify-otp')
        .send({
          email: testUser.email,
          otp,
        });
      expect(correctVerifyRes.statusCode).toBe(200);
      expect(correctVerifyRes.body).toHaveProperty('success', true);

      // 4. Fails reset with wrong OTP
      const wrongOtpRes = await request(app)
        .post('/api/auth/reset-password')
        .send({
          email: testUser.email,
          otp: '000000',
          newPassword: 'BrandNewPassword999!',
        });
      expect(wrongOtpRes.statusCode).toBe(400);

      // 3. Fails reset with weak password
      const weakPassRes = await request(app)
        .post('/api/auth/reset-password')
        .send({
          email: testUser.email,
          otp,
          newPassword: 'short',
        });
      expect(weakPassRes.statusCode).toBe(400);

      // 4. Successfully resets password
      const resetRes = await request(app)
        .post('/api/auth/reset-password')
        .send({
          email: testUser.email,
          otp,
          newPassword: 'BrandNewPassword999!',
        });
      expect(resetRes.statusCode).toBe(200);
      expect(resetRes.body).toHaveProperty('success', true);

      // 5. Verify user can log in with new password
      const loginRes = await request(app)
        .post('/api/auth/login')
        .send({
          identifier: testUser.email,
          password: 'BrandNewPassword999!',
        });
      expect(loginRes.statusCode).toBe(200);
      expect(loginRes.body).toHaveProperty('token');
    });
  });
});
