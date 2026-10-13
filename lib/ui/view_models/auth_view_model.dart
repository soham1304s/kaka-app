import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/models/user_profile.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository repository;

  AuthViewModel({required this.repository});

  UserProfile? get currentUser => repository.currentUser;
  bool get isAuthenticated => repository.isAuthenticated;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Please enter a valid email address.');
      }
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters.');
      }

      await repository.login(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (name.trim().isEmpty) {
        throw Exception('Please enter your full name.');
      }
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Please enter a valid email address.');
      }
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters.');
      }

      await repository.signup(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await repository.logout();
    _isLoading = false;
    notifyListeners();
  }

  void quickDemoLogin() {
    repository.loginDemoUser();
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile updated) async {
    await repository.updateProfile(updated);
    notifyListeners();
  }
}
