/// Helper to resolve appropriate high-res food asset illustrations
/// when an item does not have a photo or when a local file is inaccessible on another device (e.g. invited member)
String getFoodAssetFallback(String name, {String? category}) {
  final lower = name.toLowerCase().trim();
  final cat = category?.toLowerCase().trim() ?? '';

  // 1. Proteins & Meats
  if (lower.contains('sausage') ||
      lower.contains('ไส้กรอก') ||
      lower.contains('ค็อกเทล') ||
      lower.contains('cocktail') ||
      lower.contains('hotdog')) {
    return 'assets/images/food_chicken_breasts.png';
  }
  if (lower.contains('chicken') || lower.contains('ไก่') || lower.contains('heart')) {
    return 'assets/images/food_chicken_breasts.png';
  }
  if (lower.contains('pork') ||
      lower.contains('beef') ||
      lower.contains('หมู') ||
      lower.contains('เนื้อ') ||
      lower.contains('steak') ||
      lower.contains('meat')) {
    return 'assets/images/food_chicken_breasts.png';
  }
  if (lower.contains('egg') || lower.contains('ไข่')) {
    return 'assets/images/food_eggs.png';
  }
  if (lower.contains('salmon') ||
      lower.contains('fish') ||
      lower.contains('seafood') ||
      lower.contains('shrimp') ||
      lower.contains('ปลา') ||
      lower.contains('กุ้ง')) {
    return 'assets/images/food_salmon_fillets.png';
  }
  if (lower.contains('tofu') || lower.contains('เต้าหู้')) {
    return 'assets/images/food_firm_tofu.png';
  }
  if (lower.contains('nugget') || lower.contains('นักเก็ต')) {
    return 'assets/images/food_nuggets.png';
  }
  if (lower.contains('dumpling') || lower.contains('เกี๊ยว') || lower.contains('dimsum')) {
    return 'assets/images/food_dumplings.png';
  }

  // 2. Veggies & Fruits
  if (lower.contains('ketchup') || lower.contains('tomato') || lower.contains('มะเขือเทศ')) {
    return 'assets/images/food_cherry_tomatoes.png';
  }
  if (lower.contains('strawberr') || lower.contains('berry') || lower.contains('สตรอ')) {
    return 'assets/images/food_strawberries.png';
  }
  if (lower.contains('spinach') ||
      lower.contains('cabbage') ||
      lower.contains('lettuce') ||
      lower.contains('kale') ||
      lower.contains('ผัก')) {
    return 'assets/images/food_spinach.png';
  }
  if (lower.contains('avocado') ||
      lower.contains('อะโวคาโด') ||
      lower.contains('banana') ||
      lower.contains('กล้วย') ||
      lower.contains('apple') ||
      lower.contains('fruit') ||
      lower.contains('ผลไม้')) {
    return 'assets/images/food_avocados.png';
  }

  // 3. Beverages & Drinks
  if (lower.contains('coca') ||
      lower.contains('cola') ||
      lower.contains('coke') ||
      lower.contains('sprite') ||
      lower.contains('soda') ||
      lower.contains('cold brew') ||
      lower.contains('coffee') ||
      lower.contains('กาแฟ') ||
      lower.contains('ice') ||
      lower.contains('น้ำแข็ง')) {
    return 'assets/images/food_cold_brew.png';
  }
  if (lower.contains('orange') || lower.contains('juice') || lower.contains('น้ำส้ม') || lower.contains('น้ำผลไม้')) {
    return 'assets/images/food_orange_juice.png';
  }
  if (lower.contains('milk') || lower.contains('นม') || lower.contains('dairy')) {
    return 'assets/images/food_whole_milk.png';
  }
  if (lower.contains('kombucha') ||
      lower.contains('tea') ||
      lower.contains('ชา') ||
      lower.contains('น้ำดื่ม') ||
      lower.contains('water')) {
    return 'assets/images/food_kombucha.png';
  }

  // 4. Sauces & Condiments
  if (lower.contains('mayo') ||
      lower.contains('มายองเนส') ||
      lower.contains('dressing') ||
      lower.contains('น้ำสลัด') ||
      lower.contains('dip')) {
    return 'assets/images/food_mayo.png';
  }
  if (lower.contains('soy') ||
      lower.contains('ซีอิ๊ว') ||
      lower.contains('น้ำปลา') ||
      lower.contains('fish sauce') ||
      lower.contains('sauce')) {
    return 'assets/images/food_soy_sauce.png';
  }
  if (lower.contains('sriracha') || lower.contains('chili') || lower.contains('พริก') || lower.contains('ซอส')) {
    return 'assets/images/food_sriracha.png';
  }
  if (lower.contains('oil') || lower.contains('น้ำมัน')) {
    return 'assets/images/food_olive_oil.png';
  }

  // 5. Meals & Dry Goods
  if (lower.contains('pizza') || lower.contains('พิซซ่า')) {
    return 'assets/images/food_pizza.png';
  }
  if (lower.contains('lasagna') ||
      lower.contains('pasta') ||
      lower.contains('noodle') ||
      lower.contains('bread') ||
      lower.contains('ขนมปัง') ||
      lower.contains('แป้ง') ||
      lower.contains('flour') ||
      lower.contains('ข้าว') ||
      lower.contains('rice') ||
      lower.contains('curry') ||
      lower.contains('bento')) {
    return 'assets/images/food_lasagna.png';
  }

  // 6. Category-level fallbacks
  switch (cat) {
    case 'proteins':
      return 'assets/images/food_chicken_breasts.png';
    case 'veggies':
      return 'assets/images/food_spinach.png';
    case 'beverages':
      return 'assets/images/food_whole_milk.png';
    case 'sauces':
      return 'assets/images/food_sriracha.png';
    case 'meals':
      return 'assets/images/food_lasagna.png';
    default:
      return 'assets/images/food_avocados.png';
  }
}

