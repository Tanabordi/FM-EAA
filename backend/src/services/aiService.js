const { GoogleGenAI } = require('@google/genai');

const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

const PROMPT = `อ่านฉลากอาหารในรูปนี้ แล้วตอบเป็น JSON เท่านั้นตามรูปแบบนี้:
{
  "foodName": string|null,
  "expiryDate": "YYYY-MM-DD"|null,
  "category": "Proteins"|"Veggies"|"Beverages"|"Meals"|"Sauces",
  "storage": "Fridge"|"Freezer",
  "unit": "pieces"|"bag"|"punnet"|"bottle"|"box"|"can"|"pack"|"g"|"kg"
}
- foodName: คือชื่อสินค้าหรือชนิดวัตถุดิบ (ภาษาไทยหรืออังกฤษตามฉลาก)
- expiryDate: วันหมดอายุเท่านั้น (EXP, BBD, Best Before, ควรบริโภคก่อน, หมดอายุ) ห้ามใช้วันผลิต (MFD, MFG). แปลงเป็น ค.ศ. รูปแบบ YYYY-MM-DD ถ้าไม่พบให้ใส่ null อย่าเดา
- category: วิเคราะห์จากประเภทอาหาร
  * "Proteins": เนื้อสัตว์, หมู, ไก่, ปลา, กุ้ง, ไข่, ไส้กรอก, แฮม, เบคอน, เต้าหู้, ลูกชิ้น
  * "Veggies": ผักสด, ผลไม้สด, เห็ด
  * "Beverages": นม, น้ำดื่ม, น้ำผลไม้, ชา, กาแฟ, โซดา, เครื่องดื่ม
  * "Meals": อาหารปรุงสำเร็จ, ข้าวกล่อง, ข้าว, ก๋วยเตี๋ยว, แกง, ต้ม, ผัด, พาสต้า, พิซซ่า, แซนด์วิช, เบอร์เกอร์
  * "Sauces": ซอส, เครื่องปรุงรส, น้ำจิ้ม, ซีอิ๊ว, น้ำปลา, น้ำมัน, มายองเนส, แยม
- storage: ส่วนใหญ่แช่ตู้เย็นปกติ "Fridge" ยกเว้นสินค้าแช่แข็งหรือไอศกรีมให้เป็น "Freezer"
- unit: หน่วยที่เหมาะสมของบรรจุภัณฑ์ เช่น "pack" สำหรับไส้กรอก/เนื้อสัตว์, "bottle" สำหรับเครื่องดื่ม, "box" สำหรับอาหารกล่อง, "bag" สำหรับผักถุง, หรือ "pieces"`;

// Daily in-memory quota tracking per user: 15 generations per day
const DAILY_RECIPE_LIMIT = 15;
const recipeQuotaTracker = new Map();

function checkAndIncrementRecipeQuota(userId) {
  const today = new Date().toISOString().split('T')[0];
  const userRecord = recipeQuotaTracker.get(userId);

  if (!userRecord || userRecord.date !== today) {
    recipeQuotaTracker.set(userId, { date: today, count: 1 });
    return { allowed: true, remaining: DAILY_RECIPE_LIMIT - 1 };
  }

  if (userRecord.count >= DAILY_RECIPE_LIMIT) {
    return { allowed: false, remaining: 0 };
  }

  userRecord.count += 1;
  return { allowed: true, remaining: DAILY_RECIPE_LIMIT - userRecord.count };
}

function clearRecipeQuotaForTest() {
  recipeQuotaTracker.clear();
}

// Curated high quality food photos & assets
const DISH_IMAGES = {
  fried_rice: {
    imageUrl: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=800&q=80',
    assetFallback: 'assets/images/food_lasagna.png',
  },
  omelet: {
    imageUrl: 'https://images.unsplash.com/photo-1510693206972-df098062cb71?auto=format&fit=crop&w=800&q=80',
    assetFallback: 'assets/images/food_eggs.png',
  },
  stir_fry: {
    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80',
    assetFallback: 'assets/images/food_lasagna.png',
  },
  soup: {
    imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=800&q=80',
    assetFallback: 'assets/images/food_lasagna.png',
  },
  pasta: {
    imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3d5d6281699?auto=format&fit=crop&w=800&q=80',
    assetFallback: 'assets/images/food_lasagna.png',
  },
  noodles: {
    imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=800&q=80',
    assetFallback: 'assets/images/food_lasagna.png',
  },
  salad: {
    imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=800&q=80',
    assetFallback: 'assets/images/food_spinach.png',
  },
  sandwich: {
    imageUrl: 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=800&q=80',
    assetFallback: 'assets/images/food_lasagna.png',
  },
  sausage: {
    imageUrl: 'https://images.unsplash.com/photo-1585325701165-351af916e581?auto=format&fit=crop&w=800&q=80',
    assetFallback: 'assets/images/food_nuggets.png',
  },
  pancake: {
    imageUrl: 'https://images.unsplash.com/photo-1528207776546-365bb710ee93?auto=format&fit=crop&w=800&q=80',
    assetFallback: 'assets/images/food_strawberries.png',
  },
  smoothie: {
    imageUrl: 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?auto=format&fit=crop&w=800&q=80',
    assetFallback: 'assets/images/food_strawberries.png',
  },
  chicken: {
    imageUrl: 'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=800&q=80',
    assetFallback: 'assets/images/food_chicken_breasts.png',
  },
  default: {
    imageUrl: 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=800&q=80',
    assetFallback: 'assets/images/food_lasagna.png',
  },
};

function attachRecipeImages(recipe, mainIngredient) {
  const type = (recipe.dishType || '').toLowerCase();
  const lowerTitle = (recipe.title || '').toLowerCase();
  const lowerExp = (recipe.expiringIngredient || mainIngredient || '').toLowerCase();

  let mapping = DISH_IMAGES[type];
  if (!mapping) {
    if (lowerTitle.includes('ไข่') || lowerTitle.includes('omelet') || lowerTitle.includes('egg')) {
      mapping = DISH_IMAGES.omelet;
    } else if (lowerTitle.includes('ข้าวผัด') || lowerTitle.includes('fried rice')) {
      mapping = DISH_IMAGES.fried_rice;
    } else if (lowerTitle.includes('ผัด') || lowerTitle.includes('stir')) {
      mapping = DISH_IMAGES.stir_fry;
    } else if (lowerTitle.includes('ซุป') || lowerTitle.includes('soup') || lowerTitle.includes('ต้ม')) {
      mapping = DISH_IMAGES.soup;
    } else if (lowerTitle.includes('สลัด') || lowerTitle.includes('salad')) {
      mapping = DISH_IMAGES.salad;
    } else if (lowerTitle.includes('แซนด์วิช') || lowerTitle.includes('sandwich')) {
      mapping = DISH_IMAGES.sandwich;
    } else if (lowerExp.includes('ไส้กรอก') || lowerExp.includes('sausage') || lowerExp.includes('ค็อกเทล')) {
      mapping = DISH_IMAGES.sausage;
    } else if (lowerExp.includes('ไก่') || lowerExp.includes('chicken')) {
      mapping = DISH_IMAGES.chicken;
    } else if (lowerExp.includes('strawberr') || lowerExp.includes('สตรอว์')) {
      mapping = DISH_IMAGES.pancake;
    } else {
      mapping = DISH_IMAGES.default;
    }
  }

  return {
    ...recipe,
    imageUrl: recipe.imageUrl || mapping.imageUrl,
    assetFallback: recipe.assetFallback || mapping.assetFallback,
  };
}

function generateFallbackRecipes(mainIngredient, language = 'th') {
  const isEn = language === 'en';
  return [
    {
      id: 'recipe_fallback_1',
      title: isEn ? `Stir-fried ${mainIngredient} with Garlic` : `ผัดกระเทียมพริกไทย${mainIngredient}`,
      description: isEn ? 'Quick, aromatic, and comforting dish in under 10 minutes.' : 'หอมกลิ่นกระเทียมพริกไทย ทำง่าย รสกลมกล่อม',
      cookingTime: '10 min',
      difficulty: 'Very easy',
      dishType: 'stir_fry',
      expiringIngredient: mainIngredient,
      ingredients: [
        `${mainIngredient}`,
        isEn ? '3 cloves garlic, crushed' : 'กระเทียมสับ 3 กลีบ',
        isEn ? '1 tbsp soy sauce' : 'ซีอิ๊วขาว 1 ช้อนโต๊ะ',
        isEn ? '1 tbsp cooking oil' : 'น้ำมันพืช 1 ช้อนโต๊ะ',
        isEn ? 'Ground pepper to taste' : 'พริกไทยป่นเล็กน้อย',
      ],
      steps: [
        isEn ? 'Heat oil in a pan over medium heat and sauté garlic until fragrant.' : 'ตั้งกระทะใส่น้ำมัน นำกระเทียมลงผัดจนหอมกรุ่น',
        isEn ? `Add ${mainIngredient} and stir-fry for 3-5 minutes.` : `ใส่${mainIngredient}ลงไปผัดให้สุกและเข้ากัน 3-5 นาที`,
        isEn ? 'Season with soy sauce and pepper, then serve with warm rice.' : 'ปรุงรสด้วยซีอิ๊วขาวและพริกไทย ตักเสิร์ฟพร้อมข้าวสวยร้อนๆ',
      ],
    },
    {
      id: 'recipe_fallback_2',
      title: isEn ? `Golden Omelet with ${mainIngredient}` : `ไข่เจียวทรงเครื่องใส่${mainIngredient}`,
      description: isEn ? 'Fluffy eggs loaded with savory flavors.' : 'ไข่เจียวฟูนุ่มกรอบนอกนุ่มใน เข้ากันได้อย่างลงตัว',
      cookingTime: '10 min',
      difficulty: 'Very easy',
      dishType: 'omelet',
      expiringIngredient: mainIngredient,
      ingredients: [
        `${mainIngredient}`,
        isEn ? '2 large eggs' : 'ไข่ไก่ 2 ฟอง',
        isEn ? '1 tsp fish sauce or light soy sauce' : 'น้ำปลาหรือซีอิ๊วขาว 1 ช้อนชา',
        isEn ? 'Cooking oil for frying' : 'น้ำมันสำหรับทอด',
      ],
      steps: [
        isEn ? `Beat eggs together in a bowl and mix in chopped ${mainIngredient}.` : `ตอกไข่ใส่ชาม ตีให้เข้ากันแล้วใส่${mainIngredient}ที่หั่นพอดีคำลงไป`,
        isEn ? 'Heat oil in pan until hot, pour egg mixture and fry until golden.' : 'ตั้งน้ำมันให้ร้อน เทไข่ลงทอดจนเหลืองฟูกรอบทั้งสองด้าน',
        isEn ? 'Drain excess oil and serve hot.' : 'ตักขึ้นสะเด็ดน้ำมัน พร้อมรับประทาน',
      ],
    },
    {
      id: 'recipe_fallback_3',
      title: isEn ? `Quick Fried Rice with ${mainIngredient}` : `ข้าวผัดโบราณใส่${mainIngredient}`,
      description: isEn ? 'The ultimate zero-waste meal using leftover rice.' : 'เปลี่ยนข้าวสวยและวัตถุดิบเหลือให้เป็นมื้ออร่อยง่ายๆ',
      cookingTime: '15 min',
      difficulty: 'Easy',
      dishType: 'fried_rice',
      expiringIngredient: mainIngredient,
      ingredients: [
        `${mainIngredient}`,
        isEn ? '1 plate cooked jasmine rice' : 'ข้าวสวย 1 จาน',
        isEn ? '1 egg' : 'ไข่ไก่ 1 ฟอง',
        isEn ? '1 tbsp soy sauce' : 'ซีอิ๊วขาว 1 ช้อนโต๊ะ',
        isEn ? '1/2 tsp sugar' : 'น้ำตาลทราย 1/2 ช้อนชา',
      ],
      steps: [
        isEn ? 'Sauté garlic in a hot pan, add egg and scramble lightly.' : 'ผัดกระเทียมในกระทะ ตอกไข่ใส่แล้วยีพอสุก',
        isEn ? `Add ${mainIngredient} followed by cooked rice.` : `ใส่${mainIngredient}และข้าวสวยลงไป ผัดให้เข้ากัน`,
        isEn ? 'Season with soy sauce and sugar, stir over high heat for 2 minutes.' : 'ปรุงรสด้วยซีอิ๊วขาวและน้ำตาล ผัดไฟแรง 2 นาทีจนหอมกระทะ',
      ],
    },
    {
      id: 'recipe_fallback_4',
      title: isEn ? `Comforting Soup with ${mainIngredient}` : `ต้มจืดซุปร้อนๆ ใส่${mainIngredient}`,
      description: isEn ? 'Soothing clear broth that warms the soul.' : 'น้ำซุปใสกลมกล่อม ซดคล่องคอ สบายท้อง',
      cookingTime: '15 min',
      difficulty: 'Easy',
      dishType: 'soup',
      expiringIngredient: mainIngredient,
      ingredients: [
        `${mainIngredient}`,
        isEn ? '2 cups water or stock' : 'น้ำเปล่าหรือน้ำซุป 2 ถ้วย',
        isEn ? '1 tbsp light soy sauce' : 'ซีอิ๊วขาว 1 ช้อนโต๊ะ',
        isEn ? 'Spring onions or coriander for garnish' : 'ต้นหอมหรือผักชีโรยหน้า',
      ],
      steps: [
        isEn ? 'Bring water or broth to a boil in a pot.' : 'ตั้งน้ำให้เดือดในหม้อ',
        isEn ? `Add ${mainIngredient} and simmer for 5-8 minutes.` : `ใส่${mainIngredient}ลงไปต้มประมาณ 5-8 นาที`,
        isEn ? 'Season with light soy sauce and garnish with fresh herbs.' : 'ปรุงรสด้วยซีอิ๊วขาว โรยผักชีหรือต้นหอมก่อนเสิร์ฟ',
      ],
    },
    {
      id: 'recipe_fallback_5',
      title: isEn ? `Crispy ${mainIngredient} Salad` : `ยำหรือสลัดคลีนๆ ใส่${mainIngredient}`,
      description: isEn ? 'Refreshing and vibrant meal ready in minutes.' : 'รสชาติสดชื่น อิ่มเบาสบายท้อง ไม่เลี่ยน',
      cookingTime: '8 min',
      difficulty: 'Very easy',
      dishType: 'salad',
      expiringIngredient: mainIngredient,
      ingredients: [
        `${mainIngredient}`,
        isEn ? 'Assorted salad greens or tomatoes' : 'ผักสลัดหรือมะเขือเทศตามชอบ',
        isEn ? '1 tbsp lemon or lime juice' : 'น้ำมะนาว 1 ช้อนโต๊ะ',
        isEn ? '1 tbsp olive oil or dressing' : 'น้ำมันมะกอกหรือน้ำสลัด 1 ช้อนโต๊ะ',
      ],
      steps: [
        isEn ? `Warm or prepare ${mainIngredient}.` : `เตรียม${mainIngredient}ให้พร้อมรับประทาน`,
        isEn ? 'Combine greens in a bowl and arrange ingredients nicely.' : 'จัดผักสดใส่จาน วางวัตถุดิบลงไปให้สวยงาม',
        isEn ? 'Drizzle dressing and toss gently before eating.' : 'ราดน้ำสลัดหรือน้ำยำ คลุกเคล้าเบาๆ พร้อมเสิร์ฟ',
      ],
    },
    {
      id: 'recipe_fallback_6',
      title: isEn ? `Toasted Sandwich with ${mainIngredient}` : `แซนด์วิชขนมปังปิ้งไส้${mainIngredient}`,
      description: isEn ? 'Crispy, warm, and satisfying snack or breakfast.' : 'กรอบนอกนุ่มใน อร่อยอยู่ท้อง ทำเสร็จไวสุดๆ',
      cookingTime: '10 min',
      difficulty: 'Very easy',
      dishType: 'sandwich',
      expiringIngredient: mainIngredient,
      ingredients: [
        `${mainIngredient}`,
        isEn ? '2 slices bread' : 'ขนมปัง 2 แผ่น',
        isEn ? '1 tbsp mayo or butter' : 'มายองเนสหรือเนย 1 ช้อนโต๊ะ',
        isEn ? 'Cheese or lettuce (optional)' : 'ชีสหรือผักสลัด (ถ้ามี)',
      ],
      steps: [
        isEn ? 'Toast bread slices until golden brown.' : 'ปิ้งขนมปังให้เหลืองกรอบ',
        isEn ? `Spread mayo or butter, then layer with ${mainIngredient}.` : `ทามายองเนสหรือเนย วางไส้${mainIngredient}ลงไป`,
        isEn ? 'Cut in half diagonally and enjoy warm.' : 'ประกบขนมปัง หั่นครึ่ง พร้อมรับประทาน',
      ],
    },
  ];
}

async function scanLabel(buffer, mimeType) {
  let model = (process.env.GEMINI_MODEL || 'gemini-3.5-flash-lite').replace(/^["']|["']$/g, '');
  if (model.includes('2.5') || model.includes('1.5')) {
    model = 'gemini-3.5-flash-lite';
  }

  const res = await ai.models.generateContent({
    model,
    contents: [
      { inlineData: { mimeType, data: buffer.toString('base64') } },
      { text: PROMPT },
    ],
    config: { responseMimeType: 'application/json', temperature: 0.1 },
  });

  const candidate = res.candidates?.[0];
  if (candidate?.finishReason && !['STOP', 'MAX_TOKENS'].includes(candidate.finishReason)) {
    throw new Error(`AI generation stopped due to: ${candidate.finishReason}`);
  }
  if (!res.text) {
    throw new Error('AI returned an empty response');
  }

  try {
    return JSON.parse(res.text);
  } catch (err) {
    throw new Error('Failed to parse AI response into valid JSON');
  }
}

async function suggestRecipes({ userId, mainIngredient, fridgeIngredients = [], language = 'th' }) {
  // Check daily rate limit (15 requests/day per user)
  let remainingQuota = DAILY_RECIPE_LIMIT;
  if (userId) {
    const quota = checkAndIncrementRecipeQuota(userId);
    if (!quota.allowed) {
      const error = new Error('วันนี้คุณได้ไอเดียไปเยอะแล้ว ลองเลือกเมนูที่แนะนำไปทำอาหารอร่อยๆ กันก่อนนะ!');
      error.statusCode = 429;
      error.remainingQuota = 0;
      throw error;
    }
    remainingQuota = quota.remaining;
  }

  const otherItems = Array.isArray(fridgeIngredients) && fridgeIngredients.length > 0
    ? fridgeIngredients.filter((i) => i && typeof i === 'string' && i.toLowerCase() !== mainIngredient.toLowerCase()).join(', ')
    : '';

  const langInstruction = language === 'en'
    ? 'All recipe titles, descriptions, ingredients, and instructions MUST be in English.'
    : 'All recipe titles, descriptions, ingredients, and instructions MUST be in natural, friendly Thai (ภาษาไทยที่เข้าใจง่าย เป็นกันเอง).';

  const prompt = `คุณคือเชฟ AI ผู้เชี่ยวชาญการทำอาหารแบบ Zero-Waste เน้นทำง่าย ใช้เวลาน้อย (10-20 นาที) และใช้วัตถุดิบเท่าที่มี
วัตถุดิบหลักที่กำลังจะหมดอายุ: "${mainIngredient}"
${otherItems ? `วัตถุดิบอื่นในตู้เย็นที่อาจนำมาผสมผสานได้ (ถ้าเหมาะสม): ${otherItems}` : ''}

เป้าหมาย:
1. แนะนำเมนูอาหารที่ใช้ "${mainIngredient}" เป็นหลักจำนวน 6 เมนู (3 เมนูแรก และอีก 3 เมนูสำหรับตัวเลือกเพิ่มเติมที่หลากหลาย)
2. ทุกเมนูต้องทำง่าย ใช้วัตถุดิบเสริมน้อย เป็นของสามัญประจำบ้าน (เช่น ไข่ ข้าว น้ำมัน กระเทียม ซีอิ๊ว น้ำปลา เกลือ พริกไทย) ไม่ต้องซื้อของแปลกเพิ่ม
3. เวลาปรุงควรอยู่ระหว่าง 5-20 นาที ระดับความง่าย Easy หรือ Very easy
4. ${langInstruction}

ตอบกลับเป็น JSON array ของวัตถุ 6 รายการเท่านั้น ตามโครงสร้างดังนี้:
[
  {
    "id": "recipe_1",
    "title": "ชื่อเมนู",
    "description": "คำอธิบายสั้นๆ 1 ประโยค",
    "cookingTime": "15 min",
    "difficulty": "Easy",
    "dishType": "stir_fry",
    "expiringIngredient": "${mainIngredient}",
    "ingredients": ["วัตถุดิบพร้อมปริมาณ"],
    "steps": ["ขั้นตอนการทำสั้นกระชับ"]
  }
]`;

  let model = (process.env.GEMINI_MODEL || 'gemini-3.5-flash-lite').replace(/^["']|["']$/g, '');
  if (model.includes('2.5') || model.includes('1.5')) {
    model = 'gemini-3.5-flash-lite';
  }

  let recipes = [];

  try {
    const res = await ai.models.generateContent({
      model,
      contents: [{ text: prompt }],
      config: { responseMimeType: 'application/json', temperature: 0.3 },
    });

    if (res.text) {
      const parsed = JSON.parse(res.text);
      if (Array.isArray(parsed) && parsed.length > 0) {
        recipes = parsed;
      }
    }
  } catch (err) {
    // If Gemini fails or API key is not configured, fall back to smart dynamic recipes
    recipes = generateFallbackRecipes(mainIngredient, language);
  }

  if (recipes.length === 0) {
    recipes = generateFallbackRecipes(mainIngredient, language);
  }

  // Ensure 6 recipes and attach image/fallback assets
  const formattedRecipes = recipes.map((r, idx) => {
    return attachRecipeImages(
      {
        id: r.id || `recipe_${idx + 1}`,
        title: r.title || `Menu with ${mainIngredient}`,
        description: r.description || '',
        cookingTime: r.cookingTime || '15 min',
        difficulty: r.difficulty || 'Easy',
        dishType: r.dishType || 'stir_fry',
        expiringIngredient: r.expiringIngredient || mainIngredient,
        ingredients: Array.isArray(r.ingredients) ? r.ingredients : [],
        steps: Array.isArray(r.steps) ? r.steps : [],
      },
      mainIngredient
    );
  });

  return {
    recipes: formattedRecipes,
    remainingDailyQuota: remainingQuota,
  };
}

module.exports = {
  scanLabel,
  suggestRecipes,
  checkAndIncrementRecipeQuota,
  clearRecipeQuotaForTest,
  generateFallbackRecipes,
  DISH_IMAGES,
};
