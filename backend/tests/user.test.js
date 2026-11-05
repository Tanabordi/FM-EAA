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

    it('proxies image successfully with valid https url', async () => {
      const origFetch = global.fetch;
      global.fetch = jest.fn().mockResolvedValue({
        ok: true,
        status: 200,
        headers: {
          get: (header) => (header.toLowerCase() === 'content-type' ? 'image/png' : null),
        },
        arrayBuffer: jest.fn().mockResolvedValue(new Uint8Array([137, 80, 78, 71]).buffer),
      });

      const res = await request(app)
        .get('/api/users/avatar-proxy')
        .query({ url: 'https://images.example.com/photo.png' });

      expect(res.statusCode).toBe(200);
      global.fetch = origFetch;
    });

    it('returns error status when proxy upstream fetch fails', async () => {
      const origFetch = global.fetch;
      global.fetch = jest.fn().mockResolvedValue({
        ok: false,
        status: 404,
      });

      const res = await request(app)
        .get('/api/users/avatar-proxy')
        .query({ url: 'https://images.example.com/notfound.png' });

      expect(res.statusCode).toBe(404);
      global.fetch = origFetch;
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

    it('validates username and email format constraints', async () => {
      // Too short username
      const shortUserRes = await request(app)
        .patch('/api/users/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ username: 'ab' });
      expect(shortUserRes.statusCode).toBe(400);
      expect(shortUserRes.body.error).toMatch(/at least 3 characters/i);

      // Invalid email
      const badEmailRes = await request(app)
        .patch('/api/users/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ email: 'not-an-email' });
      expect(badEmailRes.statusCode).toBe(400);
      expect(badEmailRes.body.error).toMatch(/valid email/i);
    });

    it('validates password change requirements', async () => {
      // Missing current password
      const noCurrRes = await request(app)
        .patch('/api/users/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ newPassword: 'NewPassword123!' });
      expect(noCurrRes.statusCode).toBe(400);
      expect(noCurrRes.body.error).toMatch(/current password is required/i);

      // Short new password
      const shortPwRes = await request(app)
        .patch('/api/users/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ currentPassword: 'Password123!', newPassword: 'short' });
      expect(shortPwRes.statusCode).toBe(400);
      expect(shortPwRes.body.error).toMatch(/at least 8 characters/i);

      // Wrong current password
      const wrongCurrRes = await request(app)
        .patch('/api/users/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ currentPassword: 'WrongPassword999!', newPassword: 'NewValidPassword123!' });
      expect(wrongCurrRes.statusCode).toBe(401);
      expect(wrongCurrRes.body.error).toMatch(/does not match/i);
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

    it('returns 400 when uploaded file format is invalid', async () => {
      const res = await request(app)
        .post('/api/users/me/avatar')
        .set('Authorization', `Bearer ${authToken}`)
        .attach('avatar', Buffer.from('plain text file'), 'test.txt');
      expect(res.statusCode).toBe(400);
      expect(res.body.error).toMatch(/invalid file type/i);
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

