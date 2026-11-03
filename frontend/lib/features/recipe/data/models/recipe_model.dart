class RecipeModel {
  final String id;
  final String title;
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
    required this.imageUrl,
    required this.assetFallback,
    required this.cookingTime,
    required this.difficulty,
    this.expiringIngredient = 'Strawberries',
    this.ingredients = const [],
    this.steps = const [],
  });
}
