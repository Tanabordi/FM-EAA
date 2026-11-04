process.env.NODE_ENV = 'test';
jest.setTimeout(30000);
const request = require('supertest');
const app = require('../src/app');
const db = require('../src/config/db');
const notificationService = require('../src/services/notificationService');

describe('Notifications API Integration Tests', () => {
  let userA = null;
  let tokenA = null;
  let userB = null;
  let tokenB = null;
  let fridgeId = null;
  let notif1Id = null;
  let notif2Id = null;

  beforeAll(async () => {
    await db.initDbPool();

    const suffix = Date.now().toString().slice(-6);

    // Register User A
    userA = {
      username: `notif_uA_${suffix}`,
      email: `notif_uA_${suffix}@example.com`,
      password: 'Password123!',
    };
    const resA = await request(app).post('/api/auth/register').send(userA);
    expect(resA.statusCode).toBe(201);
    tokenA = resA.body.token;
    userA.id = resA.body.user.id;

    // Register User B
    userB = {
      username: `notif_uB_${suffix}`,
      email: `notif_uB_${suffix}@example.com`,
      password: 'Password123!',
    };
    const resB = await request(app).post('/api/auth/register').send(userB);
    expect(resB.statusCode).toBe(201);
    tokenB = resB.body.token;
    userB.id = resB.body.user.id;

    // Create a fridge for User A
    const fridgeRes = await request(app)
      .post('/api/fridges')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({ name: `Notif Test Fridge ${suffix}`, description: 'Testing notifications' });
    expect(fridgeRes.statusCode).toBe(201);
    fridgeId = fridgeRes.body.fridge.id;
  });

  afterAll(async () => {
    try {
      if (fridgeId) {
        await request(app)
          .delete(`/api/fridges/${fridgeId}`)
          .set('Authorization', `Bearer ${tokenA}`);
      }
      await db.closeDbPool();
    } catch (_) {}
  });

  describe('Authentication & Basic Listing', () => {
    it('rejects unauthenticated requests with 401', async () => {
      const res = await request(app).get('/api/notifications');
      expect(res.statusCode).toBe(401);
    });

    it('returns empty notifications list for a brand new user', async () => {
      const res = await request(app)
        .get('/api/notifications')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.statusCode).toBe(200);
      expect(Array.isArray(res.body.notifications)).toBe(true);
      expect(res.body.unreadCount).toBe(0);
    });

    it('returns unread-count as 0 initially', async () => {
      const res = await request(app)
        .get('/api/notifications/unread-count')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.unreadCount).toBe(0);
    });
  });

  describe('Notification Creation & Management', () => {
    it('creates in-app notifications directly via service for testing', async () => {
      const created1 = await notificationService.createNotification(
        userA.id,
        'invite',
        { title: 'Fridge Invitation', message: 'You have been invited to join a fridge', fridge_id: fridgeId }
      );
      notif1Id = created1.id;
      expect(created1.isRead).toBe(false);

      const created2 = await notificationService.createNotification(
        userA.id,
        'expiry',
        { title: 'Milk expires soon', message: 'Consume before expiry', fridge_id: fridgeId }
      );
      notif2Id = created2.id;
    });

    it('lists all notifications and calculates unread count accurately', async () => {
      const res = await request(app)
        .get('/api/notifications')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.notifications.length).toBeGreaterThanOrEqual(2);
      expect(res.body.unreadCount).toBeGreaterThanOrEqual(2);

      const ids = res.body.notifications.map(n => n.id);
      expect(ids).toContain(notif1Id);
      expect(ids).toContain(notif2Id);
    });

    it('gets accurate unread-count from endpoint', async () => {
      const res = await request(app)
        .get('/api/notifications/unread-count')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.unreadCount).toBeGreaterThanOrEqual(2);
    });

    it('marks a single notification as read', async () => {
      const res = await request(app)
        .patch(`/api/notifications/${notif1Id}/read`)
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);

      // Verify status in list
      const listRes = await request(app)
        .get('/api/notifications')
        .set('Authorization', `Bearer ${tokenA}`);

      const notif1 = listRes.body.notifications.find(n => n.id === notif1Id);
      expect(notif1.isRead).toBe(true);
    });

    it('marks all notifications as read', async () => {
      const res = await request(app)
        .patch('/api/notifications/read-all')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);

      const countRes = await request(app)
        .get('/api/notifications/unread-count')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(countRes.body.unreadCount).toBe(0);
    });

    it('deletes a single notification', async () => {
      const res = await request(app)
        .delete(`/api/notifications/${notif1Id}`)
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);

      const listRes = await request(app)
        .get('/api/notifications')
        .set('Authorization', `Bearer ${tokenA}`);

      const found = listRes.body.notifications.find(n => n.id === notif1Id);
      expect(found).toBeUndefined();
    });

    it('clears all notifications for the user', async () => {
      const res = await request(app)
        .delete('/api/notifications')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);

      const listRes = await request(app)
        .get('/api/notifications')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(listRes.body.notifications.length).toBe(0);
      expect(listRes.body.unreadCount).toBe(0);
    });
  });

  describe('User Isolation & Security', () => {
    let foreignNotifId = null;

    beforeAll(async () => {
      const created = await notificationService.createNotification(
        userA.id,
        'expiry',
        { title: 'User A Secret Item', message: 'Expires today' }
      );
      foreignNotifId = created.id;
    });

    it('User B cannot see User A notifications', async () => {
      const res = await request(app)
        .get('/api/notifications')
        .set('Authorization', `Bearer ${tokenB}`);

      expect(res.statusCode).toBe(200);
      const found = res.body.notifications.find(n => n.id === foreignNotifId);
      expect(found).toBeUndefined();
    });

    it('User B cannot mark User A notification as read', async () => {
      const res = await request(app)
        .patch(`/api/notifications/${foreignNotifId}/read`)
        .set('Authorization', `Bearer ${tokenB}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.updated).toBe(0);
    });

    it('User B cannot delete User A notification', async () => {
      const res = await request(app)
        .delete(`/api/notifications/${foreignNotifId}`)
        .set('Authorization', `Bearer ${tokenB}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.deleted).toBe(0);
    });
  });

  describe('Automated Expiry Alert Generation', () => {
    it('creates an item expiring tomorrow and triggers automatic expiry notification', async () => {
      const tomorrow = new Date();
      tomorrow.setDate(tomorrow.getDate() + 1);
      const tomorrowStr = tomorrow.toISOString().slice(0, 10);

      const itemRes = await request(app)
        .post(`/api/fridges/${fridgeId}/items`)
        .set('Authorization', `Bearer ${tokenA}`)
        .send({
          name: 'Fresh Strawberries',
          category: 'veggies',
          zone: 'fridge',
          quantity: 1,
          unit: 'pack',
          expiryDate: tomorrowStr,
        });

      expect(itemRes.statusCode).toBe(201);

      // Trigger expiry check
      const checkRes = await request(app)
        .post('/api/notifications/check-expiry')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(checkRes.statusCode).toBe(200);
      expect(checkRes.body.success).toBe(true);

      // Verify notification in list
      const listRes = await request(app)
        .get('/api/notifications')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(listRes.statusCode).toBe(200);
      const expiryNotif = listRes.body.notifications.find(
        n => n.type === 'expiry' && n.payload.item_id === itemRes.body.item.id
      );

      expect(expiryNotif).toBeDefined();
      expect(expiryNotif.payload.title).toContain('Fresh Strawberries');
      expect(expiryNotif.isRead).toBe(false);
    });
  });

  describe('Fridge Activity Notifications (Member Joined & Item Actions)', () => {
    let activityItemId = null;

    it('generates a member_joined notification for User A when User B accepts invite with inviter info', async () => {
      // 1. User A invites User B
      const invRes = await request(app)
        .post(`/api/fridges/${fridgeId}/invites`)
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ username: userB.username });

      expect(invRes.statusCode).toBe(201);
      const inviteId = invRes.body.invite.id;

      // 2. User B accepts invite
      const accRes = await request(app)
        .post(`/api/invites/${inviteId}/accept`)
        .set('Authorization', `Bearer ${tokenB}`);

      expect(accRes.statusCode).toBe(200);

      // 3. User A should have a member_joined notification specifying who joined and who invited them
      const notifsRes = await request(app)
        .get('/api/notifications')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(notifsRes.statusCode).toBe(200);
      const memberNotif = notifsRes.body.notifications.find(n => n.type === 'member_joined');
      expect(memberNotif).toBeDefined();
      expect(memberNotif.payload.joined_username).toBe(userB.username);
      expect(memberNotif.payload.invited_by_username).toBe(userA.username);
      expect(memberNotif.message).toContain(userB.username);
      expect(memberNotif.message).toContain(userA.username);
    });

    it('generates an item_added notification for User A when User B adds an item', async () => {
      const tomorrow = new Date();
      tomorrow.setDate(tomorrow.getDate() + 3);
      const tomorrowStr = tomorrow.toISOString().slice(0, 10);

      const addRes = await request(app)
        .post(`/api/fridges/${fridgeId}/items`)
        .set('Authorization', `Bearer ${tokenB}`)
        .send({
          name: 'Chocolate Pudding',
          category: 'meals',
          zone: 'fridge',
          quantity: 2,
          unit: 'cups',
          expiryDate: tomorrowStr,
        });

      expect(addRes.statusCode).toBe(201);
      activityItemId = addRes.body.item.id;

      // User A receives notification that User B added Chocolate Pudding
      const notifsRes = await request(app)
        .get('/api/notifications')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(notifsRes.statusCode).toBe(200);
      const addNotif = notifsRes.body.notifications.find(
        n => n.type === 'item_added' && n.payload.item_name === 'Chocolate Pudding'
      );
      expect(addNotif).toBeDefined();
      expect(addNotif.payload.by_username).toBe(userB.username);
      expect(addNotif.message).toContain('Chocolate Pudding');
    });

    it('generates an item_consumed notification for User A when User B eats the item', async () => {
      const consumeRes = await request(app)
        .post(`/api/fridges/${fridgeId}/items/${activityItemId}/consume`)
        .set('Authorization', `Bearer ${tokenB}`)
        .send({ amount: 1 });

      expect(consumeRes.statusCode).toBe(200);

      // User A receives notification that User B ate 1 cup
      const notifsRes = await request(app)
        .get('/api/notifications')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(notifsRes.statusCode).toBe(200);
      const consumeNotif = notifsRes.body.notifications.find(
        n => n.type === 'item_consumed' && n.payload.item_name === 'Chocolate Pudding'
      );
      expect(consumeNotif).toBeDefined();
      expect(consumeNotif.payload.by_username).toBe(userB.username);
      expect(consumeNotif.message).toContain(userB.username);
      expect(consumeNotif.message).toContain('Chocolate Pudding');
    });

    it('generates an item_deleted notification for User A when User B deletes the item', async () => {
      const delRes = await request(app)
        .delete(`/api/fridges/${fridgeId}/items/${activityItemId}`)
        .set('Authorization', `Bearer ${tokenB}`);

      expect(delRes.statusCode).toBe(200);

      // User A receives notification that User B removed the item
      const notifsRes = await request(app)
        .get('/api/notifications')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(notifsRes.statusCode).toBe(200);
      const delNotif = notifsRes.body.notifications.find(
        n => n.type === 'item_deleted' && n.payload.item_name === 'Chocolate Pudding'
      );
      expect(delNotif).toBeDefined();
      expect(delNotif.payload.by_username).toBe(userB.username);
      expect(delNotif.message).toContain('Chocolate Pudding');
    });
  });
});
