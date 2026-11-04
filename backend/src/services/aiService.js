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

// Daily in-memory quota tracking per user: 3 generations per day
const DAILY_RECIPE_LIMIT = 3;
const recipeQuotaTracker = new Map();

function checkAndIncrementRecipeQuota(userId) {
  const today = new Date().toISOString().split('T')[0];
  const userRecord = recipeQuotaTracker.get(userId);

  if (!userRecord || userRecord.date !== today) {
    recipeQuotaTracker.set(userId, { date: today, count: 1 });
    return { allowed: true, used: 1, remaining: DAILY_RECIPE_LIMIT - 1, limit: DAILY_RECIPE_LIMIT };
  }

  if (userRecord.count >= DAILY_RECIPE_LIMIT) {
    return { allowed: false, used: DAILY_RECIPE_LIMIT, remaining: 0, limit: DAILY_RECIPE_LIMIT };
  }

  userRecord.count += 1;
  return { allowed: true, used: userRecord.count, remaining: DAILY_RECIPE_LIMIT - userRecord.count, limit: DAILY_RECIPE_LIMIT };
}

function getRecipeQuota(userId) {
  const today = new Date().toISOString().split('T')[0];
  const userRecord = recipeQuotaTracker.get(userId);
  if (!userRecord || userRecord.date !== today) {
    return { used: 0, remaining: DAILY_RECIPE_LIMIT, limit: DAILY_RECIPE_LIMIT };
  }
  return { used: userRecord.count, remaining: Math.max(0, DAILY_RECIPE_LIMIT - userRecord.count), limit: DAILY_RECIPE_LIMIT };
}

function clearRecipeQuotaForTest() {
  recipeQuotaTracker.clear();
}

// Curated high-resolution food photo pools to ensure diverse, accurate, and non-repeating photos
const DISH_IMAGE_POOLS = {
  carrot: [
    'https://images.unsplash.com/photo-1598170845058-32b9d6a5c717?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1447175008436-054170c2e979?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1522184216316-3c25379f9760?auto=format&fit=crop&w=800&q=80',
  ],
  omelet: [
    'https://images.unsplash.com/photo-1510693206972-df098062cb71?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1494597706938-de2cd7341979?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1700324673015-52cddc228533?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1766146431872-a4472ccd3889?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=800&q=80',
  ],
  fried_rice: [
    'https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80',
  ],
  stir_fry: [
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1514944298352-78d12351be74?auto=format&fit=crop&w=800&q=80',
  ],
  soup: [
    'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1541832676-9b763b0239ab?auto=format&fit=crop&w=800&q=80',
  ],
  salad: [
    'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80',
  ],
  sausage: [
    'https://images.unsplash.com/photo-1533060328534-2db4d2602877?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1597075349414-e594898d46a9?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1691480241974-92481cef09ff?auto=format&fit=crop&w=800&q=80',
  ],
  pasta: [
    'https://images.unsplash.com/photo-1621996346565-e3d5d6281699?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=800&q=80',
  ],
  sandwich: [
    'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=800&q=80',
  ],
  pancake: [
    'https://images.unsplash.com/photo-1528207776546-365bb710ee93?auto=format&fit=crop&w=800&q=80',
  ],
  smoothie: [
    'https://images.unsplash.com/photo-1553530666-ba11a7da3888?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1610970881699-44a5587cabec?auto=format&fit=crop&w=800&q=80',
  ],
  chicken: [
    'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=800&q=80',
  ],
  default: [
    'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80',
  ],
};

const DISH_FALLBACK_ASSETS = {
  omelet: 'assets/images/food_eggs.png',
  fried_rice: 'assets/images/food_lasagna.png',
  stir_fry: 'assets/images/food_lasagna.png',
  soup: 'assets/images/food_lasagna.png',
  salad: 'assets/images/food_spinach.png',
  sausage: 'assets/images/food_nuggets.png',
  chicken: 'assets/images/food_chicken_breasts.png',
  pancake: 'assets/images/food_strawberries.png',
  smoothie: 'assets/images/food_strawberries.png',
  default: 'assets/images/food_lasagna.png',
};

// Backwards compatibility
const DISH_IMAGES = {
  fried_rice: { imageUrl: DISH_IMAGE_POOLS.fried_rice[0], assetFallback: 'assets/images/food_lasagna.png' },
  omelet: { imageUrl: DISH_IMAGE_POOLS.omelet[0], assetFallback: 'assets/images/food_eggs.png' },
  stir_fry: { imageUrl: DISH_IMAGE_POOLS.stir_fry[0], assetFallback: 'assets/images/food_lasagna.png' },
  soup: { imageUrl: DISH_IMAGE_POOLS.soup[0], assetFallback: 'assets/images/food_lasagna.png' },
  salad: { imageUrl: DISH_IMAGE_POOLS.salad[0], assetFallback: 'assets/images/food_spinach.png' },
  default: { imageUrl: DISH_IMAGE_POOLS.default[0], assetFallback: 'assets/images/food_lasagna.png' },
};

function attachRecipeImages(recipe, mainIngredient, index = 0) {
  const type = (recipe.dishType || '').toLowerCase();
  const lowerTitle = (recipe.title || '').toLowerCase();
  const lowerExp = (recipe.expiringIngredient || mainIngredient || '').toLowerCase();

  let pool = null;
  let fallbackAsset = DISH_FALLBACK_ASSETS.default;

  // 1. Prioritize dish cooking style from title or dishType so photos accurately reflect the dish name
  if (lowerTitle.includes('ไข่') || lowerTitle.includes('omelet') || lowerTitle.includes('egg') || type === 'omelet') {
    pool = DISH_IMAGE_POOLS.omelet;
    fallbackAsset = DISH_FALLBACK_ASSETS.omelet;
  } else if (lowerTitle.includes('ข้าวผัด') || lowerTitle.includes('fried rice') || type === 'fried_rice') {
    pool = DISH_IMAGE_POOLS.fried_rice;
    fallbackAsset = DISH_FALLBACK_ASSETS.fried_rice;
  } else if (lowerTitle.includes('ผัด') || lowerTitle.includes('stir') || type === 'stir_fry') {
    pool = DISH_IMAGE_POOLS.stir_fry;
    fallbackAsset = DISH_FALLBACK_ASSETS.stir_fry;
  } else if (lowerTitle.includes('ซุป') || lowerTitle.includes('soup') || lowerTitle.includes('ต้ม') || type === 'soup') {
    pool = DISH_IMAGE_POOLS.soup;
    fallbackAsset = DISH_FALLBACK_ASSETS.soup;
  } else if (lowerTitle.includes('สลัด') || lowerTitle.includes('salad') || lowerTitle.includes('ยำ') || type === 'salad') {
    pool = DISH_IMAGE_POOLS.salad;
    fallbackAsset = DISH_FALLBACK_ASSETS.salad;
  } else if (lowerTitle.includes('แซนด์วิช') || lowerTitle.includes('sandwich') || type === 'sandwich') {
    pool = DISH_IMAGE_POOLS.sandwich;
    fallbackAsset = DISH_FALLBACK_ASSETS.default;
  } else if (lowerTitle.includes('พาสต้า') || lowerTitle.includes('สปาเก็ตตี้') || lowerTitle.includes('pasta') || type === 'pasta') {
    pool = DISH_IMAGE_POOLS.pasta;
    fallbackAsset = DISH_FALLBACK_ASSETS.default;
  } else if (lowerTitle.includes('สมูทตี้') || lowerTitle.includes('smoothie') || type === 'smoothie') {
    pool = DISH_IMAGE_POOLS.smoothie;
    fallbackAsset = DISH_FALLBACK_ASSETS.smoothie;
  } else if (lowerTitle.includes('แพนเค้ก') || lowerTitle.includes('pancake') || type === 'pancake') {
    pool = DISH_IMAGE_POOLS.pancake;
    fallbackAsset = DISH_FALLBACK_ASSETS.pancake;
  } else if (lowerTitle.includes('ไส้กรอก') || lowerTitle.includes('sausage') || lowerExp.includes('ไส้กรอก') || lowerExp.includes('ค็อกเทล')) {
    pool = DISH_IMAGE_POOLS.sausage;
    fallbackAsset = DISH_FALLBACK_ASSETS.sausage;
  } else if (lowerTitle.includes('ไก่') || lowerTitle.includes('chicken') || lowerExp.includes('ไก่')) {
    pool = DISH_IMAGE_POOLS.chicken;
    fallbackAsset = DISH_FALLBACK_ASSETS.chicken;
  } else if (lowerExp.includes('แครอท') || lowerExp.includes('carrot')) {
    pool = DISH_IMAGE_POOLS.carrot;
    fallbackAsset = DISH_FALLBACK_ASSETS.default;
  } else if (DISH_IMAGE_POOLS[type]) {
    pool = DISH_IMAGE_POOLS[type];
    fallbackAsset = DISH_FALLBACK_ASSETS[type] || DISH_FALLBACK_ASSETS.default;
  } else {
    pool = DISH_IMAGE_POOLS.default;
    fallbackAsset = DISH_FALLBACK_ASSETS.default;
  }

  // Pick unique photo from pool based on index to ensure every card in the list is distinct
  const photoIndex = index % pool.length;
  const chosenUrl = pool[photoIndex];

  return {
    ...recipe,
    imageUrl: chosenUrl,
    assetFallback: fallbackAsset,
  };
}

function generateFallbackRecipes(mainIngredient, language = 'th', offset = 0) {
  const isEn = language === 'en';
  const pool = [
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
    {
      id: 'recipe_fallback_7',
      title: isEn ? `Spicy Basil Stir-fry with ${mainIngredient}` : `ผัดกะเพรารสเด็ดใส่${mainIngredient}`,
      description: isEn ? 'Fiery and aromatic Thai holy basil stir fry.' : 'เผ็ดร้อนหอมกลิ่นใบกะเพรา เมนูยอดฮิตทำง่ายสุดๆ',
      cookingTime: '10 min',
      difficulty: 'Easy',
      dishType: 'stir_fry',
      expiringIngredient: mainIngredient,
      ingredients: [
        `${mainIngredient}`,
        isEn ? 'Handful of fresh holy basil' : 'ใบกะเพรา 1 กำมือ',
        isEn ? 'Chilies and garlic' : 'พริกขี้หนูและกระเทียมสับ',
        isEn ? 'Oyster sauce and soy sauce' : 'น้ำมันหอยและซีอิ๊วขาว',
      ],
      steps: [
        isEn ? 'Pound chilies and garlic, sauté in hot oil.' : 'โขลกพริกกระเทียมลงผัดในน้ำมันจนหอมฉุน',
        isEn ? `Add ${mainIngredient} and season.` : `ใส่${mainIngredient}ลงไปผัด ปรุงรสด้วยน้ำมันหอยและซีอิ๊ว`,
        isEn ? 'Toss in holy basil and serve over rice.' : 'ใส่ใบกะเพรา ปิดไฟ ผัดเคล้าให้เข้ากัน เสิร์ฟพร้อมข้าวสวย',
      ],
    },
    {
      id: 'recipe_fallback_8',
      title: isEn ? `Creamy Lava Egg Bowl with ${mainIngredient}` : `ข้าวไข่ข้นลาวาหน้า${mainIngredient}`,
      description: isEn ? 'Silky runny scrambled eggs topping warm rice.' : 'ไข่ข้นเยิ้มๆ นุ่มละมุนลิ้น เข้ากันดีเยี่ยม',
      cookingTime: '8 min',
      difficulty: 'Very easy',
      dishType: 'omelet',
      expiringIngredient: mainIngredient,
      ingredients: [
        `${mainIngredient}`,
        isEn ? '2 eggs' : 'ไข่ไก่ 2 ฟอง',
        isEn ? '2 tbsp milk' : 'นมสด 2 ช้อนโต๊ะ',
        isEn ? 'Butter or oil' : 'เนยสดหรือน้ำมันพืช',
      ],
      steps: [
        isEn ? 'Whisk eggs with milk.' : 'ตีไข่กับนมสดและซีอิ๊วขาวเบาๆ',
        isEn ? 'Cook gently in butter until half set.' : 'ตั้งกระทะใส่เนย ใช้ไฟอ่อน เทไข่ลงไปใช้ตะหลิวดันเข้าตรงกลาง',
        isEn ? `Top with ${mainIngredient} and pour over rice.` : `วาง${mainIngredient}ลงไปด้านบน พอไข่เยิ้มๆ ตักราดข้าวทันที`,
      ],
    },
  ];

  if (offset > 0 && pool.length > 6) {
    const shift = (offset * 2) % pool.length;
    return [...pool.slice(shift), ...pool.slice(0, shift)].slice(0, 6);
  }
  return pool.slice(0, 6);
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

async function suggestRecipes({ userId, mainIngredient, language = 'th', offset = 0 }) {
  // Check daily rate limit (10 requests/day per user)
  let remainingQuota = DAILY_RECIPE_LIMIT;
  let usedQuota = 1;
  if (userId) {
    const quota = checkAndIncrementRecipeQuota(userId);
    if (!quota.allowed) {
      const error = new Error('วันนี้คุณใช้โควตาครบ 3 ครั้งแล้ว ลองเลือกเมนูที่แนะนำไปทำอาหารอร่อยๆ กันก่อนนะ! ✨');
      error.statusCode = 429;
      error.usedQuota = DAILY_RECIPE_LIMIT;
      error.remainingQuota = 0;
      throw error;
    }
    remainingQuota = quota.remaining;
    usedQuota = quota.used;
  }

  const langInstruction = language === 'en'
    ? 'All recipe titles, descriptions, ingredients, and instructions MUST be in English.'
    : 'All recipe titles, descriptions, ingredients, and instructions MUST be in natural, creative, and friendly Thai (ภาษาไทยที่น่ากิน เข้าใจง่าย เป็นกันเอง).';

  const prompt = `คุณคือสุดยอดเชฟ AI ผู้เชี่ยวชาญการคิดเมนูอาหารที่สร้างสรรค์ ทำง่าย ใช้วัตถุดิบน้อย (10-20 นาที)
วัตถุดิบที่ต้องการนำมาทำอาหาร: "${mainIngredient}"

ข้อกำหนดสำคัญมาก:
1. ทุกเมนูต้องชูและโฟกัสเฉพาะ "${mainIngredient}" เป็นวัตถุดิบหลักเท่านั้น ห้ามใส่วัตถุดิบหลักอื่นที่ไม่เกี่ยวข้อง (ห้ามผสมเนื้อสัตว์หรือผักอื่นที่ไม่ได้เลือกมา)
2. วัตถุดิบเสริมต้องเป็นเครื่องปรุงพื้นฐานประจำบ้านเท่านั้น (เช่น ไข่ไก่, ข้าวสวย, น้ำมัน, กระเทียม, ซีอิ๊ว, น้ำปลา, เกลือ, พริกไทย, น้ำตาล)
3. เมนูทั้ง 6 ต้องมีความหลากหลายของกรรมวิธี (เช่น มีผัด, ทอด/ไข่, ต้ม/ซุป, ยำ/สลัด, ข้าว/เส้น, เมนูทานเล่น) ไม่ซ้ำแนวกัน
4. เวลาปรุง 5-20 นาที ระดับความง่าย Easy หรือ Very easy
5. ${langInstruction}

ตอบกลับเป็น JSON array ของวัตถุ 6 รายการเท่านั้น ตามโครงสร้างดังนี้:
[
  {
    "id": "recipe_1",
    "title": "ชื่อเมนูที่สร้างสรรค์และน่ากิน",
    "description": "คำอธิบายความอร่อยสั้นๆ 1 ประโยค ดึงดูดให้อยากทำ",
    "cookingTime": "15 min",
    "difficulty": "Easy",
    "dishType": "stir_fry|omelet|soup|fried_rice|salad|sandwich|pasta",
    "expiringIngredient": "${mainIngredient}",
    "ingredients": ["วัตถุดิบพร้อมปริมาณ"],
    "steps": ["ขั้นตอนการทำสั้นกระชับเข้าใจง่าย"]
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
      config: { responseMimeType: 'application/json', temperature: 0.8 },
    });

    if (res.text) {
      const parsed = JSON.parse(res.text);
      if (Array.isArray(parsed) && parsed.length > 0) {
        recipes = parsed;
      }
    }
  } catch (err) {
    // If Gemini fails or API key is not configured, fall back to smart dynamic recipes
    recipes = generateFallbackRecipes(mainIngredient, language, offset);
  }

  if (recipes.length === 0) {
    recipes = generateFallbackRecipes(mainIngredient, language, offset);
  }

  // Ensure up to 6 recipes and attach unique non-repeating image assets
  const formattedRecipes = recipes.slice(0, 6).map((r, idx) => {
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
      mainIngredient,
      idx + offset
    );
  });

  return {
    recipes: formattedRecipes,
    usedDailyQuota: usedQuota,
    remainingDailyQuota: remainingQuota,
    maxDailyQuota: DAILY_RECIPE_LIMIT,
  };
}

module.exports = {
  scanLabel,
  suggestRecipes,
  checkAndIncrementRecipeQuota,
  getRecipeQuota,
  clearRecipeQuotaForTest,
  generateFallbackRecipes,
  DISH_IMAGES,
  DISH_IMAGE_POOLS,
};
