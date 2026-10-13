import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../domain/models/food_item.dart';
import '../../domain/models/user_profile.dart';
import '../dummy_data.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client;
  String? _token;

  ApiService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? _resolveDefaultBaseUrl(),
        _client = client ?? http.Client();

  static String _resolveDefaultBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    try {
      if (Platform.isAndroid) {
        // 10.0.2.2 maps to host machine localhost in standard Android emulator
        return 'http://10.0.2.2:5000';
      }
    } catch (_) {
      // Fallback
    }
    return 'http://127.0.0.1:5000';
  }

  String? get token => _token;
  void setToken(String? token) => _token = token;

  Map<String, String> _headers({bool requiresAuth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requiresAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // 1. Health check
  Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse('$baseUrl/api/health');
      final res = await _client.get(uri).timeout(const Duration(milliseconds: 1500));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // 2. Fetch all food items with optional filtering and sorting
  Future<List<FoodItem>> getFoodItems({
    String category = 'All',
    String searchQuery = '',
    String sortBy = 'Popular',
  }) async {
    final queryParams = <String, String>{};
    if (category != 'All') queryParams['category'] = category;
    if (searchQuery.isNotEmpty) queryParams['search'] = searchQuery;
    if (sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;

    final uri = Uri.parse('$baseUrl/api/food').replace(queryParameters: queryParams);
    final response = await _client
        .get(uri, headers: _headers())
        .timeout(const Duration(seconds: 4));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final list = decoded['data'] as List<dynamic>? ?? [];
      return list.map((e) => FoodItem.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load food menu: ${response.statusCode}');
    }
  }

  // 3. Fetch categories
  Future<List<String>> getCategories() async {
    final uri = Uri.parse('$baseUrl/api/food/categories');
    final response = await _client
        .get(uri, headers: _headers())
        .timeout(const Duration(seconds: 4));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final list = decoded['data'] as List<dynamic>? ?? [];
      return list.map((e) => e.toString()).toList();
    } else {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  }

  // 4. Fetch promo banners
  Future<List<PromoBannerData>> getPromoBanners() async {
    final uri = Uri.parse('$baseUrl/api/food/promos');
    final response = await _client
        .get(uri, headers: _headers())
        .timeout(const Duration(seconds: 4));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final list = decoded['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => PromoBannerData.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load promo banners: ${response.statusCode}');
    }
  }

  // 5. User login
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth/login');
    final response = await _client
        .post(
          uri,
          headers: _headers(),
          body: json.encode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 4));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>;
      _token = data['token'] as String?;
      return UserProfile.fromJson(data['user'] as Map<String, dynamic>);
    } else {
      final decoded = json.decode(response.body) as Map<String, dynamic>?;
      final errorMsg = decoded?['error']?['message'] ?? 'Authentication failed';
      throw Exception(errorMsg);
    }
  }

  // 6. User signup
  Future<UserProfile> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth/register');
    final response = await _client
        .post(
          uri,
          headers: _headers(),
          body: json.encode({
            'name': name,
            'email': email,
            'phone': phone,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 4));

    if (response.statusCode == 201) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>;
      _token = data['token'] as String?;
      return UserProfile.fromJson(data['user'] as Map<String, dynamic>);
    } else {
      final decoded = json.decode(response.body) as Map<String, dynamic>?;
      final errorMsg = decoded?['error']?['message'] ?? 'Registration failed';
      throw Exception(errorMsg);
    }
  }

  // 7. Demo login
  Future<UserProfile> demoLogin() async {
    final uri = Uri.parse('$baseUrl/api/auth/demo');
    final response = await _client
        .post(uri, headers: _headers())
        .timeout(const Duration(seconds: 4));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>;
      _token = data['token'] as String?;
      return UserProfile.fromJson(data['user'] as Map<String, dynamic>);
    } else {
      throw Exception('Failed demo login');
    }
  }

  // 8. Update profile
  Future<UserProfile> updateProfile(UserProfile profile) async {
    final uri = Uri.parse('$baseUrl/api/auth/profile');
    final response = await _client
        .put(
          uri,
          headers: _headers(requiresAuth: true),
          body: json.encode(profile.toJson()),
        )
        .timeout(const Duration(seconds: 4));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>;
      return UserProfile.fromJson(data['user'] as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update profile');
    }
  }

  // 9. Place order
  Future<Map<String, dynamic>> placeOrder({
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    required String paymentMethod,
    double discountAmount = 0.0,
  }) async {
    final uri = Uri.parse('$baseUrl/api/orders');
    final response = await _client
        .post(
          uri,
          headers: _headers(requiresAuth: true),
          body: json.encode({
            'items': items,
            'deliveryAddress': deliveryAddress,
            'paymentMethod': paymentMethod,
            'discountAmount': discountAmount,
          }),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 201) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      return decoded['data'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to place order');
    }
  }
}
