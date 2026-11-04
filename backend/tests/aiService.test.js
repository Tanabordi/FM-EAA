const {
  checkAndIncrementRecipeQuota,
  clearRecipeQuotaForTest,
  generateFallbackRecipes,
} = require('../src/services/aiService');

describe('AI Service Quota & Recipe Logic', () => {
  beforeEach(() => {
    clearRecipeQuotaForTest();
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
});
