import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaka_app/data/repositories/auth_repository.dart';
import 'package:kaka_app/data/repositories/food_repository.dart';
import 'package:kaka_app/main.dart';
import 'package:kaka_app/ui/view_models/auth_view_model.dart';
import 'package:kaka_app/ui/view_models/cart_view_model.dart';
import 'package:kaka_app/ui/view_models/food_view_model.dart';
import 'package:kaka_app/ui/view_models/theme_view_model.dart';

// Test HttpOverrides to safely swallow network image loads in test environment
class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _FakeHttpClient();
  }
}

class _FakeHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;

  @override
  void addCredentials(Uri url, String realm, HttpClientCredentials credentials) {}
  @override
  void addProxyCredentials(String host, int port, String realm, HttpClientCredentials credentials) {}
  @override
  set authenticate(Future<bool> Function(Uri url, String scheme, String? realm)? f) {}
  @override
  set authenticateProxy(Future<bool> Function(String host, int port, String scheme, String? realm)? f) {}
  @override
  set badCertificateCallback(bool Function(X509Certificate cert, String host, int port)? callback) {}
  @override
  set findProxy(String Function(Uri url)? f) {}
  @override
  void close({bool force = false}) {}

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest();
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _FakeHttpClientRequest();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  static final List<int> _kTransparentImage = <int>[
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
    0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
    0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
    0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
    0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
    0x60, 0x82,
  ];

  @override
  int get statusCode => 200;
  @override
  int get contentLength => _kTransparentImage.length;
  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.fromIterable([_kTransparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  testWidgets('KakaFoodApp launches with intro animation and navigates to auth and dashboard', (WidgetTester tester) async {
    // Set a phone screen resolution
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    final foodRepository = FoodRepository();
    final authRepository = AuthRepository();

    final foodViewModel = FoodViewModel(repository: foodRepository);
    final authViewModel = AuthViewModel(repository: authRepository);
    final cartViewModel = CartViewModel();
    final themeViewModel = ThemeViewModel();

    await tester.pumpWidget(
      KakaFoodApp(
        foodViewModel: foodViewModel,
        authViewModel: authViewModel,
        cartViewModel: cartViewModel,
        themeViewModel: themeViewModel,
      ),
    );

    // Initial pump for IntroView to let entrance animation finish
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1500));

    // 1. Verify Intro Screen elements
    expect(find.text('Kaka Food'), findsWidgets);
    expect(find.text('Artisanal Flavors • Instant Hot Delivery'), findsOneWidget);
    expect(find.text('Under 25 Mins'), findsOneWidget);
    expect(find.text('Skip to App'), findsOneWidget);
    expect(find.text('Continue to Sign In'), findsOneWidget);

    // 2. Navigate to AuthPage
    await tester.tap(find.text('Continue to Sign In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify AuthPage rendered with Sign In tab
    expect(find.text('Sign In to Kaka Food'), findsOneWidget);
    expect(find.text('1-Tap Demo Login (Chef Alex)'), findsOneWidget);

    // 3. Switch to Create Account tab on AuthPage
    await tester.tap(find.text('Create Account'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verify Create Account elements
    expect(find.text('Join Kaka Foodies Club'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Create Account & Get ₹150'), findsOneWidget);

    // 4. Switch back to Sign In tab and login with Demo account
    await tester.tap(find.text('Sign In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('1-Tap Demo Login (Chef Alex)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify MainScreen Dashboard loaded
    expect(find.text('DELIVER TO'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Burgers'), findsOneWidget);

    // 5. Navigate to Profile Tab
    await tester.tap(find.text('Profile'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Alex Vance'), findsWidgets);
    expect(find.text('Orders Placed'), findsOneWidget);
    expect(find.text('Loyalty Points'), findsOneWidget);

    // 6. Switch back to Explore Tab
    await tester.tap(find.text('Explore'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('DELIVER TO'), findsOneWidget);
  });

  testWidgets('IntroView Skip to App button navigates directly to Dashboard as Guest', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    final foodRepository = FoodRepository();
    final authRepository = AuthRepository();

    final foodViewModel = FoodViewModel(repository: foodRepository);
    final authViewModel = AuthViewModel(repository: authRepository);
    final cartViewModel = CartViewModel();
    final themeViewModel = ThemeViewModel();

    await tester.pumpWidget(
      KakaFoodApp(
        foodViewModel: foodViewModel,
        authViewModel: authViewModel,
        cartViewModel: cartViewModel,
        themeViewModel: themeViewModel,
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Tap Skip to App
    expect(find.text('Skip to App'), findsOneWidget);
    await tester.tap(find.text('Skip to App'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify directly on Dashboard
    expect(find.text('DELIVER TO'), findsOneWidget);
    expect(find.text('Burgers'), findsOneWidget);
  });

  testWidgets('IntroView renders with orange background and new animation on compact mobile screens', (WidgetTester tester) async {
    // Small mobile screen (e.g. 360 x 640 logical pixels)
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final foodRepository = FoodRepository();
    final authRepository = AuthRepository();

    final foodViewModel = FoodViewModel(repository: foodRepository);
    final authViewModel = AuthViewModel(repository: authRepository);
    final cartViewModel = CartViewModel();
    final themeViewModel = ThemeViewModel();

    await tester.pumpWidget(
      KakaFoodApp(
        foodViewModel: foodViewModel,
        authViewModel: authViewModel,
        cartViewModel: cartViewModel,
        themeViewModel: themeViewModel,
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));

    expect(find.text('Kaka Food'), findsWidgets);
    expect(find.text('Hot & Fresh'), findsOneWidget);
    expect(find.text('Under 25 Mins'), findsOneWidget);
    expect(find.text('Continue to Sign In'), findsOneWidget);
    expect(find.text('Skip to App'), findsOneWidget);
  });
}
