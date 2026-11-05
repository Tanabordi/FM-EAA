const { GoogleGenAI } = require('@google/genai');

const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

const THAI_TO_EN_MAP = {
  'ค็อกเทลรมควัน': 'Smoked Cocktail Sausage',
  'ไส้กรอกรมควัน': 'Smoked Sausage',
  'ไส้กรอกค็อกเทล': 'Cocktail Sausage',
  'ไส้กรอก': 'Sausage',
  'หมูสับ': 'Minced Pork',
  'หมูบด': 'Minced Pork',
  'หมูชิ้น': 'Pork Slices',
  'เนื้อหมู': 'Pork',
  'หมู': 'Pork',
  'อกไก่': 'Chicken Breast',
  'สันในไก่': 'Chicken Tenderloin',
  'เนื้อไก่': 'Chicken',
  'ไก่': 'Chicken',
  'ไข่ไก่': 'Eggs',
  'ไข่': 'Egg',
  'นมสด': 'Fresh Milk',
  'นม': 'Milk',
  'แครอท': 'Carrots',
  'มะเขือเทศ': 'Tomatoes',
  'ผักกาด': 'Cabbage',
  'กะหล่ำปลี': 'Cabbage',
  'ผักชี': 'Coriander',
  'ต้นหอม': 'Spring Onions',
  'กระเทียม': 'Garlic',
  'หัวหอม': 'Onion',
  'กุ้ง': 'Shrimp',
  'ปลา': 'Fish',
  'แซลมอน': 'Salmon',
  'เต้าหู้': 'Tofu',
  'เบคอน': 'Bacon',
  'แฮม': 'Ham',
  'ข้าวสวย': 'Cooked Rice',
  'ข้าว': 'Rice',
  'ขนมปัง': 'Bread',
  'เนย': 'Butter',
  'ชีส': 'Cheese',
  'สตรอว์เบอร์รี': 'Strawberries',
  'สตรอเบอรี่': 'Strawberries',
  'แอปเปิ้ล': 'Apples',
  'กล้วย': 'Bananas',
  'ส้ม': 'Oranges',
  'โยเกิร์ต': 'Yogurt',
  'น้ำส้ม': 'Orange Juice',
  'น้ำดื่ม': 'Drinking Water',
};

function translateThaiIngredientToEn(name) {
  if (!name || typeof name !== 'string') return name;
  const trimmed = name.trim();
  if (THAI_TO_EN_MAP[trimmed]) return THAI_TO_EN_MAP[trimmed];

  for (const [thai, en] of Object.entries(THAI_TO_EN_MAP)) {
    if (trimmed.includes(thai)) {
      return en;
    }
  }

  if (/[\u0E00-\u0E7F]/.test(trimmed)) {
    return 'Ingredient';
  }
  return trimmed;
}

const EN_TO_THAI_MAP = {
  'raw shrimp': 'กุ้งสด',
  'shrimp': 'กุ้งสด',
  'prawn': 'กุ้ง',
  'prawns': 'กุ้ง',
  'beef steak': 'สเต็กเนื้อวัว',
  'wagyu beef steak': 'สเต็กเนื้อวากิว',
  'wagyu beef': 'เนื้อวัววากิว',
  'beef': 'เนื้อวัว',
  'minced beef': 'เนื้อวัวบด',
  'pork': 'เนื้อหมู',
  'minced pork': 'หมูบด',
  'ground pork': 'หมูบด',
  'pork chops': 'พอร์คชอป',
  'pork slice': 'หมูสไลด์',
  'pork belly': 'หมูสามชั้น',
  'chicken': 'เนื้อไก่',
  'chicken breast': 'อกไก่',
  'chicken wing': 'ปีกไก่',
  'chicken wings': 'ปีกไก่',
  'chicken thigh': 'สะโพกไก่',
  'smoked sausage': 'ไส้กรอกรมควัน',
  'cocktail sausage': 'ไส้กรอกค็อกเทล',
  'smoked cocktail sausage': 'ค็อกเทลรมควัน',
  'sausage': 'ไส้กรอก',
  'sausages': 'ไส้กรอก',
  'bacon': 'เบคอน',
  'ham': 'แฮม',
  'salmon': 'แซลมอน',
  'salmon fillet': 'เนื้อปลาแซลมอน',
  'fish': 'ปลา',
  'fish fillet': 'เนื้อปลา',
  'tofu': 'เต้าหู้',
  'egg': 'ไข่ไก่',
  'eggs': 'ไข่ไก่',
  'fresh milk': 'นมสด',
  'milk': 'นมสด',
  'cheese': 'ชีส',
  'butter': 'เนย',
  'yogurt': 'โยเกิร์ต',
  'bread': 'ขนมปัง',
  'rice': 'ข้าว',
  'cooked rice': 'ข้าวสวย',
  'noodles': 'บะหมี่',
  'pasta': 'พาสต้า',
  'spaghetti': 'สปาเก็ตตี้',
  'carrot': 'แครอท',
  'carrots': 'แครอท',
  'broccoli': 'บรอกโคลี',
  'tomato': 'มะเขือเทศ',
  'tomatoes': 'มะเขือเทศ',
  'potato': 'มันฝรั่ง',
  'potatoes': 'มันฝรั่ง',
  'onion': 'หอมใหญ่',
  'onions': 'หอมใหญ่',
  'spring onion': 'ต้นหอม',
  'spring onions': 'ต้นหอม',
  'scallion': 'ต้นหอม',
  'garlic': 'กระเทียม',
  'chili': 'พริก',
  'lime': 'มะนาว',
  'lemon': 'เลมอน',
  'lettuce': 'ผักกาดหอม',
  'cabbage': 'กะหล่ำปลี',
  'spinach': 'ผักโขม',
  'mushroom': 'เห็ด',
  'mushrooms': 'เห็ด',
  'cucumber': 'แตงกวา',
  'cucumbers': 'แตงกวา',
  'bell pepper': 'พริกหวาน',
  'coriander': 'ผักชี',
  'cilantro': 'ผักชี',
  'strawberry': 'สตรอว์เบอร์รี',
  'strawberries': 'สตรอว์เบอร์รี',
  'avocado': 'อะโวคาโด',
  'avocados': 'อะโวคาโด',
  'apple': 'แอปเปิ้ล',
  'apples': 'แอปเปิ้ล',
  'banana': 'กล้วย',
  'bananas': 'กล้วย',
  'orange': 'ส้ม',
  'oranges': 'ส้ม',
  'watermelon': 'แตงโม',
  'mango': 'มะม่วง',
  'grape': 'องุ่น',
  'grapes': 'องุ่น',
  'orange juice': 'น้ำส้ม',
  'apple juice': 'น้ำแอปเปิ้ล',
  'drinking water': 'น้ำดื่ม',
  'water': 'น้ำดื่ม',
  'green tea': 'ชาเขียว',
  'coffee': 'กาแฟ',
  'spicy chili sauce': 'ซอสพริกเผ็ด',
  'chili sauce': 'ซอสพริก',
  'tomato sauce': 'ซอสมะเขือเทศ',
  'ketchup': 'ซอสมะเขือเทศ',
  'soy sauce': 'ซีอิ๊วขาว',
  'fish sauce': 'น้ำปลา',
  'oyster sauce': 'ซอสหอยนางรม',
  'mayonnaise': 'มายองเนส',
  'cooking oil': 'น้ำมันพืช',
  'vegetable oil': 'น้ำมันพืช',
  'olive oil': 'น้ำมันมะกอก',
  'honey': 'น้ำผึ้ง',
  'jam': 'แยม',
  'strawberry jam': 'แยมสตรอว์เบอร์รี',
};

function translateEnIngredientToThai(name) {
  if (!name || typeof name !== 'string') return name;
  const lower = name.toLowerCase().trim();
  if (EN_TO_THAI_MAP[lower]) return EN_TO_THAI_MAP[lower];
  for (const [en, thai] of Object.entries(EN_TO_THAI_MAP)) {
    if (lower.includes(en)) {
      return thai;
    }
  }
  return name;
}

function getScanLabelPrompt(language = 'en') {
  if (language === 'en') {
    return `Analyze the image and respond strictly in JSON matching this schema:
{
  "is_food": boolean,
  "foodName": string|null,
  "expiryDate": "YYYY-MM-DD"|null,
  "category": "Proteins"|"Veggies"|"Beverages"|"Meals"|"Sauces",
  "storage": "Fridge"|"Freezer",
  "unit": "pieces"|"bag"|"punnet"|"bottle"|"box"|"can"|"pack"|"g"|"kg",
  "confidence": number
}
Rules:
- is_food: MUST be true ONLY if the image depicts food, groceries, edible ingredients, fresh produce, snacks, beverages, or a food product packaging label. MUST be false if the image is a person's face, selfie, human body, animal, general non-food object, furniture, electronics, or scenery.
- confidence: Confidence score between 0.0 and 1.0. If the image is blurry, occluded by hand, far away, or not clear, set confidence lower than 0.6. If it is clearly not food, set 0.0.
- foodName: The clear product name or ingredient in concise natural English (e.g. "Smoked Cocktail Sausage", "Minced Pork", "Fresh Milk", "Eggs").
  CRITICAL: If is_food is false, foodName MUST be null.
  Even if the packaging, brand, or text on the label is in Thai or another non-English language (such as "ค็อกเทลรมควัน", "หมูบด", "นมสด", "ไข่ไก่"), you MUST translate it accurately and write foodName ONLY in English. Do NOT return Thai script in foodName.
- expiryDate: Expiry date ONLY (EXP, BBD, Best Before, ควรบริโภคก่อน, หมดอายุ). NEVER use manufacturing date (MFD, MFG). Convert Buddhist Era (BE/พ.ศ.) to CE (AD/ค.ศ.) in YYYY-MM-DD format (subtract 543 if year is > 2400). If not clearly found on this image (e.g. stamped on cap or bottom out of view), return null. Do NOT guess.
- category: Analyze food category:
  * "Proteins": Meat, pork, chicken, beef, fish, seafood, eggs, sausages, ham, bacon, tofu, plant-based proteins, meatballs
  * "Veggies": Fresh vegetables, leafy greens, mushrooms, fresh fruits, garlic, onions, chili, lime, fresh herbs
  * "Beverages": Milk, soy milk, water, juices, tea, coffee, soda, drinks, yogurt drinks, energy drinks
  * "Sauces": Condiments, sauces, dips, soy sauce, fish sauce, cooking oils, mayonnaise, butter, margarine, jams, honey, seasoning powders, sugar, salt
  * "Meals": Ready-to-eat meals, bento, rice dishes, noodles, soups, curries, stir-fries, pasta, pizza, sandwiches, burgers, AND ALL dry goods / baking ingredients / pantry staples (such as flour, crispy batter, tempura flour, starch, baking powder, rice grains, noodles, instant noodles/ramen, vermicelli, bread, toast, bakery, cookies, chips, snacks, cereals, biscuits), and any other edible food or ingredient not falling into the other 4 categories.
- storage: Mostly "Fridge" for all fresh items, dairy, vegetables, meat, and dry goods/groceries stored in the refrigerator, unless it is frozen food, ice cream, or specifies freezer, then "Freezer".
- unit: Appropriate packaging unit: "pack" for sausages/meats, "bottle" for drinks, "box" for meal boxes, "bag" for veggies/flour, or "pieces", "g", "kg", "can", "punnet".`;
  }

  return `อ่านฉลากหรือภาพอาหารในรูปนี้ แล้วตอบเป็น JSON เท่านั้นตามรูปแบบนี้:
{
  "is_food": boolean,
  "foodName": string|null,
  "expiryDate": "YYYY-MM-DD"|null,
  "category": "Proteins"|"Veggies"|"Beverages"|"Meals"|"Sauces",
  "storage": "Fridge"|"Freezer",
  "unit": "pieces"|"bag"|"punnet"|"bottle"|"box"|"can"|"pack"|"g"|"kg",
  "confidence": number
}
- is_food: ต้องเป็น true เฉพาะเมื่อในรูปเป็นอาหาร วัตถุดิบ ของกิน เครื่องดื่ม หรือฉลากบรรจุภัณฑ์อาหารเท่านั้น หากเป็นรูปใบหน้าคน เซลฟี่ สัตว์ สิ่งของที่ไม่ใช่อาหาร เครื่องใช้ หรือวิว ให้ตอบ false
- confidence: ค่าความมั่นใจระหว่าง 0.0 ถึง 1.0 ถ้าภาพเบลอ มีมือบัง หรือไม่ชัด ให้ระบุต่ำกว่า 0.6 หากไม่ใช่อาหารให้เป็น 0.0
- foodName: ชื่อสินค้าหรือชนิดวัตถุดิบ (ถ้า is_food เป็น false ให้ใส่ null) ห้ามเดาหากไม่ชัดเจน
- expiryDate: วันหมดอายุเท่านั้น (EXP, BBD, Best Before, ควรบริโภคก่อน, หมดอายุ) ห้ามใช้วันผลิต (MFD, MFG). แปลงเป็น ค.ศ. รูปแบบ YYYY-MM-DD หากไม่พบตัวเลขวันหมดอายุในรูปให้ใส่ null ห้ามเดา
- category: วิเคราะห์จากประเภทอาหาร (5 หมวด):
  * "Proteins": เนื้อสัตว์, หมู, ไก่, วัว, ปลา, กุ้ง, ไข่, ไส้กรอก, แฮม, เบคอน, เต้าหู้, ลูกชิ้น
  * "Veggies": ผักสด, ผลไม้สด, เห็ดทุกชนิด, พริก, กระเทียม, หอม, มะนาว
  * "Beverages": นม, น้ำดื่ม, น้ำผลไม้, ชา, กาแฟ, โซดา, เครื่องดื่ม
  * "Sauces": ซอส, เครื่องปรุงรส, น้ำจิ้ม, ซีอิ๊ว, น้ำปลา, น้ำมันพืช, มายองเนส, เนย, แยม, ผงปรุงรส, น้ำตาล, เกลือ
  * "Meals": อาหารปรุงสำเร็จ, กับข้าว, ข้าวกล่อง รวมถึงของแห้งและวัตถุดิบทั้งหมด เช่น แป้งทอดกรอบ, แป้งสาลี, ข้าวสาร, บะหมี่กึ่งสำเร็จรูป, พาสต้า, ขนมปัง, เบเกอรี่, ขนมขบเคี้ยว (Snacks) และอาหารใดๆ ที่ไม่เข้าข่าย 4 หมวดแรก
- storage: "Fridge" สำหรับของสดและของกินทั่วไปที่แช่ในตู้เย็น ยกเว้นสินค้าแช่แข็งหรือไอศกรีมให้เป็น "Freezer"
- unit: หน่วยที่เหมาะสมของบรรจุภัณฑ์ เช่น "pack", "bottle", "box", "bag", "can", "pieces"`;
}

function getExpiryOnlyPrompt(language = 'en') {
  return `Analyze this close-up photo of a food packaging (such as a bottle cap, bottom of a can, stamp seal, or expiry label) and extract the expiration date.
Respond strictly in JSON matching this schema:
{
  "expiryDate": "YYYY-MM-DD"|null,
  "confidence": number
}
Rules:
- expiryDate: Expiry date ONLY (EXP, BBD, Best Before, ควรบริโภคก่อน, หมดอายุ, EXP.DATE).
  NEVER use manufacturing date (MFD, MFG). Convert Buddhist Era (BE/พ.ศ.) to CE (AD/ค.ศ.) in YYYY-MM-DD format (subtract 543 if year is > 2400).
  If not found or unreadable, return null. Do not guess.
- confidence: Score between 0.0 and 1.0 based on legibility.`;
}

const PROMPT = getScanLabelPrompt('en');

// Daily in-memory quota tracking per user and ingredient: 3 generations per day per ingredient
const DAILY_RECIPE_LIMIT = 3;
const recipeQuotaTracker = new Map();

function checkAndIncrementRecipeQuota(userId, ingredient = '') {
  const today = new Date().toISOString().split('T')[0];
  const cleanIngredient = ingredient ? ingredient.toLowerCase().trim() : '';
  const key = cleanIngredient ? `${userId}:${cleanIngredient}` : userId;
  const userRecord = recipeQuotaTracker.get(key);

  if (!userRecord || userRecord.date !== today) {
    recipeQuotaTracker.set(key, { date: today, count: 1 });
    return { allowed: true, used: 1, remaining: DAILY_RECIPE_LIMIT - 1, limit: DAILY_RECIPE_LIMIT };
  }

  if (userRecord.count >= DAILY_RECIPE_LIMIT) {
    return { allowed: false, used: DAILY_RECIPE_LIMIT, remaining: 0, limit: DAILY_RECIPE_LIMIT };
  }

  userRecord.count += 1;
  return { allowed: true, used: userRecord.count, remaining: DAILY_RECIPE_LIMIT - userRecord.count, limit: DAILY_RECIPE_LIMIT };
}

function getRecipeQuota(userId, ingredient = '') {
  const today = new Date().toISOString().split('T')[0];
  const cleanIngredient = ingredient ? ingredient.toLowerCase().trim() : '';
  const key = cleanIngredient ? `${userId}:${cleanIngredient}` : userId;
  const userRecord = recipeQuotaTracker.get(key);
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
  beverage: [
    'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1544787219-7f47ccb76574?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=800&q=80',
  ],
  sauce: [
    'https://images.unsplash.com/photo-1472476443507-c7a5948772fc?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80',
  ],
  dessert: [
    'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1528207776546-365bb710ee93?auto=format&fit=crop&w=800&q=80',
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
  beverage: 'assets/images/food_strawberries.png',
  sauce: 'assets/images/food_lasagna.png',
  dessert: 'assets/images/food_strawberries.png',
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
  } else if (
    lowerTitle.includes('เครื่องดื่ม') ||
    lowerTitle.includes('drink') ||
    lowerTitle.includes('beverage') ||
    lowerTitle.includes('tea') ||
    lowerTitle.includes('coffee') ||
    lowerTitle.includes('latte') ||
    lowerTitle.includes('juice') ||
    lowerTitle.includes('mocktail') ||
    type === 'beverage'
  ) {
    pool = DISH_IMAGE_POOLS.beverage;
    fallbackAsset = DISH_FALLBACK_ASSETS.beverage;
  } else if (
    lowerTitle.includes('ซอส') ||
    lowerTitle.includes('sauce') ||
    lowerTitle.includes('dip') ||
    lowerTitle.includes('dressing') ||
    lowerTitle.includes('glaze') ||
    type === 'sauce'
  ) {
    pool = DISH_IMAGE_POOLS.sauce;
    fallbackAsset = DISH_FALLBACK_ASSETS.sauce;
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

function detectCategory(mainIngredient = '', explicitCategory = null) {
  if (explicitCategory && typeof explicitCategory === 'string') {
    const clean = explicitCategory.trim().toLowerCase();
    if (['proteins', 'veggies', 'beverages', 'meals', 'sauces'].includes(clean)) {
      return clean;
    }
  }

  const text = (mainIngredient || '').toLowerCase();

  // 1. Beverages
  const beverageKeywords = [
    'milk', 'coffee', 'tea', 'latte', 'juice', 'soda', 'water', 'smoothie', 'kombucha',
    'cider', 'cola', 'shake', 'lemonade', 'espresso', 'matcha', 'drink', 'beverage', 'oat milk',
    'almond milk', 'นม', 'ชา', 'กาแฟ', 'น้ำผลไม้', 'น้ำส้ม', 'น้ำเปล่า', 'โซดา', 'เครื่องดื่ม',
    'นมเปรี้ยว', 'โกโก้', 'มัทฉะ', 'น้ำอัดลม', 'โค้ก', 'ชานม', 'น้ำเต้าหู้', 'ลาเต้', 'น้ำมะนาว',
  ];
  if (beverageKeywords.some((k) => text.includes(k))) {
    return 'beverages';
  }

  // 2. Sauces & Condiments
  const sauceKeywords = [
    'sauce', 'mayo', 'mayonnaise', 'ketchup', 'mustard', 'dressing', 'dip', 'salsa',
    'chili paste', 'jam', 'spread', 'vinaigrette', 'marinade', 'pesto', 'syrup', 'gravy',
    'soy sauce', 'oyster sauce', 'fish sauce', 'ซอส', 'มายองเนส', 'มัสตาร์ด', 'น้ำสลัด',
    'น้ำจิ้ม', 'แยม', 'สเปรด', 'ซีอิ๊ว', 'น้ำปลา', 'น้ำมันหอย', 'น้ำพริก', 'ซอสมะเขือเทศ', 'ซอสพริก',
  ];
  if (sauceKeywords.some((k) => text.includes(k))) {
    return 'sauces';
  }

  // 3. Veggies & Fruits
  const veggieKeywords = [
    'veggie', 'vegetable', 'spinach', 'tomato', 'avocado', 'strawberry', 'strawberries',
    'apple', 'fruit', 'banana', 'onion', 'garlic', 'carrot', 'broccoli', 'cabbage',
    'lettuce', 'mushroom', 'cucumber', 'potato', 'lemon', 'lime', 'bell pepper', 'kale',
    'herbs', 'greens', 'berries', 'berry', 'orange', 'ผัก', 'สลัด', 'มะเขือเทศ', 'อะโวคาโด',
    'สตรอว์เบอร์รี', 'สตรอเบอรี่', 'แอปเปิ้ล', 'กล้วย', 'กะหล่ำ', 'ผักกาด',
    'แครอท', 'บรอกโคลี', 'เห็ด', 'แตงกวา', 'ผักชี', 'ต้นหอม', 'หัวหอม', 'พริก', 'มะนาว', 'ผลไม้',
  ];
  if (veggieKeywords.some((k) => text.includes(k))) {
    return 'veggies';
  }

  // 4. Meals / Staples
  const mealKeywords = [
    'noodle', 'noodles', 'pasta', 'rice', 'pizza', 'sandwich', 'bread', 'curry',
    'lasagna', 'leftover', 'meal', 'bento', 'spaghetti', 'ข้าว', 'ก๋วยเตี๋ยว', 'เส้น',
    'พาสต้า', 'ข้าวกล่อง', 'แกง', 'ขนมปัง',
  ];
  if (mealKeywords.some((k) => text.includes(k))) {
    return 'meals';
  }

  // 5. Default
  return 'proteins';
}

function generateFallbackRecipes(mainIngredient, language = 'en', offset = 0, category = null) {
  const isEn = language === 'en';
  const displayIngredient = isEn ? translateThaiIngredientToEn(mainIngredient) : translateEnIngredientToThai(mainIngredient);
  const detectedCat = detectCategory(mainIngredient, category);

  let pool = [];

  if (detectedCat === 'beverages') {
    pool = [
      {
        id: 'recipe_bev_1',
        title: isEn ? `Refreshing Iced ${displayIngredient} Splash` : `เครื่องดื่มเย็นชื่นใจสูตร${displayIngredient}`,
        description: isEn ? 'Cool, vibrant, and incredibly refreshing beverage.' : 'สดชื่น ดับกระหาย คลายร้อน ทำง่ายใน 3 นาที',
        cookingTime: '5 min',
        difficulty: 'Very easy',
        dishType: 'beverage',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? '1 cup ice cubes' : 'น้ำแข็ง 1 แก้ว',
          isEn ? '1 tbsp honey or simple syrup' : 'น้ำผึ้งหรือน้ำเชื่อม 1 ช้อนโต๊ะ',
          isEn ? 'Fresh mint or lemon slice (optional)' : 'ใบสะระแหน่หรือเลมอนฝาน (ถ้ามี)',
        ],
        steps: [
          isEn ? `Pour ${displayIngredient} into a serving glass over ice.` : `เท${displayIngredient}ลงในแก้วที่ใส่น้ำแข็งเตรียมไว้`,
          isEn ? 'Stir in honey or syrup to your desired sweetness.' : 'เติมน้ำผึ้งหรือน้ำเชื่อม คนให้เข้ากันตามความหวานที่ชอบ',
          isEn ? 'Garnish with mint leaves or citrus slice and serve chilled.' : 'ตกแต่งด้วยใบสะระแหน่หรือเลมอน พร้อมเสิร์ฟทันที',
        ],
      },
      {
        id: 'recipe_bev_2',
        title: isEn ? `Creamy ${displayIngredient} Smoothie` : `สมูทตี้เนื้อนุ่มปั่นใส่${displayIngredient}`,
        description: isEn ? 'Rich, velvety smoothie blended to perfection.' : 'เนื้อเนียนนุ่ม หอมมัน ได้คุณค่าสารอาหารเต็มๆ',
        cookingTime: '5 min',
        difficulty: 'Very easy',
        dishType: 'smoothie',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? '1/2 cup yogurt or frozen fruit' : 'โยเกิร์ตหรือผลไม้แช่แข็ง 1/2 ถ้วย',
          isEn ? '1 tbsp honey' : 'น้ำผึ้ง 1 ช้อนโต๊ะ',
          isEn ? '1/2 cup crushed ice' : 'น้ำแข็งบด 1/2 ถ้วย',
        ],
        steps: [
          isEn ? `Combine ${displayIngredient}, yogurt, and ice in a blender.` : `ใส่${displayIngredient} โยเกิร์ต และน้ำแข็งลงในโถปั่น`,
          isEn ? 'Blend on high until silky smooth and creamy.' : 'ปั่นด้วยความเร็วสูงจนเนื้อเนียนละเอียดเข้ากันดี',
          isEn ? 'Pour into a tall glass and enjoy immediately.' : 'เทใส่แก้วทรงสูง พร้อมดื่มเพื่อความสดชื่น',
        ],
      },
      {
        id: 'recipe_bev_3',
        title: isEn ? `Golden Fluffy Pancakes with ${displayIngredient}` : `แพนเค้กนุ่มฟูทำจาก${displayIngredient}`,
        description: isEn ? 'Light, airy breakfast pancakes infused with rich flavor.' : 'แพนเค้กเนื้อนุ่มฟู หอมละมุน เหมาะกับมื้อเช้า',
        cookingTime: '15 min',
        difficulty: 'Easy',
        dishType: 'pancake',
        expiringIngredient: displayIngredient,
        ingredients: [
          isEn ? `1/2 cup ${displayIngredient}` : `${displayIngredient} 1/2 ถ้วย`,
          isEn ? '1 cup all-purpose flour' : 'แป้งสาลีอเนกประสงค์ 1 ถ้วย',
          isEn ? '1 large egg' : 'ไข่ไก่ 1 ฟอง',
          isEn ? '1 tbsp melted butter or oil' : 'เนยละลาย 1 ช้อนโต๊ะ',
          isEn ? '1 tsp baking powder and maple syrup' : 'ผงฟู 1 ช้อนชา และน้ำเชื่อมตามชอบ',
        ],
        steps: [
          isEn ? `Whisk egg, melted butter, and ${displayIngredient} together.` : `ตีไข่ เนยละลาย และ${displayIngredient}เข้าด้วยกัน`,
          isEn ? 'Gently fold in flour and baking powder until just combined.' : 'ร่อนแป้งและผงฟูลงไป ตะล่อมเบาๆ ให้เข้ากัน',
          isEn ? 'Pour batter onto a buttered griddle and cook both sides until golden.' : 'หยอดแป้งลงบนกระทะทาเนย พลิกกลับด้านจนสุกเหลืองทองทั้งสองด้าน',
        ],
      },
      {
        id: 'recipe_bev_4',
        title: isEn ? `Silky Chia Seed Pudding with ${displayIngredient}` : `พุดดิ้งเมล็ดเจียเนื้อละมุนผสม${displayIngredient}`,
        description: isEn ? 'Healthy zero-waste breakfast or dessert bowl.' : 'อาหารเช้าหรือของหวานคลีนๆ อิ่มท้องนาน ดีต่อสุขภาพ',
        cookingTime: '5 min',
        difficulty: 'Very easy',
        dishType: 'dessert',
        expiringIngredient: displayIngredient,
        ingredients: [
          isEn ? `1 cup ${displayIngredient}` : `${displayIngredient} 1 ถ้วย`,
          isEn ? '3 tbsp chia seeds' : 'เมล็ดเจีย 3 ช้อนโต๊ะ',
          isEn ? '1 tsp vanilla extract or honey' : 'น้ำผึ้งหรือวานิลลา 1 ช้อนชา',
          isEn ? 'Fresh fruit or nuts for topping' : 'ผลไม้สดหรือถั่วสำหรับโรยหน้า',
        ],
        steps: [
          isEn ? `Whisk ${displayIngredient}, chia seeds, and honey in a jar.` : `คน${displayIngredient} เมล็ดเจีย และน้ำผึ้งให้เข้ากันในขวดโหล`,
          isEn ? 'Let rest for 15 minutes (or chill overnight) until thickened.' : 'ทิ้งไว้ 15 นาที หรือแช่ตู้เย็นไว้จนเมล็ดเจียพองตัวเป็นเนื้อพุดดิ้ง',
          isEn ? 'Top with fresh fruit and enjoy cold.' : 'โรยหน้าด้วยผลไม้สดหรือถั่วตามชอบ พร้อมตักทาน',
        ],
      },
      {
        id: 'recipe_bev_5',
        title: isEn ? `Golden French Toast Soaked in ${displayIngredient}` : `เฟรนช์โทสต์หอมเนยชุบ${displayIngredient}`,
        description: isEn ? 'Custardy inside, golden-crisp outside breakfast classic.' : 'นุ่มชุ่มฉ่ำด้านใน หอมกรอบด้านนอก ทำง่ายสุดๆ',
        cookingTime: '10 min',
        difficulty: 'Very easy',
        dishType: 'sandwich',
        expiringIngredient: displayIngredient,
        ingredients: [
          isEn ? `1/3 cup ${displayIngredient}` : `${displayIngredient} 1/3 ถ้วย`,
          isEn ? '2 thick bread slices' : 'ขนมปังแผ่นหนา 2 แผ่น',
          isEn ? '1 large egg' : 'ไข่ไก่ 1 ฟอง',
          isEn ? '1 tbsp butter for pan' : 'เนยสดสำหรับทอด 1 ช้อนโต๊ะ',
        ],
        steps: [
          isEn ? `Beat egg with ${displayIngredient} in a shallow dish.` : `ตอกไข่ตีผสมกับ${displayIngredient}ในจานก้นลึก`,
          isEn ? 'Dip bread slices, coating both sides evenly.' : 'นำขนมปังลงชุบให้ชุ่มทั้งสองด้าน',
          isEn ? 'Pan-fry in melted butter over medium heat until golden brown.' : 'ทอดในกระทะใส่เนยด้วยไฟกลางจนเหลืองทองสวยทั้งสองด้าน',
        ],
      },
      {
        id: 'recipe_bev_6',
        title: isEn ? `Warm Spiced ${displayIngredient} Latte` : `เครื่องดื่มลาเต้อุ่นละมุนใส่${displayIngredient}`,
        description: isEn ? 'Soothing, aromatic warm drink for any cozy moment.' : 'หอมกรุ่น อุ่นท้อง สบายใจ ดื่มก่อนนอนหรือช่วงพักผ่อน',
        cookingTime: '5 min',
        difficulty: 'Very easy',
        dishType: 'beverage',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? 'Pinch of cinnamon or cocoa powder' : 'ผงอบเชยหรือผงโกโก้เล็กน้อย',
          isEn ? '1 tsp brown sugar or honey' : 'น้ำตาลทรายแดงหรือน้ำผึ้ง 1 ช้อนชา',
        ],
        steps: [
          isEn ? `Warm ${displayIngredient} gently in a small pot over low heat.` : `นำ${displayIngredient}ตั้งไฟอ่อนในหม้อใบเล็กพออุ่น`,
          isEn ? 'Whisk briskly to create a delicate foam top.' : 'ใช้ที่ตีฟองนมหรือตะกร้อมือตีจนขึ้นฟองนุ่ม',
          isEn ? 'Pour into your favorite mug and dust with cinnamon.' : 'เทใส่แก้วโปรด โรยผงอบเชยหรือโกโก้พร้อมดื่ม',
        ],
      },
      {
        id: 'recipe_bev_7',
        title: isEn ? `Sparkling Citrus Splash with ${displayIngredient}` : `ม็อกเทลสดชื่นซาบซ่าใส่${displayIngredient}`,
        description: isEn ? 'Fizzy, thirst-quenching drink with lively bubbles.' : 'ซ่าสดชื่น ดับร้อน ปลุกความกระปรี้กระเปร่า',
        cookingTime: '3 min',
        difficulty: 'Very easy',
        dishType: 'beverage',
        expiringIngredient: displayIngredient,
        ingredients: [
          isEn ? `1/2 cup ${displayIngredient}` : `${displayIngredient} 1/2 ถ้วย`,
          isEn ? '1/2 cup sparkling soda water' : 'โซดา 1/2 ถ้วย',
          isEn ? 'Ice cubes and lime wedge' : 'น้ำแข็งและมะนาวหั่นเสี้ยว',
        ],
        steps: [
          isEn ? 'Fill a tall glass with fresh ice.' : 'ใส่น้ำแข็งเต็มแก้ว',
          isEn ? `Pour ${displayIngredient} followed by chilled soda water.` : `เท${displayIngredient}ตามด้วยโซดาแช่เย็นเจี๊ยบ`,
          isEn ? 'Stir gently once and serve immediately.' : 'คนเบาๆ ให้เข้ากัน ดื่มด่ำความสดชื่นทันที',
        ],
      },
      {
        id: 'recipe_bev_8',
        title: isEn ? `Overnight Rolled Oats with ${displayIngredient}` : `ข้าวโอ๊ตข้ามคืนผสม${displayIngredient}`,
        description: isEn ? 'Grab-and-go nutrient-rich breakfast jar.' : 'มื้อเช้าสะดวกพร้อมทาน อุดมไฟเบอร์ อิ่มท้องสบายๆ',
        cookingTime: '5 min',
        difficulty: 'Very easy',
        dishType: 'dessert',
        expiringIngredient: displayIngredient,
        ingredients: [
          isEn ? `3/4 cup ${displayIngredient}` : `${displayIngredient} 3/4 ถ้วย`,
          isEn ? '1/2 cup rolled oats' : 'ข้าวโอ๊ต 1/2 ถ้วย',
          isEn ? '1 tbsp honey or maple syrup' : 'น้ำผึ้ง 1 ช้อนโต๊ะ',
        ],
        steps: [
          isEn ? `Combine oats and ${displayIngredient} in a mason jar.` : `เทข้าวโอ๊ตผสมกับ${displayIngredient}ในขวดโหล`,
          isEn ? 'Stir in honey, seal lid, and refrigerate overnight.' : 'คนผสมน้ำผึ้ง ปิดฝา แช่ตู้เย็นทิ้งไว้ข้ามคืน',
          isEn ? 'Open and enjoy directly with spoon next morning.' : 'เปิดฝาพร้อมตักทานได้ทันทีในเช้าวันใหม่',
        ],
      },
    ];
  } else if (detectedCat === 'sauces') {
    pool = [
      {
        id: 'recipe_sauce_1',
        title: isEn ? `Golden Glazed Pan-Sear with ${displayIngredient}` : `เมนูย่างเกลซเคลือบซอส${displayIngredient}`,
        description: isEn ? 'Rich, caramelized glaze coated beautifully over protein or veggies.' : 'เคลือบซอสเข้มข้นจนขึ้นเงา หอมอร่อยกลมกล่อม',
        cookingTime: '12 min',
        difficulty: 'Easy',
        dishType: 'stir_fry',
        expiringIngredient: displayIngredient,
        ingredients: [
          isEn ? `2 tbsp ${displayIngredient}` : `${displayIngredient} 2 ช้อนโต๊ะ`,
          isEn ? 'Tofu, eggs, or protein of choice' : 'เต้าหู้ ไข่ไก่ หรือเนื้อสัตว์ตามชอบ',
          isEn ? '1 tbsp cooking oil or butter' : 'น้ำมันพืชหรือเนย 1 ช้อนโต๊ะ',
          isEn ? '1 clove garlic, minced' : 'กระเทียมสับ 1 กลีบ',
        ],
        steps: [
          isEn ? 'Sear your choice of protein or tofu in a pan until golden.' : 'นำเต้าหู้หรือเนื้อสัตว์ลงจี่ในกระทะจนเหลืองสวย',
          isEn ? `Spoon in ${displayIngredient} and garlic, tossing to coat evenly.` : `ใส่กระเทียมและตัก${displayIngredient}ลงไป คลุกเคล้าให้เคลือบทั่ว`,
          isEn ? 'Simmer for 1-2 minutes until glossy and fragrant, then serve.' : 'เคี่ยวต่อ 1-2 นาทีจนซอสเคลือบเงาหอม เสิร์ฟพร้อมข้าวสวย',
        ],
      },
      {
        id: 'recipe_sauce_2',
        title: isEn ? `Quick Tossed Garlic Pasta with ${displayIngredient}` : `พาสต้าคลุกซอส${displayIngredient}`,
        description: isEn ? 'Al dente pasta tossed lightly with seasoned sauce.' : 'เส้นพาสต้าเหนียวนุ่มคลุกเคล้าซอสรสเด็ด ทำง่ายในพริบตา',
        cookingTime: '15 min',
        difficulty: 'Easy',
        dishType: 'pasta',
        expiringIngredient: displayIngredient,
        ingredients: [
          isEn ? `3 tbsp ${displayIngredient}` : `${displayIngredient} 3 ช้อนโต๊ะ`,
          isEn ? '150g pasta (spaghetti or penne)' : 'เส้นสปาเก็ตตี้หรือมักกะโรนี 150 กรัม',
          isEn ? '1 tbsp olive oil' : 'น้ำมันมะกอก 1 ช้อนโต๊ะ',
          isEn ? 'Parmesan or black pepper to finish' : 'พริกไทยดำหรือชีสโรยหน้า',
        ],
        steps: [
          isEn ? 'Boil pasta in salted water until al dente, drain.' : 'ต้มเส้นพาสต้าในน้ำเดือดใส่เกลือจนสุกพอดี ตักสะเด็ดน้ำ',
          isEn ? `Warm ${displayIngredient} in pan with olive oil.` : `อุ่น${displayIngredient}ในกระทะกับน้ำมันมะกอกด้วยไฟอ่อน`,
          isEn ? 'Toss pasta into sauce until every strand is coated.' : 'นำเส้นลงคลุกเคล้าในกระทะจนซอสเคลือบเส้นทั่ว ตักใส่จาน',
        ],
      },
      {
        id: 'recipe_sauce_3',
        title: isEn ? `Crisp Garden Salad with ${displayIngredient} Dressing` : `สลัดผักกรอบราดน้ำสลัด${displayIngredient}`,
        description: isEn ? 'Vibrant fresh greens elevated with delicious sauce.' : 'ผักกรอบสดชื่น เข้ากันดีเยี่ยมกับซอสรสกลมกล่อม',
        cookingTime: '8 min',
        difficulty: 'Very easy',
        dishType: 'salad',
        expiringIngredient: displayIngredient,
        ingredients: [
          isEn ? `2 tbsp ${displayIngredient}` : `${displayIngredient} 2 ช้อนโต๊ะ`,
          isEn ? 'Assorted salad greens, tomatoes, cucumber' : 'ผักสลัดรวม มะเขือเทศ หรือแตงกวา',
          isEn ? '1 tsp olive oil or lemon juice' : 'น้ำมันมะกอกหรือน้ำมะนาว 1 ช้อนชา',
        ],
        steps: [
          isEn ? 'Rinse and chop fresh salad vegetables.' : 'ล้างผักสดให้สะอาด หั่นชิ้นพอดีคำจัดใส่ชาม',
          isEn ? `Whisk ${displayIngredient} with olive oil or splash of lemon.` : `ผสม${displayIngredient}กับน้ำมันมะกอกหรือมะนาวเล็กน้อย`,
          isEn ? 'Drizzle dressing over greens and toss gently before eating.' : 'ราดลงบนผักสลัด คลุกเคล้าเบาๆ พร้อมรับประทาน',
        ],
      },
      {
        id: 'recipe_sauce_4',
        title: isEn ? `Cheesy Melt Toast with ${displayIngredient} Spread` : `โทสต์อบชีสทา${displayIngredient}`,
        description: isEn ? 'Toasty bread with savory sauce and melted cheese.' : 'ขนมปังปิ้งกรอบนอกนุ่มใน ทาซอสเข้มข้นอบชีสเยิ้มๆ',
        cookingTime: '8 min',
        difficulty: 'Very easy',
        dishType: 'sandwich',
        expiringIngredient: displayIngredient,
        ingredients: [
          isEn ? `1-2 tbsp ${displayIngredient}` : `${displayIngredient} 1-2 ช้อนโต๊ะ`,
          isEn ? '2 slices bread' : 'ขนมปัง 2 แผ่น',
          isEn ? '1 slice cheese or shredded cheese' : 'ชีส 1 แผ่น',
          isEn ? 'Butter for crust' : 'เนยสดเล็กน้อย',
        ],
        steps: [
          isEn ? `Spread ${displayIngredient} generously onto bread slices.` : `ทา${displayIngredient}ให้ทั่วแผ่นขนมปัง`,
          isEn ? 'Top with cheese and place in toaster oven or pan.' : 'วางชีสลงไป นำเข้าเตาอบหรือจี่ในกระทะทาเนย',
          isEn ? 'Heat until cheese is bubbly and melted, serve warm.' : 'อบจนชีสละลายเยิ้มและขนมปังกรอบเหลืองทอง',
        ],
      },
      {
        id: 'recipe_sauce_5',
        title: isEn ? `Savory Rice Bowl with ${displayIngredient} Drizzle` : `ข้าวหน้าไข่ราดซอส${displayIngredient}`,
        description: isEn ? 'Comforting warm rice bowl topped with tasty sauce.' : 'ข้าวสวยร้อนๆ ท็อปไข่ดาวหรือไข่ข้น ราดซอสฉ่ำๆ',
        cookingTime: '10 min',
        difficulty: 'Very easy',
        dishType: 'fried_rice',
        expiringIngredient: displayIngredient,
        ingredients: [
          isEn ? `2 tbsp ${displayIngredient}` : `${displayIngredient} 2 ช้อนโต๊ะ`,
          isEn ? '1 bowl warm jasmine rice' : 'ข้าวสวยร้อนๆ 1 ถ้วย',
          isEn ? '1 fried or soft boiled egg' : 'ไข่ดาวหรือไข่ต้มยางมะตูม 1 ฟอง',
          isEn ? 'Chopped spring onions or sesame seeds' : 'ต้นหอมซอยหรืองาขาวโรยหน้า',
        ],
        steps: [
          isEn ? 'Scoop warm rice into a serving bowl and top with egg.' : 'ตักข้าวสวยใส่ชาม วางไข่ดาวลงด้านบน',
          isEn ? `Drizzle ${displayIngredient} over the hot egg and rice.` : `ราด${displayIngredient}ลงบนไข่และข้าวขณะร้อนๆ`,
          isEn ? 'Garnish with spring onions or sesame seeds and enjoy.' : 'โรยต้นหอมซอย พร้อมคลุกเคล้าความอร่อย',
        ],
      },
      {
        id: 'recipe_sauce_6',
        title: isEn ? `Crispy Finger Food with Zesty ${displayIngredient} Dip` : `ชุดของว่างพร้อมดิปซอส${displayIngredient}`,
        description: isEn ? 'Crisp bites paired with an irresistible dipping sauce.' : 'ของทานเล่นกรอบๆ จิ้มซอสรสกลมกล่อม เพลินสุดๆ',
        cookingTime: '10 min',
        difficulty: 'Very easy',
        dishType: 'snack',
        expiringIngredient: displayIngredient,
        ingredients: [
          isEn ? `3 tbsp ${displayIngredient}` : `${displayIngredient} 3 ช้อนโต๊ะ`,
          isEn ? 'Crackers, potato wedges, nuggets, or celery sticks' : 'มันฝรั่งทอด นักเก็ต หรือผักแท่งตามชอบ',
          isEn ? 'Squeeze of lime or herbs (optional)' : 'มะนาวหรือผักชีซอยเล็กน้อย',
        ],
        steps: [
          isEn ? `Transfer ${displayIngredient} into a small dipping bowl.` : `ตัก${displayIngredient}ใส่ถ้วยน้ำจิ้มใบเล็ก`,
          isEn ? 'Add a touch of fresh pepper or lime juice if desired.' : 'ปรุงแต่งด้วยพริกไทยหรือมะนาวเพิ่มมิติรสชาติ',
          isEn ? 'Arrange your favorite crispy finger foods around and dip away.' : 'จัดวางของทานเล่นรอบจาน จิ้มทานได้ทันที',
        ],
      },
      {
        id: 'recipe_sauce_7',
        title: isEn ? `Golden Omelet Filled with ${displayIngredient}` : `ไข่เจียวสอดไส้ซอส${displayIngredient}`,
        description: isEn ? 'Fluffy egg pocket bursting with rich sauce inside.' : 'ไข่เจียวนุ่มๆ สอดไส้ซอสรสเด็ด กัดตรงไหนก็ฟิน',
        cookingTime: '8 min',
        difficulty: 'Very easy',
        dishType: 'omelet',
        expiringIngredient: displayIngredient,
        ingredients: [
          isEn ? `2 tbsp ${displayIngredient}` : `${displayIngredient} 2 ช้อนโต๊ะ`,
          isEn ? '2 large eggs' : 'ไข่ไก่ 2 ฟอง',
          isEn ? '1 tbsp cooking oil or butter' : 'น้ำมันพืชหรือเนย 1 ช้อนโต๊ะ',
        ],
        steps: [
          isEn ? 'Beat eggs lightly and pour into hot buttered pan.' : 'ตีไข่พอแตก เทลงในกระทะทาเนยร้อนปานกลาง',
          isEn ? `When bottom is set, spoon ${displayIngredient} onto one half.` : `พอไข่เริ่มเซ็ตตัว ตัก${displayIngredient}ใส่ลงบนไข่ครึ่งหนึ่ง`,
          isEn ? 'Fold egg over and slide onto a warm plate.' : 'พับครึ่งไข่ ตักเสิร์ฟพร้อมข้าวสวยร้อนๆ',
        ],
      },
      {
        id: 'recipe_sauce_8',
        title: isEn ? `Tangy Sautéed Skillet with ${displayIngredient}` : `ผัดซอสกระทะร้อนใส่${displayIngredient}`,
        description: isEn ? 'Quick sizzling skillet dish coated in savory sauce.' : 'ผัดเร็วๆ ด้วยไฟแรง ซอสเคลือบหอมติดกระทะ',
        cookingTime: '10 min',
        difficulty: 'Easy',
        dishType: 'stir_fry',
        expiringIngredient: displayIngredient,
        ingredients: [
          isEn ? `2-3 tbsp ${displayIngredient}` : `${displayIngredient} 2-3 ช้อนโต๊ะ`,
          isEn ? 'Any chopped vegetable or protein leftovers' : 'ผักหรือเนื้อสัตว์ที่มีในตู้เย็น',
          isEn ? '1 tbsp cooking oil' : 'น้ำมันพืช 1 ช้อนโต๊ะ',
        ],
        steps: [
          isEn ? 'Heat oil in wok or skillet over high heat.' : 'ตั้งกระทะใส่น้ำมันใช้ไฟแรง',
          isEn ? 'Sauté ingredients for 3 minutes until tender-crisp.' : 'ใส่ของในตู้เย็นลงผัดประมาณ 3 นาทีจนสุก',
          isEn ? `Stir in ${displayIngredient} rapidly to glaze before turning off heat.` : `ใส่${displayIngredient}ลงไป ผัดเคล้าเร็วๆ จนซอสเคลือบทั่ว ปิดไฟเสิร์ฟ`,
        ],
      },
    ];
  } else if (detectedCat === 'veggies') {
    pool = [
      {
        id: 'recipe_veg_1',
        title: isEn ? `Garlic Sautéed ${displayIngredient}` : `ผัดกระเทียม${displayIngredient}`,
        description: isEn ? 'Quick, aromatic vegetable stir-fry with garlic.' : 'ผัดผักหอมกลิ่นกระเทียม ผักหวานกรอบกำลังดี',
        cookingTime: '8 min',
        difficulty: 'Very easy',
        dishType: 'stir_fry',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? '3 cloves crushed garlic' : 'กระเทียมสับ 3 กลีบ',
          isEn ? '1 tbsp light soy sauce or oyster sauce' : 'ซีอิ๊วขาวหรือน้ำมันหอย 1 ช้อนโต๊ะ',
          isEn ? '1 tbsp cooking oil' : 'น้ำมันพืช 1 ช้อนโต๊ะ',
        ],
        steps: [
          isEn ? 'Heat oil in pan, sauté crushed garlic until fragrant.' : 'ตั้งกระทะใส่น้ำมัน เจียวกระเทียมจนหอมฉุน',
          isEn ? `Add ${displayIngredient} and stir-fry over high heat for 3-4 minutes.` : `ใส่${displayIngredient}ลงไป ผัดไฟแรง 3-4 นาทีจนสุกกรอบ`,
          isEn ? 'Season with soy sauce, toss once, and serve warm.' : 'ปรุงรสด้วยซีอิ๊วขาว ตักเสิร์ฟพร้อมข้าวสวยร้อนๆ',
        ],
      },
      {
        id: 'recipe_veg_2',
        title: isEn ? `Fresh Vibrant Salad with ${displayIngredient}` : `สลัดสดชื่นใส่${displayIngredient}`,
        description: isEn ? 'Crisp, refreshing, nutrient-packed raw salad bowl.' : 'รสชาติสดชื่น กรุบกรอบ อุดมวิตามิน อิ่มเบาสบายท้อง',
        cookingTime: '5 min',
        difficulty: 'Very easy',
        dishType: 'salad',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? 'Assorted salad greens or tomatoes' : 'ผักสลัดรวมหรือมะเขือเทศ',
          isEn ? '1 tbsp olive oil' : 'น้ำมันมะกอก 1 ช้อนโต๊ะ',
          isEn ? '1 tbsp lemon or lime juice' : 'น้ำมะนาว 1 ช้อนโต๊ะ',
        ],
        steps: [
          isEn ? `Wash and slice ${displayIngredient} cleanly.` : `ล้างและหั่น${displayIngredient}เป็นชิ้นพอดีคำ`,
          isEn ? 'Combine greens in a bowl and arrange ingredients nicely.' : 'จัดผักสดใส่ชาม วาง${displayIngredient}ลงไป',
          isEn ? 'Drizzle olive oil and lemon juice, toss lightly before serving.' : 'ราดน้ำมันมะกอกและน้ำมะนาว คลุกเคล้าเบาๆ พร้อมเสิร์ฟ',
        ],
      },
      {
        id: 'recipe_veg_3',
        title: isEn ? `Comforting Vegetable Soup with ${displayIngredient}` : `ต้มจืดซุปร้อนๆ ใส่${displayIngredient}`,
        description: isEn ? 'Soothing clear broth infused with fresh vegetable sweetness.' : 'น้ำซุปใสกลมกล่อม ซดคล่องคอ หวานธรรมชาติ',
        cookingTime: '15 min',
        difficulty: 'Easy',
        dishType: 'soup',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? '2 cups vegetable or chicken stock' : 'น้ำเปล่าหรือน้ำซุป 2 ถ้วย',
          isEn ? '1 tbsp light soy sauce' : 'ซีอิ๊วขาว 1 ช้อนโต๊ะ',
          isEn ? 'Coriander or pepper to garnish' : 'ผักชีหรือพริกไทยป่นโรยหน้า',
        ],
        steps: [
          isEn ? 'Bring broth to a gentle simmer in a pot.' : 'ตั้งน้ำซุปให้เดือดปุดๆ ในหม้อ',
          isEn ? `Add ${displayIngredient} and simmer for 5-8 minutes until tender.` : `ใส่${displayIngredient}ลงไปต้มประมาณ 5-8 นาทีจนสุกนุ่ม`,
          isEn ? 'Season with light soy sauce and garnish before serving.' : 'ปรุงรสด้วยซีอิ๊วขาว โรยผักชีหรือพริกไทย เสิร์ฟอุ่นๆ',
        ],
      },
      {
        id: 'recipe_veg_4',
        title: isEn ? `Silky Scrambled Eggs with ${displayIngredient}` : `ไข่ข้นนุ่มใส่${displayIngredient}`,
        description: isEn ? 'Creamy, soft curd eggs folded with tender greens.' : 'ไข่ข้นเยิ้มๆ หอมนุ่มละมุนลิ้น ทานคู่กับผักอร่อยลงตัว',
        cookingTime: '8 min',
        difficulty: 'Very easy',
        dishType: 'omelet',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? '2 large eggs' : 'ไข่ไก่ 2 ฟอง',
          isEn ? '1 tbsp butter or oil' : 'เนยหรือน้ำมัน 1 ช้อนโต๊ะ',
          isEn ? 'Pinch of salt and pepper' : 'เกลือและพริกไทยเล็กน้อย',
        ],
        steps: [
          isEn ? `Lightly sauté ${displayIngredient} in butter until tender.` : `ผัด${displayIngredient}ในกระทะทาเนยพอสุกนุ่ม`,
          isEn ? 'Beat eggs with pinch of salt and pour into pan.' : 'ตีไข่กับเกลือเบาๆ แล้วเทลงกระทะ',
          isEn ? 'Gently scramble over low heat until custardy and soft.' : 'ใช้ไฟอ่อนคนไข่เบาๆ พอเป็นครีมเยิ้ม ตักขึ้นเสิร์ฟทันที',
        ],
      },
      {
        id: 'recipe_veg_5',
        title: isEn ? `Crispy Tempura Fritters with ${displayIngredient}` : `ผักชุบทอดกรอบใส่${displayIngredient}`,
        description: isEn ? 'Golden, airy, and crunchy zero-waste snack.' : 'กรอบนอกนุ่มใน เคี้ยวเพลิน จิ้มน้ำจิ้มอร่อยมาก',
        cookingTime: '12 min',
        difficulty: 'Easy',
        dishType: 'snack',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? '1/2 cup flour or tempura batter' : 'แป้งทอดกรอบ 1/2 ถ้วย',
          isEn ? '1/3 cup cold water' : 'น้ำเย็นจัด 1/3 ถ้วย',
          isEn ? 'Oil for frying' : 'น้ำมันสำหรับทอด',
        ],
        steps: [
          isEn ? 'Whisk flour and cold water into a light batter.' : 'ผสมแป้งทอดกรอบกับน้ำเย็นจัดให้เข้ากัน',
          isEn ? `Dip ${displayIngredient} slices into batter.` : `นำ${displayIngredient}ลงชุบแป้งบางๆ`,
          isEn ? 'Deep-fry in hot oil until golden crisp, drain on paper towel.' : 'ทอดในน้ำมันร้อนจนเหลืองกรอบ ตักขึ้นสะเด็ดน้ำมัน',
        ],
      },
      {
        id: 'recipe_veg_6',
        title: isEn ? `Warm Grain Bowl with ${displayIngredient}` : `ข้าวหน้าผักอบ${displayIngredient}`,
        description: isEn ? 'Nourishing bowl topped with roasted or sautéed veggies.' : 'ชามสุขภาพอิ่มนาน ได้พลังงานดีต่อร่างกาย',
        cookingTime: '12 min',
        difficulty: 'Easy',
        dishType: 'fried_rice',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? '1 cup cooked rice or quinoa' : 'ข้าวสวยหรือควินัว 1 ถ้วย',
          isEn ? '1 tbsp olive oil or soy sauce' : 'น้ำมันมะกอกหรือซีอิ๊วขาว 1 ช้อนโต๊ะ',
          isEn ? 'Toasted sesame seeds' : 'งาขาวคั่วโรยหน้า',
        ],
        steps: [
          isEn ? `Warm or pan-roast ${displayIngredient} with olive oil.` : `นำ${displayIngredient}ลงจี่ในกระทะด้วยน้ำมันมะกอกจนสุกหอม`,
          isEn ? 'Spoon warm rice into bowl and arrange ingredients over top.' : 'ตักข้าวใส่ชาม จัดเรียง${displayIngredient}ลงด้านบน',
          isEn ? 'Drizzle with soy sauce and sprinkle toasted sesame seeds.' : 'เหยาะซีอิ๊วขาวเล็กน้อย โรยงาคั่ว พร้อมทาน',
        ],
      },
      {
        id: 'recipe_veg_7',
        title: isEn ? `Cheesy Baked ${displayIngredient} Gratin` : `ผักอบชีสยืดๆ ใส่${displayIngredient}`,
        description: isEn ? 'Warm, bubbly, and melted cheese baked over vegetables.' : 'อบร้อนชีสยืด หอมมัน อร่อยเด็กทานได้ผู้ใหญ่ทานดี',
        cookingTime: '15 min',
        difficulty: 'Easy',
        dishType: 'pasta',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? '1/2 cup shredded mozzarella or cheddar cheese' : 'มอสซาเรลล่าชีส 1/2 ถ้วย',
          isEn ? '1 tbsp butter or cream' : 'เนยหรือนมสด 1 ช้อนโต๊ะ',
        ],
        steps: [
          isEn ? `Place chopped ${displayIngredient} in a small oven-safe dish.` : `ใส่${displayIngredient}ลงในถ้วยทนความร้อน คลุกเนยเล็กน้อย`,
          isEn ? 'Cover generously with shredded cheese.' : 'โรยชีสลงไปด้านบนให้ทั่ว',
          isEn ? 'Bake or toast until cheese is golden and melted.' : 'นำเข้าเตาอบหรือหม้อทอดไร้น้ำมันจนชีสละลายเยิ้มสีสวย',
        ],
      },
      {
        id: 'recipe_veg_8',
        title: isEn ? `Refreshing Green Smoothie with ${displayIngredient}` : `สมูทตี้ปั่นสดใส่${displayIngredient}`,
        description: isEn ? 'Revitalizing healthy blended smoothie packed with vitamins.' : 'ปั่นสด หอมสดชื่น เพิ่มความกระปรี้กระเปร่า',
        cookingTime: '5 min',
        difficulty: 'Very easy',
        dishType: 'smoothie',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? '1 cup water, milk, or coconut water' : 'น้ำเปล่า นม หรือน้ำมะพร้าว 1 ถ้วย',
          isEn ? '1 banana or apple (optional)' : 'กล้วยหอมหรือแอปเปิ้ล 1 ลูก',
          isEn ? '1 tbsp honey or lime' : 'น้ำผึ้งหรือน้ำมะนาว 1 ช้อนโต๊ะ',
        ],
        steps: [
          isEn ? `Chop ${displayIngredient} and place in blender.` : `หั่น${displayIngredient}ใส่ลงในโถปั่น`,
          isEn ? 'Add liquid, fruit, and honey.' : 'เติมนมหรือน้ำ และน้ำผึ้งลงไป',
          isEn ? 'Blend on high speed until completely smooth, serve cold.' : 'ปั่นจนเนื้อเนียนละเอียด เทใส่แก้วพร้อมดื่ม',
        ],
      },
    ];
  } else if (detectedCat === 'meals') {
    pool = [
      {
        id: 'recipe_meal_1',
        title: isEn ? `Crispy Pan-fried ${displayIngredient} Hash` : `แฮชกระทะร้อนชุบชีวิต${displayIngredient}`,
        description: isEn ? 'Turn leftover meal into a crispy, sizzling hash.' : 'นำอาหารสำเร็จรูปมาจี่กระทะให้กรอบนอกนุ่มใน',
        cookingTime: '10 min',
        difficulty: 'Very easy',
        dishType: 'stir_fry',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? '1 egg' : 'ไข่ไก่ 1 ฟอง',
          isEn ? '1 tbsp butter or cooking oil' : 'เนยหรือน้ำมันพืช 1 ช้อนโต๊ะ',
          isEn ? 'Black pepper and spring onions' : 'พริกไทยดำและต้นหอมซอย',
        ],
        steps: [
          isEn ? 'Melt butter in a pan over medium-high heat.' : 'ตั้งกระทะใส่เนยด้วยไฟกลาง',
          isEn ? `Press ${displayIngredient} into pan until bottom forms a crispy crust.` : `ใส่${displayIngredient}ลงไป กดเบาๆ ให้ก้นกระทะเกรียมกรอบ`,
          isEn ? 'Crack egg on top, season with pepper, and serve sizzling hot.' : 'ตอกไข่ใส่ด้านบน โรยพริกไทย เสิร์ฟร้อนๆ',
        ],
      },
      {
        id: 'recipe_meal_2',
        title: isEn ? `Cheesy Oven-baked ${displayIngredient} Melt` : `อบชีสเยิ้มๆ จาก${displayIngredient}`,
        description: isEn ? 'Repurpose leftovers into a luxurious melted gratin.' : 'เปลี่ยนอาหารเดิมๆ ให้กลายเป็นเมนูอบชีสสุดพรีเมียม',
        cookingTime: '12 min',
        difficulty: 'Easy',
        dishType: 'pasta',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? '1/2 cup shredded cheese' : 'ชีสขูด 1/2 ถ้วย',
          isEn ? 'Oregano or chili flakes' : 'ออริกาโนหรือพริกป่นเล็กน้อย',
        ],
        steps: [
          isEn ? `Place ${displayIngredient} into an oven-safe bowl.` : `ตัก${displayIngredient}ใส่ชามอบทนความร้อน`,
          isEn ? 'Cover with cheese and sprinkle oregano.' : 'โรยชีสปิดหน้าให้มิด โรยออริกาโน',
          isEn ? 'Bake at 180°C for 8-10 minutes until cheese is bubbly and browned.' : 'อบที่ 180°C ประมาณ 8-10 นาทีจนชีสเยิ้มสีทอง',
        ],
      },
      {
        id: 'recipe_meal_3',
        title: isEn ? `Loaded Fried Rice Bowl with ${displayIngredient}` : `ข้าวผัดมิกซ์แอนด์แมตช์ใส่${displayIngredient}`,
        description: isEn ? 'Quick wok toss making zero-waste meal exciting.' : 'ผัดคลุกเคล้าข้าวสวยร้อนๆ หอมกลิ่นกระทะ อร่อยลงตัว',
        cookingTime: '10 min',
        difficulty: 'Easy',
        dishType: 'fried_rice',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? '1 plate cooked jasmine rice' : 'ข้าวสวย 1 จาน',
          isEn ? '1 egg' : 'ไข่ไก่ 1 ฟอง',
          isEn ? '1 tbsp soy sauce' : 'ซีอิ๊วขาว 1 ช้อนโต๊ะ',
        ],
        steps: [
          isEn ? 'Scramble egg in hot wok with oil.' : 'ผัดไข่ในกระทะร้อนจนสุก',
          isEn ? `Toss in ${displayIngredient} followed by rice.` : `ใส่${displayIngredient}และข้าวสวยลงไปผัด`,
          isEn ? 'Season with soy sauce, stir over high heat for 2 minutes.' : 'ปรุงรสด้วยซีอิ๊วขาว ผัดไฟแรงจนหอมพร้อมเสิร์ฟ',
        ],
      },
      {
        id: 'recipe_meal_4',
        title: isEn ? `Crispy Breakfast Wrap with ${displayIngredient}` : `แรปโรลสอดไส้${displayIngredient}`,
        description: isEn ? 'Warm tortilla wrapped tight around savory fillings.' : 'แรปโรลแป้งตอร์ติญ่าสอดไส้ ทานง่าย พกพาสะดวก',
        cookingTime: '8 min',
        difficulty: 'Very easy',
        dishType: 'sandwich',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? '1 flour tortilla or flatbread' : 'แผ่นแป้งตอร์ติญ่า 1 แผ่น',
          isEn ? '1 slice cheese or lettuce' : 'ชีส 1 แผ่นหรือผักสลัด',
        ],
        steps: [
          isEn ? `Warm tortilla and layer with cheese and ${displayIngredient}.` : `อุ่นแผ่นแป้ง วางชีสและ${displayIngredient}ลงไป`,
          isEn ? 'Roll tightly into a burrito or wrap.' : 'ม้วนแผ่นแป้งให้แน่นเป็นโรล',
          isEn ? 'Toast on dry skillet until golden crisp on seams.' : 'นำไปจี่ในกระทะจนแป้งกรอบเหลือง หั่นครึ่งเสิร์ฟ',
        ],
      },
      {
        id: 'recipe_meal_5',
        title: isEn ? `Comforting Broth Bowl with ${displayIngredient}` : `ซุปชุ่มคอใส่${displayIngredient}`,
        description: isEn ? 'Revive leftover meal into a warm noodle or broth bowl.' : 'ซดน้ำซุปร้อนๆ ชุ่มคอ สบายท้อง อร่อยง่ายในหม้อเดียว',
        cookingTime: '10 min',
        difficulty: 'Very easy',
        dishType: 'soup',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? '2 cups hot water or stock' : 'น้ำเปล่าหรือน้ำซุป 2 ถ้วย',
          isEn ? '1 tbsp light soy sauce' : 'ซีอิ๊วขาว 1 ช้อนโต๊ะ',
          isEn ? 'Spring onion or fried garlic' : 'ต้นหอมซอยหรือกระเทียมเจียว',
        ],
        steps: [
          isEn ? 'Bring broth to a boil in small pot.' : 'ต้มน้ำซุปในหม้อให้เดือด',
          isEn ? `Gently warm ${displayIngredient} in hot broth for 3 minutes.` : `ใส่${displayIngredient}ลงไปต้มอุ่นประมาณ 3 นาที`,
          isEn ? 'Garnish with spring onions and fried garlic before serving.' : 'โรยต้นหอมและกระเทียมเจียว ยกลงเสิร์ฟร้อนๆ',
        ],
      },
      {
        id: 'recipe_meal_6',
        title: isEn ? `Golden Egg Scramble over ${displayIngredient}` : `ไข่ข้นราด${displayIngredient}`,
        description: isEn ? 'Silky eggs draped over warm meal base.' : 'ไข่ข้นเนื้อนุ่มเยิ้มๆ ราดบนอาหารจานเดิม ชวนให้น่ากินยิ่งขึ้น',
        cookingTime: '6 min',
        difficulty: 'Very easy',
        dishType: 'omelet',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? '2 eggs' : 'ไข่ไก่ 2 ฟอง',
          isEn ? '1 tbsp milk or water' : 'นมสด 1 ช้อนโต๊ะ',
          isEn ? '1 tbsp butter' : 'เนยสด 1 ช้อนโต๊ะ',
        ],
        steps: [
          isEn ? `Heat ${displayIngredient} in microwave or pan and plate it.` : `อุ่น${displayIngredient}ให้ร้อนแล้วตักใส่จานรอไว้`,
          isEn ? 'Cook eggs gently in butter until soft curds form.' : 'ตีไข่กับนมแล้วเทลงกระทะทาเนย คนเบาๆ จนไข่เริ่มเซ็ตตัวเยิ้มๆ',
          isEn ? 'Slide silky eggs right over the meal and enjoy.' : 'ตักไข่ข้นราดลงบน${displayIngredient}ทันที',
        ],
      },
      {
        id: 'recipe_meal_7',
        title: isEn ? `Quick Savory Skillet Stir-fry with ${displayIngredient}` : `ผัดคลุกกระทะร้อนใส่${displayIngredient}`,
        description: isEn ? 'Fast stir fry refreshing flavors and textures.' : 'ผัดกระทะร้อนฉ่า หอมกลิ่นคั่วกระทะ ชวนน้ำลายสอ',
        cookingTime: '8 min',
        difficulty: 'Easy',
        dishType: 'stir_fry',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? 'Garlic and chili to taste' : 'กระเทียมและพริกสับตามชอบ',
          isEn ? '1 tbsp oyster sauce or soy sauce' : 'น้ำมันหอยหรือซีอิ๊วขาว 1 ช้อนโต๊ะ',
        ],
        steps: [
          isEn ? 'Sauté garlic in hot oil.' : 'ผัดกระเทียมในน้ำมันจนหอม',
          isEn ? `Add ${displayIngredient} and toss vigorously.` : `ใส่${displayIngredient}ลงไป ผัดคลุกเคล้าไฟแรง`,
          isEn ? 'Season lightly and serve immediately.' : 'ปรุงรสเล็กน้อย ผัดให้เข้ากัน ปิดไฟเสิร์ฟ',
        ],
      },
      {
        id: 'recipe_meal_8',
        title: isEn ? `Crispy Toastie Stuffed with ${displayIngredient}` : `แซนด์วิชปิ้งไส้ทะลักใส่${displayIngredient}`,
        description: isEn ? 'Golden pressed toast loaded with delicious savory filling.' : 'ประกบขนมปังปิ้งให้กรอบนอกนุ่มใน ไส้แน่นจุใจ',
        cookingTime: '8 min',
        difficulty: 'Very easy',
        dishType: 'sandwich',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? '2 bread slices' : 'ขนมปัง 2 แผ่น',
          isEn ? 'Butter or mayo' : 'เนยหรือมายองเนส',
        ],
        steps: [
          isEn ? `Spread butter on bread and place ${displayIngredient} inside.` : `ทาเนยบนขนมปัง ใส่ไส้${displayIngredient}ลงไป`,
          isEn ? 'Press in hot pan or sandwich maker until golden crisp.' : 'นำไปจี่ในกระทะหรือเครื่องปิ้งขนมปังจนกรอบทั้งสองด้าน',
          isEn ? 'Cut in half diagonally and enjoy hot.' : 'หั่นครึ่งตามแนวทแยง พร้อมเสิร์ฟ',
        ],
      },
    ];
  } else {
    // Proteins pool (Savory dishes)
    pool = [
      {
        id: 'recipe_fallback_1',
        title: isEn ? `Stir-fried ${displayIngredient} with Garlic & Pepper` : `ผัดกระเทียมพริกไทย${displayIngredient}`,
        description: isEn ? 'Quick, aromatic, and comforting dish in under 10 minutes.' : 'หอมกลิ่นกระเทียมพริกไทย ทำง่าย รสกลมกล่อม',
        cookingTime: '10 min',
        difficulty: 'Very easy',
        dishType: 'stir_fry',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? '3 cloves garlic, crushed' : 'กระเทียมสับ 3 กลีบ',
          isEn ? '1 tbsp soy sauce' : 'ซีอิ๊วขาว 1 ช้อนโต๊ะ',
          isEn ? '1 tbsp cooking oil' : 'น้ำมันพืช 1 ช้อนโต๊ะ',
          isEn ? 'Ground pepper to taste' : 'พริกไทยป่นเล็กน้อย',
        ],
        steps: [
          isEn ? 'Heat oil in a pan over medium heat and sauté garlic until fragrant.' : 'ตั้งกระทะใส่น้ำมัน นำกระเทียมลงผัดจนหอมกรุ่น',
          isEn ? `Add ${displayIngredient} and stir-fry for 3-5 minutes.` : `ใส่${displayIngredient}ลงไปผัดให้สุกและเข้ากัน 3-5 นาที`,
          isEn ? 'Season with soy sauce and pepper, then serve with warm rice.' : 'ปรุงรสด้วยซีอิ๊วขาวและพริกไทย ตักเสิร์ฟพร้อมข้าวสวยร้อนๆ',
        ],
      },
      {
        id: 'recipe_fallback_2',
        title: isEn ? `Golden Fluffy Omelet with ${displayIngredient}` : `ไข่เจียวทรงเครื่องใส่${displayIngredient}`,
        description: isEn ? 'Fluffy eggs loaded with savory flavors.' : 'ไข่เจียวฟูนุ่มกรอบนอกนุ่มใน เข้ากันได้อย่างลงตัว',
        cookingTime: '10 min',
        difficulty: 'Very easy',
        dishType: 'omelet',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? '2 large eggs' : 'ไข่ไก่ 2 ฟอง',
          isEn ? '1 tsp fish sauce or light soy sauce' : 'น้ำปลาหรือซีอิ๊วขาว 1 ช้อนชา',
          isEn ? 'Cooking oil for frying' : 'น้ำมันสำหรับทอด',
        ],
        steps: [
          isEn ? `Beat eggs together in a bowl and mix in chopped ${displayIngredient}.` : `ตอกไข่ใส่ชาม ตีให้เข้ากันแล้วใส่${displayIngredient}ที่หั่นพอดีคำลงไป`,
          isEn ? 'Heat oil in pan until hot, pour egg mixture and fry until golden.' : 'ตั้งน้ำมันให้ร้อน เทไข่ลงทอดจนเหลืองฟูกรอบทั้งสองด้าน',
          isEn ? 'Drain excess oil and serve hot.' : 'ตักขึ้นสะเด็ดน้ำมัน พร้อมรับประทาน',
        ],
      },
      {
        id: 'recipe_fallback_3',
        title: isEn ? `Classic Fried Rice with ${displayIngredient}` : `ข้าวผัดโบราณใส่${displayIngredient}`,
        description: isEn ? 'The ultimate zero-waste meal using leftover rice.' : 'เปลี่ยนข้าวสวยและวัตถุดิบเหลือให้เป็นมื้ออร่อยง่ายๆ',
        cookingTime: '15 min',
        difficulty: 'Easy',
        dishType: 'fried_rice',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? '1 plate cooked jasmine rice' : 'ข้าวสวย 1 จาน',
          isEn ? '1 egg' : 'ไข่ไก่ 1 ฟอง',
          isEn ? '1 tbsp soy sauce' : 'ซีอิ๊วขาว 1 ช้อนโต๊ะ',
          isEn ? '1/2 tsp sugar' : 'น้ำตาลทราย 1/2 ช้อนชา',
        ],
        steps: [
          isEn ? 'Sauté garlic in a hot pan, add egg and scramble lightly.' : 'ผัดกระเทียมในกระทะ ตอกไข่ใส่แล้วยีพอสุก',
          isEn ? `Add ${displayIngredient} followed by cooked rice.` : `ใส่${displayIngredient}และข้าวสวยลงไป ผัดให้เข้ากัน`,
          isEn ? 'Season with soy sauce and sugar, stir over high heat for 2 minutes.' : 'ปรุงรสด้วยซีอิ๊วขาวและน้ำตาล ผัดไฟแรง 2 นาทีจนหอมกระทะ',
        ],
      },
      {
        id: 'recipe_fallback_4',
        title: isEn ? `Comforting Soup with ${displayIngredient}` : `ต้มจืดซุปร้อนๆ ใส่${displayIngredient}`,
        description: isEn ? 'Soothing clear broth that warms the soul.' : 'น้ำซุปใสกลมกล่อม ซดคล่องคอ สบายท้อง',
        cookingTime: '15 min',
        difficulty: 'Easy',
        dishType: 'soup',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? '2 cups water or stock' : 'น้ำเปล่าหรือน้ำซุป 2 ถ้วย',
          isEn ? '1 tbsp light soy sauce' : 'ซีอิ๊วขาว 1 ช้อนโต๊ะ',
          isEn ? 'Spring onions or coriander for garnish' : 'ต้นหอมหรือผักชีโรยหน้า',
        ],
        steps: [
          isEn ? 'Bring water or broth to a boil in a pot.' : 'ตั้งน้ำให้เดือดในหม้อ',
          isEn ? `Add ${displayIngredient} and simmer for 5-8 minutes.` : `ใส่${displayIngredient}ลงไปต้มประมาณ 5-8 นาที`,
          isEn ? 'Season with light soy sauce and garnish with fresh herbs.' : 'ปรุงรสด้วยซีอิ๊วขาว โรยผักชีหรือต้นหอมก่อนเสิร์ฟ',
        ],
      },
      {
        id: 'recipe_fallback_5',
        title: isEn ? `Fresh Crispy ${displayIngredient} Salad` : `ยำหรือสลัดคลีนๆ ใส่${displayIngredient}`,
        description: isEn ? 'Refreshing and vibrant meal ready in minutes.' : 'รสชาติสดชื่น อิ่มเบาสบายท้อง ไม่เลี่ยน',
        cookingTime: '8 min',
        difficulty: 'Very easy',
        dishType: 'salad',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? 'Assorted salad greens or tomatoes' : 'ผักสลัดหรือมะเขือเทศตามชอบ',
          isEn ? '1 tbsp lemon or lime juice' : 'น้ำมะนาว 1 ช้อนโต๊ะ',
          isEn ? '1 tbsp olive oil or dressing' : 'น้ำมันมะกอกหรือน้ำสลัด 1 ช้อนโต๊ะ',
        ],
        steps: [
          isEn ? `Warm or prepare ${displayIngredient}.` : `เตรียม${displayIngredient}ให้พร้อมรับประทาน`,
          isEn ? 'Combine greens in a bowl and arrange ingredients nicely.' : 'จัดผักสดใส่จาน วางวัตถุดิบลงไปให้สวยงาม',
          isEn ? 'Drizzle dressing and toss gently before eating.' : 'ราดน้ำสลัดหรือน้ำยำ คลุกเคล้าเบาๆ พร้อมเสิร์ฟ',
        ],
      },
      {
        id: 'recipe_fallback_6',
        title: isEn ? `Toasted Sandwich with ${displayIngredient}` : `แซนด์วิชขนมปังปิ้งไส้${displayIngredient}`,
        description: isEn ? 'Crispy, warm, and satisfying snack or breakfast.' : 'กรอบนอกนุ่มใน อร่อยอยู่ท้อง ทำเสร็จไวสุดๆ',
        cookingTime: '10 min',
        difficulty: 'Very easy',
        dishType: 'sandwich',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? '2 slices bread' : 'ขนมปัง 2 แผ่น',
          isEn ? '1 tbsp mayo or butter' : 'มายองเนสหรือเนย 1 ช้อนโต๊ะ',
          isEn ? 'Cheese or lettuce (optional)' : 'ชีสหรือผักสลัด (ถ้ามี)',
        ],
        steps: [
          isEn ? 'Toast bread slices until golden brown.' : 'ปิ้งขนมปังให้เหลืองกรอบ',
          isEn ? `Spread mayo or butter, then layer with ${displayIngredient}.` : `ทามายองเนสหรือเนย วางไส้${displayIngredient}ลงไป`,
          isEn ? 'Cut in half diagonally and enjoy warm.' : 'ประกบขนมปัง หั่นครึ่ง พร้อมรับประทาน',
        ],
      },
      {
        id: 'recipe_fallback_7',
        title: isEn ? `Spicy Basil Stir-fry with ${displayIngredient}` : `ผัดกะเพรารสเด็ดใส่${displayIngredient}`,
        description: isEn ? 'Fiery and aromatic Thai holy basil stir fry.' : 'เผ็ดร้อนหอมกลิ่นใบกะเพรา เมนูยอดฮิตทำง่ายสุดๆ',
        cookingTime: '10 min',
        difficulty: 'Easy',
        dishType: 'stir_fry',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? 'Handful of fresh holy basil' : 'ใบกะเพรา 1 กำมือ',
          isEn ? 'Chilies and garlic' : 'พริกขี้หนูและกระเทียมสับ',
          isEn ? 'Oyster sauce and soy sauce' : 'น้ำมันหอยและซีอิ๊วขาว',
        ],
        steps: [
          isEn ? 'Pound chilies and garlic, sauté in hot oil.' : 'โขลกพริกกระเทียมลงผัดในน้ำมันจนหอมฉุน',
          isEn ? `Add ${displayIngredient} and season.` : `ใส่${displayIngredient}ลงไปผัด ปรุงรสด้วยน้ำมันหอยและซีอิ๊ว`,
          isEn ? 'Toss in holy basil and serve over rice.' : 'ใส่ใบกะเพรา ปิดไฟ ผัดเคล้าให้เข้ากัน เสิร์ฟพร้อมข้าวสวย',
        ],
      },
      {
        id: 'recipe_fallback_8',
        title: isEn ? `Creamy Lava Egg Bowl with ${displayIngredient}` : `ข้าวไข่ข้นลาวาหน้า${displayIngredient}`,
        description: isEn ? 'Silky runny scrambled eggs topping warm rice.' : 'ไข่ข้นเยิ้มๆ นุ่มละมุนลิ้น เข้ากันดีเยี่ยม',
        cookingTime: '8 min',
        difficulty: 'Very easy',
        dishType: 'omelet',
        expiringIngredient: displayIngredient,
        ingredients: [
          `${displayIngredient}`,
          isEn ? '2 eggs' : 'ไข่ไก่ 2 ฟอง',
          isEn ? '2 tbsp milk' : 'นมสด 2 ช้อนโต๊ะ',
          isEn ? 'Butter or oil' : 'เนยสดหรือน้ำมันพืช',
        ],
        steps: [
          isEn ? 'Whisk eggs with milk.' : 'ตีไข่กับนมสดและซีอิ๊วขาวเบาๆ',
          isEn ? 'Cook gently in butter until half set.' : 'ตั้งกระทะใส่เนย ใช้ไฟอ่อน เทไข่ลงไปใช้ตะหลิวดันเข้าตรงกลาง',
          isEn ? `Top with ${displayIngredient} and pour over rice.` : `วาง${displayIngredient}ลงไปด้านบน พอไข่เยิ้มๆ ตักราดข้าวทันที`,
        ],
      },
    ];
  }

  if (offset > 0 && pool.length > 6) {
    const shift = (offset * 2) % pool.length;
    return [...pool.slice(shift), ...pool.slice(0, shift)].slice(0, 6);
  }
  return pool.slice(0, 6);
}

async function scanLabel(buffer, mimeType, language = 'en', mode = 'full') {
  let model = (process.env.GEMINI_MODEL || 'gemini-3.5-flash-lite').replace(/^["']|["']$/g, '');
  if (model.includes('2.5') || model.includes('1.5')) {
    model = 'gemini-3.5-flash-lite';
  }

  const promptText = mode === 'expiry_only' ? getExpiryOnlyPrompt(language) : getScanLabelPrompt(language);
  const res = await ai.models.generateContent({
    model,
    contents: [
      { inlineData: { mimeType, data: buffer.toString('base64') } },
      { text: promptText },
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
    const parsed = JSON.parse(res.text);
    if (mode === 'expiry_only') {
      return {
        expiryDate: parsed.expiryDate || null,
        confidence: typeof parsed.confidence === 'number' ? parsed.confidence : 0.8,
      };
    }

    if (typeof parsed.is_food !== 'boolean') {
      parsed.is_food = Boolean(parsed.foodName && parsed.foodName.toLowerCase() !== 'null');
    }
    if (parsed.is_food === false) {
      parsed.foodName = null;
    }
    if (typeof parsed.confidence !== 'number') {
      parsed.confidence = parsed.is_food ? 0.9 : 0.0;
    }
    if (language === 'en' && parsed.foodName && /[\u0E00-\u0E7F]/.test(parsed.foodName)) {
      parsed.foodName = translateThaiIngredientToEn(parsed.foodName);
    }
    if (language === 'th' && parsed.foodName && !/[\u0E00-\u0E7F]/.test(parsed.foodName)) {
      parsed.foodName = translateEnIngredientToThai(parsed.foodName);
    }
    return parsed;
  } catch (err) {
    throw new Error('Failed to parse AI response into valid JSON');
  }
}

async function suggestRecipes({ userId, mainIngredient, category, language = 'en', offset = 0 }) {
  // Check daily rate limit (3 requests/day per user)
  let remainingQuota = DAILY_RECIPE_LIMIT;
  let usedQuota = 1;
  if (userId) {
    const quota = checkAndIncrementRecipeQuota(userId, mainIngredient);
    if (!quota.allowed) {
      const errorMsg = language === 'en'
        ? 'You have reached your daily limit of 3 recipe generations. Try making one of your suggested recipes! ✨'
        : 'วันนี้คุณใช้โควตาครบ 3 ครั้งแล้ว ลองเลือกเมนูที่แนะนำไปทำอาหารอร่อยๆ กันก่อนนะ! ✨';
      const error = new Error(errorMsg);
      error.statusCode = 429;
      error.usedQuota = DAILY_RECIPE_LIMIT;
      error.remainingQuota = 0;
      throw error;
    }
    remainingQuota = quota.remaining;
    usedQuota = quota.used;
  }

  const detectedCat = detectCategory(mainIngredient, category);
  const isEn = language === 'en';
  const displayIngredient = isEn ? translateThaiIngredientToEn(mainIngredient) : translateEnIngredientToThai(mainIngredient);

  let categoryGuidelineEn = '';
  let categoryGuidelineTh = '';

  switch (detectedCat) {
    case 'beverages':
      categoryGuidelineEn = `CRITICAL CATEGORY REQUIREMENT (Beverages):
- The hero ingredient "${displayIngredient}" is a beverage or drink liquid.
- Every recipe MUST focus on creative drinks, specialty coffee/tea beverages, smoothies, milkshakes, mocktails, or breakfast/bakery items naturally baked/made with beverages (e.g. fluffy pancakes made with this beverage, French toast, chia seed pudding, overnight oats, latte, frappe, granita).
- STRICTLY FORBIDDEN: Do NOT generate savory lunch/dinner dishes like stir-fry with garlic, savory clear soup, savory curries, or savory fried rice!`;
      categoryGuidelineTh = `ข้อกำหนดสำคัญมากสำหรับหมวดเครื่องดื่ม (Beverages):
- วัตถุดิบหลัก "${mainIngredient}" เป็นเครื่องดื่มหรือของเหลว
- เมนูทั้ง 6 ต้องเน้นเฉพาะเครื่องดื่มสร้างสรรค์, เมนูกาแฟ/ชา/ม็อกเทล/สมูทตี้/เชค, หรือเมนูเบเกอรี่/มื้อเช้าที่ใช้น้ำ/นม/เครื่องดื่มเป็นส่วนผสมหลัก (เช่น แพนเค้ก, เฟรนช์โทสต์, ข้าวโอ๊ตข้ามคืน, พุดดิ้งเจีย, ลาเต้)
- ห้ามเด็ดขาด: ห้ามแนะนำอาหารคาวจานหลัก เช่น ผัดกระเทียม, ข้าวผัด, ต้มจืด, หรือแกงคาวเด็ดขาด`;
      break;

    case 'sauces':
      categoryGuidelineEn = `CRITICAL CATEGORY REQUIREMENT (Sauces & Condiments):
- The hero ingredient "${displayIngredient}" is a sauce, condiment, dressing, or spread.
- Every recipe MUST highlight the sauce as the flavor hero: glazed pan-seared proteins/tofu, tossed pasta/noodles, salad dressing creations, dipping platter pairings, or toasted melts.
- STRICTLY FORBIDDEN: Do NOT treat the sauce as a plain standalone meal to be eaten alone with a spoon (e.g. no stir-fried plain sauce).`;
      categoryGuidelineTh = `ข้อกำหนดสำคัญมากสำหรับหมวดซอสและเครื่องปรุง (Sauces):
- วัตถุดิบหลัก "${mainIngredient}" เป็นซอส เครื่องปรุง หรือสเปรด
- เมนูต้องชูซอสนี้เป็นตัวเอก เช่น เมนูย่างเกลซเคลือบซอส, เส้นพาสต้าคลุกซอส, น้ำสลัดสดชื่น, โทสต์อบชีสทาสเปรด, หรือของว่างพร้อมดิปซอส
- ห้ามเด็ดขาด: ห้ามนำซอสมาเป็นอาหารหลักกินเปล่าๆ เช่น ห้ามทำผัดซอสมะเขือเทศเปล่าๆ`;
      break;

    case 'veggies':
      categoryGuidelineEn = `CRITICAL CATEGORY REQUIREMENT (Vegetables & Fruits):
- Focus on vibrant crisp salads, comforting vegetable soups, garlic vegetable stir-fries, vegetable gratins/bakes, or refreshing fruit smoothies/desserts (for fruits).`;
      categoryGuidelineTh = `ข้อกำหนดสำหรับหมวดผักและผลไม้ (Veggies):
- เน้นสลัดสดชื่น, ซุปผักอุ่นๆ, ผัดผักสไตล์โฮมเมด, ผักอบชีส, เมนูชุบทอดกรอบ หรือสมูทตี้/ของหวานเพื่อสุขภาพ (กรณีเป็นผลไม้)`;
      break;

    case 'meals':
      categoryGuidelineEn = `CRITICAL CATEGORY REQUIREMENT (Meals & Staples):
- Focus on creative zero-waste leftover repurposing: crispy skillet hash, loaded wraps, cheesy pasta/grain melts, or sizzling fried rice bowls.`;
      categoryGuidelineTh = `ข้อกำหนดสำหรับหมวดอาหารจานเดียว (Meals):
- เน้นการชุบชีวิตอาหารและของเหลือ (Zero-waste) เช่น แฮชกระทะร้อน, แรปโรลสอดไส้, พาสต้าอบชีส, หรือข้าวผัดมิกซ์แอนด์แมตช์`;
      break;

    case 'proteins':
    default:
      categoryGuidelineEn = `CRITICAL CATEGORY REQUIREMENT (Proteins):
- Focus on hearty savory main dishes, pan-searing, stir-fries, fluffy egg dishes, nourishing soups, or high-protein bowls highlighting this protein.`;
      categoryGuidelineTh = `ข้อกำหนดสำหรับหมวดโปรตีน (Proteins):
- เน้นเมนูจานหลักอิ่มท้อง สเต๊ก, เมนูผัดกระเทียม/กะเพรา, ไข่ข้น, ต้มซุปร้อนๆ หรือโปรตีนโบวล์ที่ชูวัตถุดิบนี้`;
      break;
  }

  const langInstruction = isEn
    ? `All recipe titles, descriptions, ingredients, and instructions MUST be 100% in natural English.
CRITICAL: Do NOT include any Thai characters in titles, descriptions, ingredients, or steps. The ingredient "${mainIngredient}" translates to "${displayIngredient}". Use "${displayIngredient}" as the primary ingredient name in English.`
    : 'All recipe titles, descriptions, ingredients, and instructions MUST be in natural, creative, and friendly Thai (ภาษาไทยที่น่ากิน เข้าใจง่าย เป็นกันเอง).';

  const prompt = isEn
    ? `You are an expert creative chef specializing in quick, delicious zero-waste recipes using minimal ingredients (10-20 minutes).
Target primary ingredient: "${displayIngredient}" (original: "${mainIngredient}")
Category: ${detectedCat}

${categoryGuidelineEn}

Requirements:
1. Every recipe must highlight and focus strictly on "${displayIngredient}" as the main hero ingredient.
2. Supporting ingredients should be basic household pantry staples only (e.g. eggs, rice, cooking oil, garlic, soy sauce, salt, pepper, sugar, butter, flour, milk).
3. The 6 recipes must represent distinct culinary variations suitable for the "${detectedCat}" category.
4. Cooking time 5-20 min, difficulty Easy or Very easy.
5. ${langInstruction}

Respond strictly in JSON array of 6 items matching this schema:
[
  {
    "id": "recipe_1",
    "title": "Creative and appetizing dish name in English",
    "description": "Short appetizing description in 1 sentence",
    "cookingTime": "15 min",
    "difficulty": "Easy",
    "dishType": "stir_fry|omelet|soup|fried_rice|salad|sandwich|pasta|beverage|smoothie|pancake|dessert",
    "expiringIngredient": "${displayIngredient}",
    "ingredients": ["ingredient with quantity in English"],
    "steps": ["clear concise step in English"]
  }
]
`
    : `คุณคือสุดยอดเชฟ AI ผู้เชี่ยวชาญการคิดเมนูอาหารที่สร้างสรรค์ ทำง่าย ใช้วัตถุดิบน้อย (10-20 นาที)
วัตถุดิบที่ต้องการนำมาทำอาหาร: "${displayIngredient}"
หมวดหมู่: ${detectedCat}

${categoryGuidelineTh}

ข้อกำหนดสำคัญมาก:
1. ทุกเมนูต้องชูและโฟกัสเฉพาะ "${displayIngredient}" เป็นวัตถุดิบหลักเท่านั้น ห้ามใส่วัตถุดิบหลักอื่นที่ไม่เกี่ยวข้อง
2. วัตถุดิบเสริมต้องเป็นเครื่องปรุงหรือของพื้นฐานประจำบ้านเท่านั้น (เช่น ไข่ไก่, ข้าวสวย, น้ำมัน, กระเทียม, ซีอิ๊ว, น้ำปลา, เกลือ, พริกไทย, น้ำตาล, แป้ง, นม)
3. เมนูทั้ง 6 ต้องมีความหลากหลายที่เหมาะสมกับหมวดหมู่ "${detectedCat}" ไม่ซ้ำแนวกัน
4. เวลาปรุง 5-20 นาที ระดับความง่าย เช่น "ง่ายมาก", "ง่าย", "ปานกลาง"
5. ${langInstruction}

ตอบกลับเป็น JSON array ของวัตถุ 6 รายการเท่านั้น ตามโครงสร้างดังนี้:
[
  {
    "id": "recipe_1",
    "title": "ชื่อเมนูที่สร้างสรรค์และน่ากิน",
    "description": "คำอธิบายความอร่อยสั้นๆ 1 ประโยค ดึงดูดให้อยากทำ",
    "cookingTime": "15 นาที",
    "difficulty": "ง่ายมาก",
    "dishType": "stir_fry|omelet|soup|fried_rice|salad|sandwich|pasta|beverage|smoothie|pancake|dessert",
    "expiringIngredient": "${displayIngredient}",
    "ingredients": ["วัตถุดิบพร้อมปริมาณเป็นภาษาไทย"],
    "steps": ["ขั้นตอนการทำสั้นกระชับเข้าใจง่ายเป็นภาษาไทย"]
  }
]
`;

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
    recipes = generateFallbackRecipes(mainIngredient, language, offset, detectedCat);
  }

  if (recipes.length === 0) {
    recipes = generateFallbackRecipes(mainIngredient, language, offset, detectedCat);
  }

  // Ensure up to 6 recipes and attach unique non-repeating image assets
  const formattedRecipes = recipes.slice(0, 6).map((r, idx) => {
    let cTime = r.cookingTime || (language === 'th' ? '15 นาที' : '15 min');
    if (language === 'th') {
      cTime = cTime.replace(/mins?|minutes?/i, 'นาที').replace(/hrs?|hours?/i, 'ชั่วโมง');
    }
    let diff = r.difficulty || (language === 'th' ? 'ง่ายมาก' : 'Easy');
    if (language === 'th') {
      const dLower = diff.toLowerCase();
      if (dLower.includes('very easy')) diff = 'ง่ายมาก';
      else if (dLower.includes('easy')) diff = 'ง่าย';
      else if (dLower.includes('medium')) diff = 'ปานกลาง';
      else if (dLower.includes('hard')) diff = 'ยาก';
    }
    return attachRecipeImages(
      {
        id: r.id || `recipe_${idx + 1}`,
        title: r.title || (language === 'th' ? `เมนูจาก ${displayIngredient}` : `Menu with ${displayIngredient}`),
        description: r.description || '',
        cookingTime: cTime,
        difficulty: diff,
        dishType: r.dishType || 'stir_fry',
        expiringIngredient: r.expiringIngredient || displayIngredient,
        ingredients: Array.isArray(r.ingredients) ? r.ingredients : [],
        steps: Array.isArray(r.steps) ? r.steps : [],
      },
      displayIngredient,
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
  detectCategory,
  translateThaiIngredientToEn,
  DISH_IMAGES,
  DISH_IMAGE_POOLS,
};
