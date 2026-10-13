import '../../domain/models/food_item.dart';
import '../dummy_data.dart';
import '../services/api_service.dart';

class FoodRepository {
  final ApiService? apiService;
  List<FoodItem> _items;
  List<String> _categories;
  List<PromoBannerData> _promos;

  FoodRepository({this.apiService})
      : _items = List.from(DummyData.foodItems),
        _categories = List.from(DummyData.categories),
        _promos = List.from(DummyData.promoBanners);

  List<FoodItem> getAllItems() => List.unmodifiable(_items);

  List<String> getCategories() => List.unmodifiable(_categories);

  List<PromoBannerData> getPromoBanners() => List.unmodifiable(_promos);

  // Sync fresh menu and categories directly from backend database
  Future<bool> refreshFromBackend() async {
    if (apiService == null) return false;
    try {
      final remoteItems = await apiService!.getFoodItems();
      if (remoteItems.isNotEmpty) {
        _items = remoteItems;
      }

      final remoteCats = await apiService!.getCategories();
      if (remoteCats.isNotEmpty) {
        _categories = remoteCats;
      }

      final remotePromos = await apiService!.getPromoBanners();
      if (remotePromos.isNotEmpty) {
        _promos = remotePromos;
      }

      return true;
    } catch (_) {
      // In offline or testing mode, gracefully preserve in-memory/cached items
      return false;
    }
  }

  List<FoodItem> filterItems({
    String category = 'All',
    String searchQuery = '',
    String sortBy = 'Popular',
  }) {
    var result = _items.where((item) {
      final matchesCategory = category == 'All' || item.category == category;
      final matchesQuery = searchQuery.isEmpty ||
          item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    switch (sortBy) {
      case 'Rating':
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Price: Low to High':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Fastest Delivery':
        result.sort((a, b) => a.deliveryTime.compareTo(b.deliveryTime));
        break;
      case 'Popular':
      default:
        result.sort((a, b) => (b.isPopular ? 1 : 0).compareTo(a.isPopular ? 1 : 0));
        break;
    }

    return result;
  }
}
