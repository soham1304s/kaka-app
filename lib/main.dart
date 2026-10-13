import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/food_repository.dart';
import 'data/services/api_service.dart';
import 'ui/features/intro/intro_view.dart';
import 'ui/theme/app_theme.dart';
import 'ui/view_models/auth_view_model.dart';
import 'ui/view_models/cart_view_model.dart';
import 'ui/view_models/food_view_model.dart';
import 'ui/view_models/theme_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final apiService = ApiService();
  final foodRepository = FoodRepository(apiService: apiService);
  final authRepository = AuthRepository(apiService: apiService);

  final foodViewModel = FoodViewModel(repository: foodRepository);
  final authViewModel = AuthViewModel(repository: authRepository);
  final cartViewModel = CartViewModel();
  final themeViewModel = ThemeViewModel();

  runApp(
    KakaFoodApp(
      foodViewModel: foodViewModel,
      authViewModel: authViewModel,
      cartViewModel: cartViewModel,
      themeViewModel: themeViewModel,
    ),
  );
}

class KakaFoodApp extends StatelessWidget {
  final FoodViewModel foodViewModel;
  final AuthViewModel authViewModel;
  final CartViewModel cartViewModel;
  final ThemeViewModel themeViewModel;

  const KakaFoodApp({
    super.key,
    required this.foodViewModel,
    required this.authViewModel,
    required this.cartViewModel,
    required this.themeViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeViewModel,
      builder: (context, _) {
        return MaterialApp(
          title: 'Kaka Food',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeViewModel.themeMode,
          home: IntroView(
            foodViewModel: foodViewModel,
            authViewModel: authViewModel,
            cartViewModel: cartViewModel,
            themeViewModel: themeViewModel,
          ),
        );
      },
    );
  }
}
