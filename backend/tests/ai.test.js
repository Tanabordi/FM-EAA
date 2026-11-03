const request = require('supertest');
const jwt = require('jsonwebtoken');
const app = require('../src/app');
const config = require('../src/config/env');
const aiService = require('../src/services/aiService');

// Mock aiService
jest.mock('../src/services/aiService');

describe('AI Label Scanning Routes (/api/ai/scan-label)', () => {
  const validToken = jwt.sign(
    { userId: 'user_1', email: 'chanin@kmitl.ac.th' },
    config.jwt.secret,
    { expiresIn: '1h' }
  );

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should return 401 Unauthorized if no Bearer token is provided', async () => {
    const res = await request(app).post('/api/ai/scan-label');
    expect(res.statusCode).toBe(401);
    expect(res.body).toHaveProperty('error');
  });

  it('should return 403 Forbidden if invalid token is provided', async () => {
    const res = await request(app)
      .post('/api/ai/scan-label')
      .set('Authorization', 'Bearer invalid_token');
    expect(res.statusCode).toBe(403);
    expect(res.body).toHaveProperty('error', 'Invalid or expired token');
  });

  it('should return 400 Bad Request if no image file is attached', async () => {
    const res = await request(app)
      .post('/api/ai/scan-label')
      .set('Authorization', `Bearer ${validToken}`);
    expect(res.statusCode).toBe(400);
    expect(res.body).toHaveProperty('error', 'image is required');
  });

  it('should return 400 Bad Request if unsupported file type is uploaded', async () => {
    const res = await request(app)
      .post('/api/ai/scan-label')
      .set('Authorization', `Bearer ${validToken}`)
      .attach('image', Buffer.from('hello world'), 'document.txt');
    expect(res.statusCode).toBe(400);
    expect(res.body.error).toContain('Only JPEG, PNG, WebP, and HEIC are supported');
  });

  it('should return 200 OK and scan result when valid image is analyzed', async () => {
    const mockResult = {
      foodName: 'Dutch Mill Milk 830ml',
      expiryDate: '2026-11-20',
    };
    aiService.scanLabel.mockResolvedValueOnce(mockResult);

    const dummyImage = Buffer.from('fake_image_bytes');

    const res = await request(app)
      .post('/api/ai/scan-label')
      .set('Authorization', `Bearer ${validToken}`)
      .attach('image', dummyImage, 'label.jpg');

    expect(res.statusCode).toBe(200);
    expect(res.body).toEqual(mockResult);
    expect(aiService.scanLabel).toHaveBeenCalledTimes(1);
  });

  it('should return 500 when AI service fails or throws', async () => {
    aiService.scanLabel.mockRejectedValueOnce(new Error('Gemini API quota exceeded'));

    const dummyImage = Buffer.from('fake_image_bytes');

    const res = await request(app)
      .post('/api/ai/scan-label')
      .set('Authorization', `Bearer ${validToken}`)
      .attach('image', dummyImage, 'label.png');

    expect(res.statusCode).toBe(500);
    expect(res.body).toHaveProperty('error');
  });
});

describe('AI Recipe Suggestion Routes (/api/ai/recipes)', () => {
  const validToken = jwt.sign(
    { userId: 'user_chef_1', email: 'chef@kmitl.ac.th' },
    config.jwt.secret,
    { expiresIn: '1h' }
  );

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should return 401 Unauthorized if no Bearer token is provided', async () => {
    const res = await request(app)
      .post('/api/ai/recipes')
      .send({ mainIngredient: 'ค็อกเทลรมควัน' });
    expect(res.statusCode).toBe(401);
    expect(res.body).toHaveProperty('error');
  });

  it('should return 400 Bad Request if mainIngredient is missing', async () => {
    const res = await request(app)
      .post('/api/ai/recipes')
      .set('Authorization', `Bearer ${validToken}`)
      .send({});
    expect(res.statusCode).toBe(400);
    expect(res.body).toHaveProperty('error', 'mainIngredient is required');
  });

  it('should return 200 OK and recipe suggestions when mainIngredient is provided', async () => {
    const mockRecipeResponse = {
      recipes: [
        {
          id: 'rec_1',
          title: 'ผัดกะเพราค็อกเทลรมควัน',
          cookingTime: '10 min',
          difficulty: 'Easy',
          expiringIngredient: 'ค็อกเทลรมควัน',
          ingredients: ['ค็อกเทลรมควัน', 'ใบกะเพรา', 'พริกกระเทียม'],
          steps: ['ผัดพริกกระเทียม', 'ใส่ไส้กรอกค็อกเทล', 'ปรุงรส'],
          imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
          assetFallback: 'assets/images/food_nuggets.png',
        },
      ],
      remainingDailyQuota: 14,
    };
    aiService.suggestRecipes.mockResolvedValueOnce(mockRecipeResponse);

    const res = await request(app)
      .post('/api/ai/recipes')
      .set('Authorization', `Bearer ${validToken}`)
      .send({
        mainIngredient: 'ค็อกเทลรมควัน',
        fridgeIngredients: ['ไข่ไก่', 'ข้าวสวย'],
      });

    expect(res.statusCode).toBe(200);
    expect(res.body).toEqual(mockRecipeResponse);
    expect(aiService.suggestRecipes).toHaveBeenCalledWith({
      userId: 'user_chef_1',
      mainIngredient: 'ค็อกเทลรมควัน',
      fridgeIngredients: ['ไข่ไก่', 'ข้าวสวย'],
      language: 'th',
    });
  });

  it('should return 429 when user daily quota is reached', async () => {
    const quotaError = new Error('วันนี้คุณได้ไอเดียไปเยอะแล้ว ลองเลือกเมนูที่แนะนำไปทำอาหารอร่อยๆ กันก่อนนะ!');
    quotaError.statusCode = 429;
    aiService.suggestRecipes.mockRejectedValueOnce(quotaError);

    const res = await request(app)
      .post('/api/ai/recipes')
      .set('Authorization', `Bearer ${validToken}`)
      .send({ mainIngredient: 'ค็อกเทลรมควัน' });

    expect(res.statusCode).toBe(429);
    expect(res.body.error).toContain('วันนี้คุณได้ไอเดียไปเยอะแล้ว');
    expect(res.body.remainingDailyQuota).toBe(0);
  });
});
