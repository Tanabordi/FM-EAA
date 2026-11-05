process.env.NODE_ENV = 'test';
const request = require('supertest');
const app = require('../src/app');
const db = require('../src/config/db');

describe('User Profile & Device API Integration Tests', () => {
  let authToken = null;
  let testUserId = null;

  const testUser = {
    username: `user_${Date.now().toString().slice(-6)}`,
    email: `user_${Date.now().toString().slice(-6)}@example.com`,
    password: 'Password123!',
  };

  beforeAll(async () => {
    await db.initDbPool();

    // Register user to get token
    const res = await request(app).post('/api/auth/register').send(testUser);
    if (res.statusCode === 201) {
      authToken = res.body.token;
      testUserId = res.body.user.id;
    }
  });

  afterAll(async () => {
    await db.closeDbPool();
  });

  describe('GET /api/users/avatar-proxy', () => {
    it('returns 400 when url parameter is missing', async () => {
      const res = await request(app).get('/api/users/avatar-proxy');
      expect(res.statusCode).toBe(400);
      expect(res.text).toMatch(/missing url/i);
    });

    it('returns 400 when url protocol is invalid', async () => {
      const res = await request(app)
        .get('/api/users/avatar-proxy')
        .query({ url: 'ftp://example.com/avatar.png' });
      expect(res.statusCode).toBe(400);
      expect(res.text).toMatch(/invalid url/i);
    });
  });

  describe('GET /api/users/me', () => {
    it('returns 401 unauthorized when token is not provided', async () => {
      const res = await request(app).get('/api/users/me');
      expect(res.statusCode).toBe(401);
    });

    it('returns current user profile when token is valid', async () => {
      const res = await request(app)
        .get('/api/users/me')
        .set('Authorization', `Bearer ${authToken}`);
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('user');
      expect(res.body.user.username).toBe(testUser.username);
    });
  });

  describe('PATCH /api/users/me', () => {
    it('returns 401 when token is missing', async () => {
      const res = await request(app).patch('/api/users/me').send({ email: 'new@test.com' });
      expect(res.statusCode).toBe(401);
    });

    it('updates user email and avatarUrl', async () => {
      const newEmail = `updated_${Date.now().toString().slice(-6)}@example.com`;
      const res = await request(app)
        .patch('/api/users/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          email: newEmail,
          avatarUrl: 'https://images.example.com/new_avatar.png',
        });
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('user');
      expect(res.body.user.email).toBe(newEmail);
      expect(res.body.user.avatarUrl).toBe('https://images.example.com/new_avatar.png');
    });
  });

  describe('POST /api/users/me/avatar', () => {
    it('returns 401 when token is missing', async () => {
      const res = await request(app).post('/api/users/me/avatar');
      expect(res.statusCode).toBe(401);
    });

    it('returns 400 when no file is uploaded', async () => {
      const res = await request(app)
        .post('/api/users/me/avatar')
        .set('Authorization', `Bearer ${authToken}`);
      expect(res.statusCode).toBe(400);
    });
  });

  describe('GET /api/users/search', () => {
    it('returns 401 when unauthenticated', async () => {
      const res = await request(app).get('/api/users/search');
      expect(res.statusCode).toBe(401);
    });

    it('returns empty list when username query parameter is empty', async () => {
      const res = await request(app)
        .get('/api/users/search')
        .set('Authorization', `Bearer ${authToken}`);
      expect(res.statusCode).toBe(200);
      expect(res.body.users).toEqual([]);
    });

    it('searches for users matching query term', async () => {
      const res = await request(app)
        .get('/api/users/search')
        .query({ username: testUser.username.substring(0, 5) })
        .set('Authorization', `Bearer ${authToken}`);
      expect(res.statusCode).toBe(200);
      expect(Array.isArray(res.body.users)).toBe(true);
    });
  });

  describe('POST & DELETE /api/users/fcm-token', () => {
    const fakeFcmToken = 'fake_fcm_registration_token_12345';

    it('returns 400 when fcmToken is missing', async () => {
      const res = await request(app)
        .post('/api/users/fcm-token')
        .set('Authorization', `Bearer ${authToken}`)
        .send({});
      expect(res.statusCode).toBe(400);
    });

    it('successfully registers an FCM token', async () => {
      const res = await request(app)
        .post('/api/users/fcm-token')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ fcmToken: fakeFcmToken, language: 'th' });
      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
    });

    it('successfully removes an FCM token on logout', async () => {
      const res = await request(app)
        .delete('/api/users/fcm-token')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ fcmToken: fakeFcmToken });
      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
    });
  });
});

