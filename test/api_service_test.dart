import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kaka_app/data/repositories/auth_repository.dart';
import 'package:kaka_app/data/repositories/food_repository.dart';
import 'package:kaka_app/data/services/api_service.dart';

void main() {
  group('ApiService & Repositories Backend Integration', () {
    test('ApiService successfully deserializes food items from backend JSON', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/food') {
          return http.Response(
            json.encode({
              'success': true,
              'count': 1,
              'data': [
                {
                  'id': 'f1',
                  'name': 'Double Truffle Smash Burger',
                  'category': 'Burgers',
                  'description': 'Aged Angus patties with black truffle glaze',
                  'price': 399.0,
                  'rating': 4.9,
                  'reviewCount': 320,
                  'deliveryTime': '20-25 min',
                  'calories': 680,
                  'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd',
                  'isPopular': true,
                  'isChefSpecial': true,
                  'ingredients': ['Angus Beef', 'Truffle Butter', 'Brioche'],
                  'spicyLevel': 1,
                  'isVegetarian': false,
                }
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiService = ApiService(baseUrl: 'http://127.0.0.1:5000', client: mockClient);
      final items = await apiService.getFoodItems();

      expect(items.length, 1);
      expect(items.first.name, 'Double Truffle Smash Burger');
      expect(items.first.price, 399.0);
      expect(items.first.isPopular, isTrue);
    });

    test('ApiService successfully handles login and sets JWT token', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/auth/login') {
          return http.Response(
            json.encode({
              'success': true,
              'data': {
                'token': 'mock_jwt_token_123',
                'user': {
                  'id': 'usr_1',
                  'fullName': 'Alex Vance',
                  'email': 'chef.alex@kakafood.com',
                  'phoneNumber': '+91 98765 43210',
                  'avatarUrl': 'https://example.com/avatar.jpg',
                  'membershipTier': 'Gold Gourmet Member ⭐',
                  'totalOrders': 6,
                  'savedFavoritesCount': 4,
                  'loyaltyPoints': 240,
                  'walletBalance': 150.0,
                  'address': '221B Baker Street',
                  'preferredPayment': 'UPI •••• 9210',
                },
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiService = ApiService(baseUrl: 'http://127.0.0.1:5000', client: mockClient);
      final user = await apiService.login(email: 'chef.alex@kakafood.com', password: 'password123');

      expect(apiService.token, 'mock_jwt_token_123');
      expect(user.fullName, 'Alex Vance');
      expect(user.walletBalance, 150.0);
    });

    test('FoodRepository refreshFromBackend seamlessly updates items', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/food') {
          return http.Response(
            json.encode({
              'success': true,
              'data': [
                {
                  'id': 'f99',
                  'name': 'Special Gourmet Biryani',
                  'category': 'Asian & Bowls',
                  'description': 'Dum cooked saffron basmati rice with spices',
                  'price': 499.0,
                  'rating': 5.0,
                  'reviewCount': 50,
                  'deliveryTime': '30 min',
                  'calories': 700,
                  'imageUrl': 'https://example.com/biryani.jpg',
                  'isPopular': true,
                  'isChefSpecial': true,
                  'ingredients': ['Basmati Rice', 'Saffron', 'Spices'],
                  'spicyLevel': 2,
                  'isVegetarian': true,
                }
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/api/food/categories') {
          return http.Response(
            json.encode({'success': true, 'data': ['All', 'Burgers', 'Asian & Bowls']}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/api/food/promos') {
          return http.Response(
            json.encode({'success': true, 'data': []}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiService = ApiService(baseUrl: 'http://127.0.0.1:5000', client: mockClient);
      final repo = FoodRepository(apiService: apiService);

      final synced = await repo.refreshFromBackend();
      expect(synced, isTrue);
      expect(repo.getAllItems().length, 1);
      expect(repo.getAllItems().first.name, 'Special Gourmet Biryani');
    });

    test('AuthRepository login seamlessly sets currentUser with backend response', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/auth/login') {
          return http.Response(
            json.encode({
              'success': true,
              'data': {
                'token': 'jwt_token_xyz',
                'user': {
                  'id': 'usr_99',
                  'fullName': 'Soham User',
                  'email': 'soham@kakafood.com',
                  'phoneNumber': '+91 99999 88888',
                  'avatarUrl': '',
                  'membershipTier': 'Platinum Foodie ⭐',
                  'totalOrders': 12,
                  'savedFavoritesCount': 5,
                  'loyaltyPoints': 500,
                  'walletBalance': 300.0,
                  'address': 'Kolkata, India',
                  'preferredPayment': 'UPI',
                },
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiService = ApiService(baseUrl: 'http://127.0.0.1:5000', client: mockClient);
      final authRepo = AuthRepository(apiService: apiService);

      final user = await authRepo.login(email: 'soham@kakafood.com', password: 'password123');
      expect(user.fullName, 'Soham User');
      expect(authRepo.currentUser?.email, 'soham@kakafood.com');
      expect(authRepo.isAuthenticated, isTrue);
    });
  });
}
