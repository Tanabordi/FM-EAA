process.env.NODE_ENV = 'test';
const request = require('supertest');
const app = require('../src/app');
const db = require('../src/config/db');

describe('Family Member & Invite API Integration Tests', () => {
  let userA = null;
  let tokenA = null;
  let userB = null;
  let tokenB = null;
  let userC = null;
  let tokenC = null;
  let fridgeId = null;
  let inviteBId = null;
  let inviteCId = null;

  beforeAll(async () => {
    await db.initDbPool();

    const suffix = Date.now().toString().slice(-6);

    // Register User A (Fridge Owner)
    userA = {
      username: `owner_${suffix}`,
      email: `owner_${suffix}@example.com`,
      password: 'Password123!',
    };
    const resA = await request(app).post('/api/auth/register').send(userA);
    expect(resA.statusCode).toBe(201);
    tokenA = resA.body.token;

    // Register User B (Invitee / Member)
    userB = {
      username: `memberB_${suffix}`,
      email: `memberB_${suffix}@example.com`,
      password: 'Password123!',
    };
    const resB = await request(app).post('/api/auth/register').send(userB);
    expect(resB.statusCode).toBe(201);
    tokenB = resB.body.token;

    // Register User C (Declining Member)
    userC = {
      username: `memberC_${suffix}`,
      email: `memberC_${suffix}@example.com`,
      password: 'Password123!',
    };
    const resC = await request(app).post('/api/auth/register').send(userC);
    expect(resC.statusCode).toBe(201);
    tokenC = resC.body.token;

    // User A creates a fridge
    const fridgeRes = await request(app)
      .post('/api/fridges')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({ name: 'Family Test Fridge', description: 'Testing member workflows' });
    expect(fridgeRes.statusCode).toBe(201);
    fridgeId = fridgeRes.body.fridge.id;
  });

  afterAll(async () => {
    await db.closeDbPool();
  });

  describe('1. Member Listing & Search', () => {
    it('initially lists only the owner in fridge members', async () => {
      const res = await request(app)
        .get(`/api/fridges/${fridgeId}/members`)
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.members).toHaveLength(1);
      expect(res.body.members[0].username).toBe(userA.username);
      expect(res.body.members[0].role).toBe('owner');
    });

    it('searches for users and marks them as available', async () => {
      const res = await request(app)
        .get(`/api/fridges/${fridgeId}/search-users?username=${userB.username}`)
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.users.length).toBeGreaterThanOrEqual(1);
      const found = res.body.users.find(u => u.username === userB.username);
      expect(found).toBeDefined();
      expect(found.status).toBe('available');
    });

    it('does not include the requesting user in search results', async () => {
      const res = await request(app)
        .get(`/api/fridges/${fridgeId}/search-users?username=${userA.username}`)
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.statusCode).toBe(200);
      const foundSelf = res.body.users.find(u => u.username === userA.username);
      expect(foundSelf).toBeUndefined();
    });
  });

  describe('2. Invitations Flow', () => {
    it('fails to invite with empty username', async () => {
      const res = await request(app)
        .post(`/api/fridges/${fridgeId}/invites`)
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ username: '' });

      expect(res.statusCode).toBe(400);
      expect(res.body.error).toContain('Username is required');
    });

    it('fails to invite a non-existent user', async () => {
      const res = await request(app)
        .post(`/api/fridges/${fridgeId}/invites`)
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ username: 'non_existent_xyz_user_99999' });

      expect(res.statusCode).toBe(404);
      expect(res.body.error).toContain('not found');
    });

    it('fails when owner tries to invite themselves', async () => {
      const res = await request(app)
        .post(`/api/fridges/${fridgeId}/invites`)
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ username: userA.username });

      expect(res.statusCode).toBe(400);
      expect(res.body.error).toContain('Cannot invite yourself');
    });

    it('successfully sends an invitation to User B', async () => {
      const res = await request(app)
        .post(`/api/fridges/${fridgeId}/invites`)
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ username: userB.username });

      expect(res.statusCode).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.invite).toHaveProperty('id');
      expect(res.body.invite.status).toBe('pending');
      inviteBId = res.body.invite.id;
    });

    it('rejects duplicate pending invitation to the same user', async () => {
      const res = await request(app)
        .post(`/api/fridges/${fridgeId}/invites`)
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ username: userB.username });

      expect(res.statusCode).toBe(400);
      expect(res.body.error).toContain('Invitation already sent');
    });

    it('marks invited user as pending in search results', async () => {
      const res = await request(app)
        .get(`/api/fridges/${fridgeId}/search-users?username=${userB.username}`)
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.statusCode).toBe(200);
      const found = res.body.users.find(u => u.username === userB.username);
      expect(found).toBeDefined();
      expect(found.status).toBe('pending');
    });

    it('shows pending invites in fridge invites endpoint', async () => {
      const res = await request(app)
        .get(`/api/fridges/${fridgeId}/invites`)
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.invites.some(inv => inv.id === inviteBId)).toBe(true);
    });

    it('User B can view their received pending invitations', async () => {
      const res = await request(app)
        .get('/api/invites/pending')
        .set('Authorization', `Bearer ${tokenB}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.invites.some(inv => inv.id === inviteBId)).toBe(true);
      const invite = res.body.invites.find(inv => inv.id === inviteBId);
      expect(invite.fridgeName).toBe('Family Test Fridge');
      expect(invite.fromUsername).toBe(userA.username);
    });

    it('User B has a notification for the invitation', async () => {
      const res = await request(app)
        .get('/api/notifications')
        .set('Authorization', `Bearer ${tokenB}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.notifications.some(n => n.type === 'invite')).toBe(true);
      const notif = res.body.notifications.find(n => n.type === 'invite');
      expect(notif.payload.invite_id).toBe(inviteBId);
    });
  });

  describe('3. Accepting & Declining Invitations', () => {
    it('User B accepts the invitation and joins the fridge', async () => {
      const res = await request(app)
        .post(`/api/invites/${inviteBId}/accept`)
        .set('Authorization', `Bearer ${tokenB}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.status).toBe('accepted');
    });

    it('User B now has access to the fridge', async () => {
      const res = await request(app)
        .get(`/api/fridges/${fridgeId}`)
        .set('Authorization', `Bearer ${tokenB}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.fridge.id).toBe(fridgeId);
    });

    it('lists User B in fridge members with role member', async () => {
      const res = await request(app)
        .get(`/api/fridges/${fridgeId}/members`)
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.members).toHaveLength(2);
      const memberB = res.body.members.find(m => m.username === userB.username);
      expect(memberB).toBeDefined();
      expect(memberB.role).toBe('member');
    });

    it('marks User B as already in family in search results', async () => {
      const res = await request(app)
        .get(`/api/fridges/${fridgeId}/search-users?username=${userB.username}`)
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.statusCode).toBe(200);
      const found = res.body.users.find(u => u.username === userB.username);
      expect(found).toBeDefined();
      expect(found.status).toBe('already');
    });

    it('User A invites User C, and User C declines', async () => {
      const invRes = await request(app)
        .post(`/api/fridges/${fridgeId}/invites`)
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ username: userC.username });

      expect(invRes.statusCode).toBe(201);
      inviteCId = invRes.body.invite.id;

      const decRes = await request(app)
        .post(`/api/invites/${inviteCId}/decline`)
        .set('Authorization', `Bearer ${tokenC}`);

      expect(decRes.statusCode).toBe(200);
      expect(decRes.body.status).toBe('declined');

      // User C should NOT have access
      const accessRes = await request(app)
        .get(`/api/fridges/${fridgeId}`)
        .set('Authorization', `Bearer ${tokenC}`);

      expect(accessRes.statusCode).toBe(404);
    });
  });

  describe('4. Member Removal & Permissions', () => {
    it('member cannot remove the owner', async () => {
      const membersRes = await request(app)
        .get(`/api/fridges/${fridgeId}/members`)
        .set('Authorization', `Bearer ${tokenA}`);

      const owner = membersRes.body.members.find(m => m.role === 'owner');

      const res = await request(app)
        .delete(`/api/fridges/${fridgeId}/members/${owner.id}`)
        .set('Authorization', `Bearer ${tokenB}`);

      expect(res.statusCode).toBe(403);
    });

    it('non-owner member cannot update fridge details', async () => {
      const res = await request(app)
        .patch(`/api/fridges/${fridgeId}`)
        .set('Authorization', `Bearer ${tokenB}`)
        .send({ name: 'Hacked Name' });

      expect(res.statusCode).toBe(403);
      expect(res.body.message).toContain('Only the fridge owner can update this fridge');
    });

    it('owner can successfully update fridge details', async () => {
      const res = await request(app)
        .patch(`/api/fridges/${fridgeId}`)
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ name: 'Updated Family Fridge' });

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.fridge.name).toBe('Updated Family Fridge');
    });

    it('owner cannot leave the fridge', async () => {
      const res = await request(app)
        .post(`/api/fridges/${fridgeId}/leave`)
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.statusCode).toBe(400);
      expect(res.body.message).toContain('Fridge owner cannot leave the fridge');
    });

    it('member B can successfully leave the fridge', async () => {
      const res = await request(app)
        .post(`/api/fridges/${fridgeId}/leave`)
        .set('Authorization', `Bearer ${tokenB}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
    });

    it('User B no longer has access to the fridge after leaving', async () => {
      const res = await request(app)
        .get(`/api/fridges/${fridgeId}`)
        .set('Authorization', `Bearer ${tokenB}`);

      expect(res.statusCode).toBe(404);
    });
  });
});
