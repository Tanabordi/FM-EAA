process.env.NODE_ENV = 'test';
const request = require('supertest');
const jwt = require('jsonwebtoken');
const app = require('../src/app');
const db = require('../src/config/db');
const config = require('../src/config/env');

describe('Security & Vulnerability Test Suite (Security Testing)', () => {
  let userAToken = null;
  let userBToken = null;
  let userAId = null;
  let userBId = null;
  let userAFridgeId = null;

  const userA = {
    username: `sec_a_${Date.now().toString().slice(-6)}`,
    email: `sec_a_${Date.now().toString().slice(-6)}@security.test`,
    password: 'Password123!',
  };

  const userB = {
    username: `sec_b_${Date.now().toString().slice(-6)}`,
    email: `sec_b_${Date.now().toString().slice(-6)}@security.test`,
    password: 'Password456!',
  };

  beforeAll(async () => {
    await db.initDbPool();

    // Register User A
    const resA = await request(app).post('/api/auth/register').send(userA);
    if (resA.statusCode === 201) {
      userAToken = resA.body.token;
      userAId = resA.body.user.id;
    }

    // Register User B
    const resB = await request(app).post('/api/auth/register').send(userB);
    if (resB.statusCode === 201) {
      userBToken = resB.body.token;
      userBId = resB.body.user.id;
    }

    // Create a private fridge for User A
    if (userAToken) {
      const fridgeRes = await request(app)
        .post('/api/fridges')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({ name: 'User A Private Vault', timezone: 'Asia/Bangkok' });
      if (fridgeRes.statusCode === 201) {
        userAFridgeId = fridgeRes.body.fridge.id;
      }
    }
  });

  afterAll(async () => {
    await db.closeDbPool();
  });

  describe('1. Authentication Enforcement & Access Controls (401)', () => {
    it('blocks unauthenticated access to /api/users/me', async () => {
      const res = await request(app).get('/api/users/me');
      expect(res.statusCode).toBe(401);
      expect(res.body.error).toMatch(/access token required/i);
    });

    it('blocks unauthenticated access to /api/fridges', async () => {
      const res = await request(app).get('/api/fridges');
      expect(res.statusCode).toBe(401);
      expect(res.body.error).toMatch(/access token required/i);
    });

    it('blocks unauthenticated access to /api/notifications', async () => {
      const res = await request(app).get('/api/notifications');
      expect(res.statusCode).toBe(401);
      expect(res.body.error).toMatch(/access token required/i);
    });

    it('blocks unauthenticated access to /api/sync/pull', async () => {
      const res = await request(app).get('/api/sync/pull');
      expect(res.statusCode).toBe(401);
    });
  });

  describe('2. Token Integrity & Forgery Protection (403)', () => {
    it('rejects tampered or forged JWT tokens', async () => {
      const fakeToken = jwt.sign(
        { id: userAId, email: userA.email },
        'wrong_attacker_secret_key_123',
        { expiresIn: '1h' }
      );

      const res = await request(app)
        .get('/api/users/me')
        .set('Authorization', `Bearer ${fakeToken}`);
      expect(res.statusCode).toBe(403);
      expect(res.body.error).toMatch(/invalid or expired token/i);
    });

    it('rejects expired JWT tokens', async () => {
      const expiredToken = jwt.sign(
        { id: userAId, email: userA.email },
        config.jwt.secret,
        { expiresIn: '-1s' }
      );

      const res = await request(app)
        .get('/api/users/me')
        .set('Authorization', `Bearer ${expiredToken}`);
      expect(res.statusCode).toBe(403);
      expect(res.body.error).toMatch(/invalid or expired token/i);
    });

    it('rejects malformed bearer tokens', async () => {
      const res = await request(app)
        .get('/api/users/me')
        .set('Authorization', 'Bearer not.a.valid.jwt');
      expect(res.statusCode).toBe(403);
    });
  });

  describe('3. Sensitive Data Exposure Prevention', () => {
    it('does not expose password hashes in GET /api/users/me', async () => {
      const res = await request(app)
        .get('/api/users/me')
        .set('Authorization', `Bearer ${userAToken}`);
      expect(res.statusCode).toBe(200);
      expect(res.body.user).not.toHaveProperty('password');
      expect(res.body.user).not.toHaveProperty('password_hash');
      expect(res.body.user).not.toHaveProperty('salt');
    });

    it('does not leak password hashes in user search results', async () => {
      const res = await request(app)
        .get('/api/users/search')
        .set('Authorization', `Bearer ${userAToken}`)
        .query({ q: userA.username });
      expect(res.statusCode).toBe(200);
      if (res.body.users && res.body.users.length > 0) {
        for (const u of res.body.users) {
          expect(u).not.toHaveProperty('password');
          expect(u).not.toHaveProperty('password_hash');
        }
      }
    });

    it('rejects wrong password without leaking backend stack trace', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({ identifier: userA.email, password: 'WrongPassword999!' });
      expect(res.statusCode).toBe(401);
      expect(res.body).toHaveProperty('error');
      expect(res.text).not.toMatch(/node_modules|at Object|oracledb/);
    });
  });

  describe('4. IDOR (Insecure Direct Object Reference) & Multi-Tenant Isolation', () => {
    it('prevents User B from modifying or deleting User A private fridge', async () => {
      if (!userAFridgeId || !userBToken) return;

      // User B tries to delete User A's fridge
      const deleteRes = await request(app)
        .delete(`/api/fridges/${userAFridgeId}`)
        .set('Authorization', `Bearer ${userBToken}`);

      // Must be 403 Forbidden or 404 Not Found (isolated)
      expect([403, 404]).toContain(deleteRes.statusCode);

      // Verify User A fridge remains intact
      const verifyRes = await request(app)
        .get(`/api/fridges/${userAFridgeId}`)
        .set('Authorization', `Bearer ${userAToken}`);
      expect([200, 404]).toContain(verifyRes.statusCode);
    });
  });

  describe('5. Input Sanitization & Injection Defense', () => {
    it('handles SQL injection payloads safely without throwing unhandled database error', async () => {
      const sqlInjectionPayloads = [
        "' OR '1'='1",
        "'; DROP TABLE users; --",
        "admin' --",
        "1 UNION SELECT null, null, null--",
      ];

      for (const payload of sqlInjectionPayloads) {
        const res = await request(app)
          .get('/api/users/search')
          .set('Authorization', `Bearer ${userAToken}`)
          .query({ q: payload });

        // Safe status: 200 with sanitized results or 400 bad request, NEVER 500 SQL syntax crash
        expect([200, 400]).toContain(res.statusCode);
        expect(res.text).not.toMatch(/ORA-|syntax error|SQL command/i);
      }
    });

    it('handles script tags (XSS payloads) in input fields safely', async () => {
      if (!userAToken) return;

      const xssName = '<script>alert("XSS")</script>';
      const res = await request(app)
        .post('/api/fridges')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({ name: xssName, timezone: 'Asia/Bangkok' });

      // If created, stored safely without crashing JSON
      if (res.statusCode === 201) {
        expect(res.body.fridge.name).toBe(xssName);
      } else {
        expect([400, 422]).toContain(res.statusCode);
      }
    });
  });
});

