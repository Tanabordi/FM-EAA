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

