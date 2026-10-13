import '../../domain/models/user_profile.dart';
import '../dummy_data.dart';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService? apiService;
  UserProfile? _currentUser = DummyData.defaultUser;

  AuthRepository({this.apiService});

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    if (apiService != null) {
      try {
        final user = await apiService!.login(email: email, password: password);
        _currentUser = user;
        return _currentUser!;
      } catch (_) {
        // Fall back gracefully to local session for offline/demo reliability
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));

    final name = email.split('@').first;
    final formattedName = name.isNotEmpty
        ? name[0].toUpperCase() + name.substring(1)
        : 'Gourmet User';

    _currentUser = UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      fullName: formattedName,
      email: email,
      phoneNumber: '+91 98765 01928',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
      membershipTier: 'Gold Gourmet Member ⭐',
      totalOrders: 6,
      savedFavoritesCount: 4,
      loyaltyPoints: 240,
      walletBalance: 150.00,
      address: '221B Baker Street, Suite 4',
      preferredPayment: 'UPI •••• 9210',
    );

    return _currentUser!;
  }

  Future<UserProfile> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (apiService != null) {
      try {
        final user = await apiService!.signup(
          name: name,
          email: email,
          phone: phone,
          password: password,
        );
        _currentUser = user;
        return _currentUser!;
      } catch (_) {
        // Fall back gracefully for offline resilience
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));

    _currentUser = UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      fullName: name,
      email: email,
      phoneNumber: phone.isNotEmpty ? phone : '+91 98765 12345',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&auto=format&fit=crop&q=80',
      membershipTier: 'Welcome Foodie ⭐',
      totalOrders: 0,
      savedFavoritesCount: 0,
      loyaltyPoints: 100, // Sign up bonus
      walletBalance: 150.00, // ₹150 Welcome credit
      address: 'Add your primary delivery address',
      preferredPayment: 'UPI / Google Pay',
    );

    return _currentUser!;
  }

  Future<void> logout() async {
    apiService?.setToken(null);
    _currentUser = null;
  }

  void loginDemoUser() {
    if (apiService != null) {
      apiService!.demoLogin().then((user) {
        _currentUser = user;
      }).catchError((_) {
        _currentUser = DummyData.defaultUser;
      });
    }
    _currentUser = DummyData.defaultUser;
  }

  Future<UserProfile> updateProfile(UserProfile updated) async {
    if (apiService != null) {
      try {
        final user = await apiService!.updateProfile(updated);
        _currentUser = user;
        return _currentUser!;
      } catch (_) {
        // Fall back to local update
      }
    }

    _currentUser = updated;
    return _currentUser!;
  }
}
