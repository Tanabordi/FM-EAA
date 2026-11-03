process.env.NODE_ENV = 'test';
const request = require('supertest');
const app = require('../src/app');
const db = require('../src/config/db');

describe('Fridge & Item CRUD API Integration Tests', () => {
  let authToken = null;
  let testUser = null;
  let createdFridgeId = null;
  let createdItemId = null;
  let consumeHistoryId = null;

  beforeAll(async () => {
    await db.initDbPool();

    // Register a unique test user for this test suite
    const uniqueSuffix = Date.now().toString().slice(-6);
    testUser = {
      username: `fridge_u_${uniqueSuffix}`,
      email: `fridge_${uniqueSuffix}@example.com`,
      password: 'Password123!',
    };

    const regRes = await request(app)
      .post('/api/auth/register')
      .send(testUser);

    expect(regRes.statusCode).toBe(201);
    authToken = regRes.body.token;
    expect(authToken).toBeDefined();
  });

  afterAll(async () => {
    await db.closeDbPool();
  });

  // ==========================================
  // 1. Fridge CRUD Tests
  // ==========================================
  describe('Fridge Management (/api/fridges)', () => {
    it('requires authentication to access /api/fridges', async () => {
      const res = await request(app).get('/api/fridges');
      expect(res.statusCode).toBe(401);
    });

    it('fails to create a fridge without a name', async () => {
      const res = await request(app)
        .post('/api/fridges')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ description: 'No name fridge' });

      expect(res.statusCode).toBe(400);
      expect(res.body).toHaveProperty('error');
    });

    it('successfully creates a new fridge', async () => {
      const res = await request(app)
        .post('/api/fridges')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          name: 'Kitchen Main Fridge',
          description: 'Our primary kitchen refrigerator',
        });

      expect(res.statusCode).toBe(201);
      expect(res.body).toHaveProperty('success', true);
      expect(res.body.fridge).toHaveProperty('id');
      expect(res.body.fridge.name).toBe('Kitchen Main Fridge');
      expect(res.body.fridge.role).toBe('owner');

      createdFridgeId = res.body.fridge.id;
    });

    it('lists fridges that the user belongs to', async () => {
      const res = await request(app)
        .get('/api/fridges')
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('fridges');
      expect(Array.isArray(res.body.fridges)).toBe(true);
      expect(res.body.fridges.some(f => f.id === createdFridgeId)).toBe(true);
    });

    it('retrieves single fridge details with member list', async () => {
      const res = await request(app)
        .get(`/api/fridges/${createdFridgeId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.fridge).toHaveProperty('id', createdFridgeId);
      expect(res.body.fridge).toHaveProperty('members');
      expect(res.body.fridge.members.length).toBeGreaterThanOrEqual(1);
      expect(res.body.fridge.members[0].username).toBe(testUser.username);
    });

    it('updates fridge name and description', async () => {
      const res = await request(app)
        .patch(`/api/fridges/${createdFridgeId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          name: 'Updated Kitchen Fridge',
          description: 'Updated fridge description',
        });

      expect(res.statusCode).toBe(200);
      expect(res.body.fridge.name).toBe('Updated Kitchen Fridge');
      expect(res.body.fridge.description).toBe('Updated fridge description');
    });

    it('lists members of the fridge via /api/fridges/:id/members', async () => {
      const res = await request(app)
        .get(`/api/fridges/${createdFridgeId}/members`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('members');
      expect(Array.isArray(res.body.members)).toBe(true);
    });
  });

  // ==========================================
  // 2. Item CRUD Tests
  // ==========================================
  describe('Item Management (/api/fridges/:id/items)', () => {
    it('fails to create an item with missing or invalid fields', async () => {
      const res = await request(app)
        .post(`/api/fridges/${createdFridgeId}/items`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          name: 'Test Milk',
          // missing category and expiryDate
        });

      expect(res.statusCode).toBe(400);
    });

    it('fails to create an item with an invalid category', async () => {
      const res = await request(app)
        .post(`/api/fridges/${createdFridgeId}/items`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          name: 'Apple',
          category: 'invalid_category_xyz',
          zone: 'fridge',
          quantity: 2,
          expiryDate: '2026-12-31',
        });

      expect(res.statusCode).toBe(400);
      expect(res.body.error).toContain('Category must be one of');
    });

    it('successfully creates an item in the fridge', async () => {
      const res = await request(app)
        .post(`/api/fridges/${createdFridgeId}/items`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          name: 'Fresh Cow Milk',
          category: 'beverages',
          zone: 'fridge',
          quantity: 3,
          unit: 'bottles',
          expiryDate: '2026-11-20',
          imagePath: '/images/milk.png',
        });

      expect(res.statusCode).toBe(201);
      expect(res.body).toHaveProperty('success', true);
      expect(res.body.item).toHaveProperty('id');
      expect(res.body.item.name).toBe('Fresh Cow Milk');
      expect(res.body.item.category).toBe('beverages');
      expect(res.body.item.quantity).toBe(3);
      expect(res.body.item.expiryDate).toBe('2026-11-20');

      createdItemId = res.body.item.id;
    });

    it('creates a second item in freezer zone', async () => {
      const res = await request(app)
        .post(`/api/fridges/${createdFridgeId}/items`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          name: 'Pork Tenderloin',
          category: 'proteins',
          zone: 'freezer',
          quantity: 1,
          unit: 'kg',
          expiryDate: '2026-12-15',
        });

      expect(res.statusCode).toBe(201);
      expect(res.body.item.zone).toBe('freezer');
    });

    it('lists items in the fridge with zone filter', async () => {
      const res = await request(app)
        .get(`/api/fridges/${createdFridgeId}/items?zone=fridge`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('items');
      expect(Array.isArray(res.body.items)).toBe(true);
      expect(res.body.items.every(i => i.zone === 'fridge')).toBe(true);
      expect(res.body.items.some(i => i.id === createdItemId)).toBe(true);
    });

    it('lists items in the fridge with category filter', async () => {
      const res = await request(app)
        .get(`/api/fridges/${createdFridgeId}/items?category=beverages`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.items.every(i => i.category === 'beverages')).toBe(true);
    });

    it('retrieves single item details by id', async () => {
      const res = await request(app)
        .get(`/api/fridges/${createdFridgeId}/items/${createdItemId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.item.id).toBe(createdItemId);
      expect(res.body.item.name).toBe('Fresh Cow Milk');
    });

    it('updates item details (e.g. quantity and unit)', async () => {
      const res = await request(app)
        .patch(`/api/fridges/${createdFridgeId}/items/${createdItemId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          quantity: 5,
          unit: 'packs',
        });

      expect(res.statusCode).toBe(200);
      expect(res.body.item.quantity).toBe(5);
      expect(res.body.item.unit).toBe('packs');
    });
  });

  // ==========================================
  // 3. Item Consumption & History Tests
  // ==========================================
  describe('Consumption & History Flow', () => {
    it('consumes partial item quantity and records in history', async () => {
      const res = await request(app)
        .post(`/api/fridges/${createdFridgeId}/items/${createdItemId}/consume`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({ amount: 2 });

      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('success', true);
      expect(res.body.consumedAmount).toBe(2);
      expect(res.body.quantityLeft).toBe(3); // 5 - 2 = 3
      expect(res.body).toHaveProperty('historyId');

      consumeHistoryId = res.body.historyId;
    });

    it('retrieves consumption history for fridge', async () => {
      const res = await request(app)
        .get(`/api/fridges/${createdFridgeId}/history?kind=consumed`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('history');
      expect(Array.isArray(res.body.history)).toBe(true);
      expect(res.body.history.some(h => h.id === consumeHistoryId)).toBe(true);
    });

    it('successfully undoes consumption and restores quantity', async () => {
      const res = await request(app)
        .post(`/api/fridges/${createdFridgeId}/items/${createdItemId}/consume/undo`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({ historyId: consumeHistoryId });

      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('success', true);
      expect(res.body.restoredQuantity).toBe(2);

      // Verify item quantity is restored to 5 (3 + 2 = 5)
      const itemRes = await request(app)
        .get(`/api/fridges/${createdFridgeId}/items/${createdItemId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(itemRes.body.item.quantity).toBe(5);
    });

    it('consumes with finishAll: true which deletes the item from items table', async () => {
      const res = await request(app)
        .post(`/api/fridges/${createdFridgeId}/items/${createdItemId}/consume`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({ finishAll: true });

      expect(res.statusCode).toBe(200);
      expect(res.body.finishedAll).toBe(true);
      expect(res.body.quantityLeft).toBe(0);

      // Verify item is no longer in items list
      const checkRes = await request(app)
        .get(`/api/fridges/${createdFridgeId}/items/${createdItemId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(checkRes.statusCode).toBe(404);
    });

    it('clears consumption history', async () => {
      const res = await request(app)
        .delete(`/api/fridges/${createdFridgeId}/history/clear?kind=consumed`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('success', true);
    });
  });

  // ==========================================
  // 4. Fridge Deletion Tests
  // ==========================================
  describe('Fridge Deletion Cascade', () => {
    it('successfully deletes fridge', async () => {
      const res = await request(app)
        .delete(`/api/fridges/${createdFridgeId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('success', true);
    });

    it('returns 404 when querying deleted fridge', async () => {
      const res = await request(app)
        .get(`/api/fridges/${createdFridgeId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.statusCode).toBe(404);
    });
  });
});
