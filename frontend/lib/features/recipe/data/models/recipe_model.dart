class RecipeModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String assetFallback;
  final String cookingTime;
  final String difficulty;
  final String expiringIngredient;
  final List<String> ingredients;
  final List<String> steps;

  const RecipeModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.imageUrl,
    required this.assetFallback,
    required this.cookingTime,
    required this.difficulty,
    this.expiringIngredient = 'Strawberries',
    this.ingredients = const [],
    this.steps = const [],
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json, {String? defaultExpiring}) {
    return RecipeModel(
      id: json['id']?.toString() ?? 'recipe_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? 'Recipe',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80',
      assetFallback: json['assetFallback']?.toString() ?? 'assets/images/food_lasagna.png',
      cookingTime: json['cookingTime']?.toString() ?? '15 min',
      difficulty: json['difficulty']?.toString() ?? 'Easy',
      expiringIngredient: json['expiringIngredient']?.toString() ?? defaultExpiring ?? 'Expiring item',
      ingredients: (json['ingredients'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      steps: (json['steps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'assetFallback': assetFallback,
      'cookingTime': cookingTime,
      'difficulty': difficulty,
      'expiringIngredient': expiringIngredient,
      'ingredients': ingredients,
      'steps': steps,
    };
  }
}
