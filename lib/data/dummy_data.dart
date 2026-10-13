import '../domain/models/food_item.dart';
import '../domain/models/user_profile.dart';

class PromoBannerData {
  final String id;
  final String title;
  final String subtitle;
  final String tag;
  final String discountCode;
  final String imageUrl;

  const PromoBannerData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.discountCode,
    required this.imageUrl,
  });

  factory PromoBannerData.fromJson(Map<String, dynamic> json) {
    return PromoBannerData(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      tag: json['tag'] as String? ?? '',
      discountCode: json['discountCode'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'tag': tag,
      'discountCode': discountCode,
      'imageUrl': imageUrl,
    };
  }
}

class DummyData {
  static const List<String> categories = [
    'All',
    'Burgers',
    'Pizza',
    'Asian & Bowls',
    'Healthy & Salads',
    'Desserts',
    'Beverages',
  ];

  static const List<PromoBannerData> promoBanners = [
    PromoBannerData(
      id: 'p1',
      title: 'Chef Special Truffle Burger',
      subtitle: 'Double Angus beef with black truffle glaze & aged cheddar',
      tag: '30% OFF',
      discountCode: 'TRUFFLE30',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&auto=format&fit=crop&q=80',
    ),
    PromoBannerData(
      id: 'p2',
      title: 'Woodfired Artisan Margherita',
      subtitle: 'San Marzano tomatoes, buffalo mozzarella & basil',
      tag: 'FREE DRINK',
      discountCode: 'PIZZAFREE',
      imageUrl: 'https://images.unsplash.com/photo-1604382355076-af4b0eb60143?w=800&auto=format&fit=crop&q=80',
    ),
    PromoBannerData(
      id: 'p3',
      title: 'Kyoto Ramen Bowl',
      subtitle: '24-hour slow simmered tonkotsu broth with chashu pork',
      tag: 'TRENDING NOW',
      discountCode: 'RAMENLOVE',
      imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&auto=format&fit=crop&q=80',
    ),
  ];

  static final List<FoodItem> foodItems = [
    const FoodItem(
      id: 'f1',
      name: 'Smokey BBQ Bacon Burger',
      category: 'Burgers',
      description: 'Charbroiled prime beef patty topped with crispy applewood smoked bacon, caramelized onions, melted cheddar cheese, and house BBQ sauce on a toasted brioche bun.',
      price: 299.00,
      rating: 4.9,
      reviewCount: 384,
      deliveryTime: '20-25 min',
      calories: 680,
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=700&auto=format&fit=crop&q=80',
      isPopular: true,
      isChefSpecial: true,
      ingredients: ['Prime Angus Beef', 'Applewood Bacon', 'Aged Cheddar', 'Caramelized Onion', 'Smokey BBQ', 'Brioche'],
      spicyLevel: 1,
    ),
    const FoodItem(
      id: 'f2',
      name: 'Rustic Neapolitan Truffle Pizza',
      category: 'Pizza',
      description: 'Authentic 48-hour fermented sour dough topped with creamy fior di latte mozzarella, wild mushrooms, fresh thyme, and aromatic white truffle oil infusion.',
      price: 449.00,
      rating: 4.8,
      reviewCount: 512,
      deliveryTime: '25-30 min',
      calories: 820,
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=700&auto=format&fit=crop&q=80',
      isPopular: true,
      ingredients: ['Sourdough', 'Fior di Latte', 'Wild Porcini', 'White Truffle Oil', 'Fresh Thyme'],
      isVegetarian: true,
    ),
    const FoodItem(
      id: 'f3',
      name: 'Crispy Korean Fried Chicken Bowl',
      category: 'Asian & Bowls',
      description: 'Double-fried crunchy chicken bites glazed in sweet and fiery gochujang chili sauce, served over fluffy jasmine rice with pickled radish and toasted sesame.',
      price: 329.00,
      rating: 4.9,
      reviewCount: 620,
      deliveryTime: '15-20 min',
      calories: 610,
      imageUrl: 'https://images.unsplash.com/photo-1562967914-608f82629710?w=700&auto=format&fit=crop&q=80',
      isPopular: true,
      isChefSpecial: true,
      ingredients: ['Organic Chicken', 'Gochujang Glaze', 'Jasmine Rice', 'Scallions', 'Pickled Daikon', 'Sesame'],
      spicyLevel: 2,
    ),
    const FoodItem(
      id: 'f4',
      name: 'California Salmon Poke Bowl',
      category: 'Healthy & Salads',
      description: 'Sashimi-grade Norwegian salmon with creamy avocado, edamame beans, cucumber ribbons, wakame seaweed salad, and house yuzu sesame ponzu dressing.',
      price: 399.00,
      rating: 4.7,
      reviewCount: 290,
      deliveryTime: '15-20 min',
      calories: 490,
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=700&auto=format&fit=crop&q=80',
      isPopular: false,
      ingredients: ['Norwegian Salmon', 'Ripe Avocado', 'Edamame', 'Wakame', 'Organic Brown Rice', 'Ponzu'],
      spicyLevel: 0,
    ),
    const FoodItem(
      id: 'f5',
      name: 'Spicy Pepperoni Inferno Pizza',
      category: 'Pizza',
      description: 'Handcrafted pizza layered with spicy calabrese salami, pickled jalapeño coins, hot honey drizzle, and fresh mozzarella over rich San Marzano tomato sauce.',
      price: 429.00,
      rating: 4.8,
      reviewCount: 440,
      deliveryTime: '20-25 min',
      calories: 860,
      imageUrl: 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=700&auto=format&fit=crop&q=80',
      isPopular: true,
      ingredients: ['Calabrese Salami', 'San Marzano Sauce', 'Mozzarella', 'Pickled Jalapeños', 'Hot Honey'],
      spicyLevel: 3,
    ),
    const FoodItem(
      id: 'f6',
      name: 'Avocado Green Goddess Crunch',
      category: 'Healthy & Salads',
      description: 'Crisp baby gem lettuce, massaged kale, shaved rainbow carrots, pumpkin seeds, crumbled feta cheese, and velvety herb green goddess avocado dressing.',
      price: 249.00,
      rating: 4.6,
      reviewCount: 180,
      deliveryTime: '10-15 min',
      calories: 380,
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=700&auto=format&fit=crop&q=80',
      ingredients: ['Baby Gem Lettuce', 'Tuscan Kale', 'Avocado', 'Pepitas', 'Greek Feta', 'Herb Dressing'],
      isVegetarian: true,
    ),
    const FoodItem(
      id: 'f7',
      name: 'Molten Belgian Chocolate Lava Cake',
      category: 'Desserts',
      description: 'Warm, rich Valrhona dark chocolate cake with a luscious flowing molten center, dusted with Dutch cocoa and served with Madagascar vanilla gelato.',
      price: 199.00,
      rating: 4.9,
      reviewCount: 520,
      deliveryTime: '15-20 min',
      calories: 520,
      imageUrl: 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=700&auto=format&fit=crop&q=80',
      isPopular: true,
      isChefSpecial: true,
      ingredients: ['Valrhona Chocolate', 'Pure Butter', 'Free-range Eggs', 'Madagascar Vanilla Bean', 'Sea Salt'],
      isVegetarian: true,
    ),
    const FoodItem(
      id: 'f8',
      name: 'Classic Matcha Latte & Cold Foam',
      category: 'Beverages',
      description: 'Ceremonial grade Uji matcha whisked with creamy oat milk and crowned with a velvety vanilla sweet cold foam layer.',
      price: 149.00,
      rating: 4.8,
      reviewCount: 310,
      deliveryTime: '10-15 min',
      calories: 190,
      imageUrl: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=700&auto=format&fit=crop&q=80',
      ingredients: ['Uji Matcha', 'Barista Oat Milk', 'Pure Agave', 'Vanilla Foam'],
      isVegetarian: true,
    ),
    const FoodItem(
      id: 'f9',
      name: 'Classic Double Cheeseburger',
      category: 'Burgers',
      description: 'Two smashed beef patties, double melted American cheese, dill pickles, diced onions, and signature secret shack sauce on a pillowy potato roll.',
      price: 269.00,
      rating: 4.7,
      reviewCount: 410,
      deliveryTime: '15-20 min',
      calories: 720,
      imageUrl: 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=700&auto=format&fit=crop&q=80',
      ingredients: ['Smashed Beef Patties', 'American Cheese', 'Dill Pickles', 'Sweet Relish', 'Shack Sauce'],
      spicyLevel: 0,
    ),
  ];

  static const UserProfile defaultUser = UserProfile(
    id: 'u_101',
    fullName: 'Alex Vance',
    email: 'alex.vance@example.com',
    phoneNumber: '+91 98765 43210',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
    membershipTier: 'Gold Gourmet Member ⭐',
    totalOrders: 24,
    savedFavoritesCount: 8,
    loyaltyPoints: 580,
    walletBalance: 850.00,
    address: '742 Park Street, Indiranagar, Bengaluru',
    preferredPayment: 'UPI / GPay •••• 9210',
  );
}
