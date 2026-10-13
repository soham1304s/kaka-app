class FoodItem {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final double rating;
  final int reviewCount;
  final String deliveryTime;
  final int calories;
  final String imageUrl;
  final bool isPopular;
  final bool isChefSpecial;
  final List<String> ingredients;
  final int spicyLevel; // 0: None, 1: Mild, 2: Medium, 3: Hot
  final bool isVegetarian;

  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
    required this.calories,
    required this.imageUrl,
    this.isPopular = false,
    this.isChefSpecial = false,
    this.ingredients = const [],
    this.spicyLevel = 0,
    this.isVegetarian = false,
  });

  FoodItem copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    double? price,
    double? rating,
    int? reviewCount,
    String? deliveryTime,
    int? calories,
    String? imageUrl,
    bool? isPopular,
    bool? isChefSpecial,
    List<String>? ingredients,
    int? spicyLevel,
    bool? isVegetarian,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      calories: calories ?? this.calories,
      imageUrl: imageUrl ?? this.imageUrl,
      isPopular: isPopular ?? this.isPopular,
      isChefSpecial: isChefSpecial ?? this.isChefSpecial,
      ingredients: ingredients ?? this.ingredients,
      spicyLevel: spicyLevel ?? this.spicyLevel,
      isVegetarian: isVegetarian ?? this.isVegetarian,
    );
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'All',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      deliveryTime: json['deliveryTime'] as String? ?? '20-25 min',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      isPopular: json['isPopular'] as bool? ?? false,
      isChefSpecial: json['isChefSpecial'] as bool? ?? false,
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      spicyLevel: (json['spicyLevel'] as num?)?.toInt() ?? 0,
      isVegetarian: json['isVegetarian'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'rating': rating,
      'reviewCount': reviewCount,
      'deliveryTime': deliveryTime,
      'calories': calories,
      'imageUrl': imageUrl,
      'isPopular': isPopular,
      'isChefSpecial': isChefSpecial,
      'ingredients': ingredients,
      'spicyLevel': spicyLevel,
      'isVegetarian': isVegetarian,
    };
  }
}
