const mockGenerateContent = jest.fn();

jest.mock('@google/genai', () => ({
  GoogleGenAI: jest.fn().mockImplementation(() => ({
    models: {
      generateContent: mockGenerateContent,
    },
  })),
}));

const {
  scanLabel,
  suggestRecipes,
  checkAndIncrementRecipeQuota,
  getRecipeQuota,
  clearRecipeQuotaForTest,
  generateFallbackRecipes,
  detectCategory,
  translateThaiIngredientToEn,
} = require('../src/services/aiService');

describe('AI Service Quota & Recipe Logic', () => {
  beforeEach(() => {
    clearRecipeQuotaForTest();
    jest.clearAllMocks();
  });

  it('should track quota up to 3 times and reject the 4th attempt with allowed: false', () => {
    const userId = 'user_test_limit';
    for (let i = 1; i <= 3; i++) {
      const quota = checkAndIncrementRecipeQuota(userId);
      expect(quota.allowed).toBe(true);
      expect(quota.used).toBe(i);
      expect(quota.remaining).toBe(3 - i);
    }

    const exceeded = checkAndIncrementRecipeQuota(userId);
    expect(exceeded.allowed).toBe(false);
    expect(exceeded.remaining).toBe(0);
  });

  it('should correctly get quota state without incrementing', () => {
    const userId = 'user_get_quota';
    const initQuota = getRecipeQuota(userId, 'Shrimp');
    expect(initQuota.used).toBe(0);
    expect(initQuota.remaining).toBe(3);
    expect(initQuota.limit).toBe(3);

    checkAndIncrementRecipeQuota(userId, 'Shrimp');
    const updatedQuota = getRecipeQuota(userId, 'Shrimp');
    expect(updatedQuota.used).toBe(1);
    expect(updatedQuota.remaining).toBe(2);
  });

  it('should track quota independently per ingredient so different items do not block each other', () => {
    const userId = 'user_multi_items';
    // Use up all 3 quotas for Item A
    for (let i = 1; i <= 3; i++) {
      const quotaA = checkAndIncrementRecipeQuota(userId, 'Sausage');
      expect(quotaA.allowed).toBe(true);
      expect(quotaA.used).toBe(i);
    }
    expect(checkAndIncrementRecipeQuota(userId, 'Sausage').allowed).toBe(false);

    // Item B should still have full 3 quotas available
    const quotaB = checkAndIncrementRecipeQuota(userId, 'Strawberries');
    expect(quotaB.allowed).toBe(true);
    expect(quotaB.used).toBe(1);
    expect(quotaB.remaining).toBe(2);
  });

  it('should correctly translate Thai ingredients to English', () => {
    expect(translateThaiIngredientToEn('ค็อกเทลรมควัน')).toBe('Smoked Cocktail Sausage');
    expect(translateThaiIngredientToEn('ไก่ย่าง')).toBe('Chicken');
    expect(translateThaiIngredientToEn('เนื้อมหัศจรรย์ไม่มีในดิก')).toBe('Ingredient');
    expect(translateThaiIngredientToEn('Fresh Milk')).toBe('Fresh Milk');
    expect(translateThaiIngredientToEn(null)).toBe(null);
    expect(translateThaiIngredientToEn(12345)).toBe(12345);
  });

  it('should generate 6 fallback recipes with mainIngredient when offline or API unavailable', () => {
    const recipes = generateFallbackRecipes('ค็อกเทลรมควัน', 'th');
    expect(recipes).toHaveLength(6);
    expect(recipes[0].expiringIngredient).toBe('ค็อกเทลรมควัน');
    expect(recipes[0].title).toContain('ค็อกเทลรมควัน');
    expect(recipes[1].title).toContain('ค็อกเทลรมควัน');
  });

  it('should generate 6 fallback recipes in English when language is en even for Thai ingredient', () => {
    const recipes = generateFallbackRecipes('ค็อกเทลรมควัน', 'en');
    expect(recipes).toHaveLength(6);
    expect(recipes[0].expiringIngredient).toBe('Smoked Cocktail Sausage');
    expect(recipes[0].title).toBe('Stir-fried Smoked Cocktail Sausage with Garlic & Pepper');
    expect(recipes[1].title).toBe('Golden Fluffy Omelet with Smoked Cocktail Sausage');
  });

  it('should correctly detect categories from ingredient names or explicit category', () => {
    expect(detectCategory('Cold Brew Coffee')).toBe('beverages');
    expect(detectCategory('นมสด')).toBe('beverages');
    expect(detectCategory('Orange Juice')).toBe('beverages');
    expect(detectCategory('Tomato Ketchup')).toBe('sauces');
    expect(detectCategory('มายองเนส')).toBe('sauces');
    expect(detectCategory('Baby Spinach')).toBe('veggies');
    expect(detectCategory('หมูสับ')).toBe('proteins');
    expect(detectCategory('Fried Rice Leftover')).toBe('meals');
    // Explicit override
    expect(detectCategory('Something strange', 'beverages')).toBe('beverages');
    expect(detectCategory('Something strange', 'sauces')).toBe('sauces');
    expect(detectCategory('Something strange', 'proteins')).toBe('proteins');
    expect(detectCategory('Something strange', 'veggies')).toBe('veggies');
    expect(detectCategory('Something strange', 'meals')).toBe('meals');
  });

  it('should generate beverage-appropriate recipes for beverages category and never savory fried rice/garlic stir-fry', () => {
    const recipes = generateFallbackRecipes('Milk', 'en', 0, 'beverages');
    expect(recipes).toHaveLength(6);
    const titles = recipes.map((r) => r.title.toLowerCase());
    expect(titles.some((t) => t.includes('garlic') && t.includes('stir-fry'))).toBe(false);
    expect(titles.some((t) => t.includes('fried rice'))).toBe(false);
    expect(titles.some((t) => t.includes('smoothie') || t.includes('pancake') || t.includes('latte') || t.includes('splash') || t.includes('pudding'))).toBe(true);
  });

  it('should generate sauce-appropriate recipes for sauces category', () => {
    const recipes = generateFallbackRecipes('Ketchup', 'en', 0, 'sauces');
    expect(recipes).toHaveLength(6);
    const titles = recipes.map((r) => r.title.toLowerCase());
    expect(titles.some((t) => t.includes('glazed') || t.includes('pasta') || t.includes('dressing') || t.includes('toast') || t.includes('dip'))).toBe(true);
  });

  it('should generate recipes for all categories with offset variation', () => {
    const vegRecipes = generateFallbackRecipes('Carrot', 'en', 1, 'veggies');
    expect(vegRecipes).toHaveLength(6);
    const mealRecipes = generateFallbackRecipes('Rice', 'th', 2, 'meals');
    expect(mealRecipes).toHaveLength(6);
  });

  describe('scanLabel AI detection tests', () => {
    const sampleBuffer = Buffer.from('fake_image_bytes');

    it('successfully parses full food scan result from Gemini AI', async () => {
      mockGenerateContent.mockResolvedValueOnce({
        candidates: [{ finishReason: 'STOP' }],
        text: JSON.stringify({
          is_food: true,
          foodName: 'นมสดเมจิ',
          expiryDate: '2026-11-30',
          category: 'Beverages',
          storage: 'Fridge',
          unit: 'bottle',
          confidence: 0.96,
        }),
      });

      const res = await scanLabel(sampleBuffer, 'image/jpeg', 'th', 'full');
      expect(res.is_food).toBe(true);
      expect(res.foodName).toBe('นมสดเมจิ');
      expect(res.expiryDate).toBe('2026-11-30');
      expect(res.category).toBe('Beverages');
    });

    it('handles non-food detection correctly in full mode', async () => {
      mockGenerateContent.mockResolvedValueOnce({
        candidates: [{ finishReason: 'STOP' }],
        text: JSON.stringify({
          is_food: false,
          foodName: 'Keyboard',
          expiryDate: null,
          category: 'Meals',
          storage: 'Fridge',
          unit: 'pieces',
        }),
      });

      const res = await scanLabel(sampleBuffer, 'image/png', 'en', 'full');
      expect(res.is_food).toBe(false);
      expect(res.foodName).toBeNull();
      expect(res.confidence).toBe(0.0);
    });

    it('handles missing is_food and confidence fields gracefully', async () => {
      mockGenerateContent.mockResolvedValueOnce({
        candidates: [{ finishReason: 'STOP' }],
        text: JSON.stringify({
          foodName: 'Egg',
          expiryDate: '2026-12-01',
        }),
      });

      const res = await scanLabel(sampleBuffer, 'image/jpeg');
      expect(res.is_food).toBe(true);
      expect(res.confidence).toBe(0.9);
    });

    it('extracts expiry date correctly in expiry_only mode', async () => {
      mockGenerateContent.mockResolvedValueOnce({
        candidates: [{ finishReason: 'STOP' }],
        text: JSON.stringify({
          expiryDate: '2026-12-25',
          confidence: 0.95,
        }),
      });

      const res = await scanLabel(sampleBuffer, 'image/jpeg', 'en', 'expiry_only');
      expect(res.expiryDate).toBe('2026-12-25');
      expect(res.confidence).toBe(0.95);
    });

    it('throws error when finishReason is not STOP or MAX_TOKENS', async () => {
      mockGenerateContent.mockResolvedValueOnce({
        candidates: [{ finishReason: 'SAFETY' }],
        text: '{}',
      });

      await expect(scanLabel(sampleBuffer, 'image/jpeg')).rejects.toThrow('AI generation stopped due to: SAFETY');
    });

    it('throws error when AI returns empty text', async () => {
      mockGenerateContent.mockResolvedValueOnce({
        candidates: [{ finishReason: 'STOP' }],
        text: '',
      });

      await expect(scanLabel(sampleBuffer, 'image/jpeg')).rejects.toThrow('AI returned an empty response');
    });

    it('throws error when AI response is not valid JSON', async () => {
      mockGenerateContent.mockResolvedValueOnce({
        candidates: [{ finishReason: 'STOP' }],
        text: 'This is not valid json at all',
      });

      await expect(scanLabel(sampleBuffer, 'image/jpeg')).rejects.toThrow('Failed to parse AI response into valid JSON');
    });
  });

  describe('suggestRecipes AI & Fallback tests', () => {
    it('suggests recipes using Gemini and maps Thai difficulty levels', async () => {
      mockGenerateContent.mockResolvedValueOnce({
        candidates: [{ finishReason: 'STOP' }],
        text: JSON.stringify([
          {
            id: 'r_1',
            title: 'ข้าวผัดไก่',
            description: 'ข้าวผัดแสนอร่อย',
            cookingTime: '15 mins',
            difficulty: 'easy',
            dishType: 'fried_rice',
            ingredients: ['ข้าวสวย', 'เนื้อไก่'],
            steps: ['ผัดไก่', 'ใส่ข้าว', 'ปรุงรส'],
          },
          {
            id: 'r_2',
            title: 'ซุปไก่ใส',
            description: 'ซุปร้อนๆ ชุ่มคอ',
            cookingTime: '25 mins',
            difficulty: 'very easy',
            dishType: 'soup',
            ingredients: ['ไก่', 'น้ำซุป'],
            steps: ['ต้มน้ำ', 'ใส่ไก่'],
          },
          {
            id: 'r_3',
            title: 'สลัดไก่ฉีก',
            description: 'สลัดเพื่อสุขภาพ',
            cookingTime: '10 mins',
            difficulty: 'medium',
            dishType: 'salad',
            ingredients: ['ผักสลัด', 'ไก่ฉีก'],
            steps: ['คลุกเคล้า'],
          },
          {
            id: 'r_4',
            title: 'พาสต้าไก่ครีมซอส',
            description: 'พาสต้าเข้มข้น',
            cookingTime: '20 mins',
            difficulty: 'hard',
            dishType: 'pasta',
            ingredients: ['เส้นพาสต้า', 'ไก่'],
            steps: ['ต้มเส้น', 'ผัดซอส'],
          },
        ]),
      });

      const res = await suggestRecipes({
        userId: 'user_suggest_test',
        mainIngredient: 'ไก่',
        category: 'proteins',
        language: 'th',
      });

      expect(res.recipes).toHaveLength(4);
      expect(res.recipes[0].difficulty).toBe('ง่าย');
      expect(res.recipes[1].difficulty).toBe('ง่ายมาก');
      expect(res.recipes[2].difficulty).toBe('ปานกลาง');
      expect(res.recipes[3].difficulty).toBe('ยาก');
      expect(res.usedDailyQuota).toBe(1);
      expect(res.remainingDailyQuota).toBe(2);
      expect(res.recipes[0].imageUrl).toBeDefined();
    });

    it('falls back to smart fallback recipes when AI returns invalid format or fails', async () => {
      mockGenerateContent.mockResolvedValueOnce({
        candidates: [{ finishReason: 'STOP' }],
        text: 'Invalid AI response',
      });

      const res = await suggestRecipes({
        userId: 'user_fallback_test',
        mainIngredient: 'Salmon',
        category: 'proteins',
        language: 'en',
      });

      expect(res.recipes).toHaveLength(6);
      expect(res.usedDailyQuota).toBe(1);
      expect(res.recipes[0].expiringIngredient).toBe('Salmon');
    });

    it('attaches image styles correctly for various dish styles', async () => {
      mockGenerateContent.mockResolvedValueOnce({
        candidates: [{ finishReason: 'STOP' }],
        text: JSON.stringify([
          { title: 'ไข่เจียวสมุนไพร', dishType: 'omelet' },
          { title: 'แซนด์วิชทูน่า', dishType: 'sandwich' },
          { title: 'สมูทตี้กล้วยหอม', dishType: 'smoothie' },
          { title: 'แพนเค้กเนยสด', dishType: 'pancake' },
          { title: 'ชาเขียวลาเต้', dishType: 'beverage' },
          { title: 'น้ำจิ้มแจ่วสูตรเด็ด', dishType: 'sauce' },
          { title: 'สเต็กไส้กรอกย่าง', dishType: 'sausage' },
          { title: 'สลัดแครอทขูด', dishType: 'carrot' },
        ]),
      });

      const res = await suggestRecipes({
        userId: 'user_dish_types',
        mainIngredient: 'Egg',
        category: 'proteins',
        language: 'th',
      });

      expect(res.recipes).toHaveLength(6);
      expect(res.recipes[0].assetFallback).toBe('assets/images/food_eggs.png');
      expect(res.recipes[0].imageUrl).toBeDefined();
      expect(res.recipes[1].imageUrl).toBeDefined();
      expect(res.recipes[2].imageUrl).toBeDefined();
      expect(res.recipes[3].imageUrl).toBeDefined();
      expect(res.recipes[4].imageUrl).toBeDefined();
      expect(res.recipes[5].imageUrl).toBeDefined();
    });

    it('returns error when user exceeds daily recipe limit', async () => {
      const userId = 'quota_exceeded_user';
      checkAndIncrementRecipeQuota(userId, 'Beef');
      checkAndIncrementRecipeQuota(userId, 'Beef');
      checkAndIncrementRecipeQuota(userId, 'Beef');

      await expect(
        suggestRecipes({
          userId,
          mainIngredient: 'Beef',
          category: 'proteins',
          language: 'en',
        })
      ).rejects.toThrow('daily limit of 3 recipe generations');
    });
  });
});

