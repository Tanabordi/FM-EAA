class RecipeModel {
  final String id;
  final String title;
  final String imageUrl;
  final String assetFallback;
  final String cookingTime;
  final String difficulty;
  final List<String> ingredientsFromFridge;
  final List<String> extraPantryIngredients;
  final List<String> steps;

  const RecipeModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.assetFallback,
    required this.cookingTime,
    required this.difficulty,
    this.ingredientsFromFridge = const [],
    this.extraPantryIngredients = const [],
    this.steps = const [],
  });
}
