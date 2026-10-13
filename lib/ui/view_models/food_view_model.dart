import 'package:flutter/foundation.dart';
import '../../data/dummy_data.dart';
import '../../data/repositories/food_repository.dart';
import '../../domain/models/food_item.dart';

class FoodViewModel extends ChangeNotifier {
  final FoodRepository repository;

  FoodViewModel({required this.repository}) {
    _loadData();
  }

  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _sortBy = 'Popular';
  final Set<String> _favoriteIds = {'f1', 'f3', 'f7'};

  List<FoodItem> _filteredItems = [];
  List<PromoBannerData> _promoBanners = [];
  List<String> _categories = [];

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  Set<String> get favoriteIds => _favoriteIds;
  List<FoodItem> get filteredItems => _filteredItems;
  List<PromoBannerData> get promoBanners => _promoBanners;
  List<String> get categories => _categories;

  bool isFavorite(String foodId) => _favoriteIds.contains(foodId);

  void _loadData() {
    _categories = repository.getCategories();
    _promoBanners = repository.getPromoBanners();
    _applyFilters();

    repository.refreshFromBackend().then((synced) {
      if (synced) {
        _categories = repository.getCategories();
        _promoBanners = repository.getPromoBanners();
        _applyFilters();
      }
    });
  }

  void _applyFilters() {
    _filteredItems = repository.filterItems(
      category: _selectedCategory,
      searchQuery: _searchQuery,
      sortBy: _sortBy,
    );
    notifyListeners();
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    _applyFilters();
  }

  void toggleFavorite(String foodId) {
    if (_favoriteIds.contains(foodId)) {
      _favoriteIds.remove(foodId);
    } else {
      _favoriteIds.add(foodId);
    }
    notifyListeners();
  }
}
