import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/cart_view_model.dart';
import '../../view_models/food_view_model.dart';
import '../../view_models/theme_view_model.dart';
import '../auth/auth_page.dart';
import '../../main_screen.dart';

class IntroView extends StatefulWidget {
  final FoodViewModel foodViewModel;
  final AuthViewModel authViewModel;
  final CartViewModel cartViewModel;
  final ThemeViewModel themeViewModel;

  const IntroView({
    super.key,
    required this.foodViewModel,
    required this.authViewModel,
    required this.cartViewModel,
    required this.themeViewModel,
  });

  @override
  State<IntroView> createState() => _IntroViewState();
}

class _IntroViewState extends State<IntroView> with TickerProviderStateMixin {
  // 1. Entrance controller for initial staggered appearance
  late final AnimationController _entranceController;

  // 2. Ripple waves controller radiating from center
  late final AnimationController _rippleController;

  // 3. Floating ambient controller for hovering culinary badges
  late final AnimationController _floatingController;

  // 4. Rotating aura halo
  late final AnimationController _haloController;

  // Animations
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _badgesFade;
  late final Animation<double> _buttonsFade;

  Timer? _autoTransitionTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // Entrance animation (1000ms)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Continuous ripple wave animation
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // Continuous gentle floating oscillation for badges
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // Continuous slow halo rotation
    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    )..repeat();

    // Logo pop-in
    _logoScale = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.65, curve: Curves.elasticOut),
    );
    _logoFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
    );

    // Title slide & fade
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _titleFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 0.7, curve: Curves.easeIn),
    );

    // Badges scale
    _badgesFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.55, 0.9, curve: Curves.easeOutBack),
    );

    // Buttons fade
    _buttonsFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    );

    _entranceController.forward();

    // Automatic transition to AuthPage after intro animation plays (2.5s)
    _autoTransitionTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted && !_hasNavigated) {
        _navigateToAuth();
      }
    });
  }

  @override
  void dispose() {
    _autoTransitionTimer?.cancel();
    _entranceController.dispose();
    _rippleController.dispose();
    _floatingController.dispose();
    _haloController.dispose();
    super.dispose();
  }

  void _navigateToAuth({bool isSignUp = false}) {
    if (_hasNavigated) return;
    _hasNavigated = true;
    _autoTransitionTimer?.cancel();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => AuthPage(
          authViewModel: widget.authViewModel,
          foodViewModel: widget.foodViewModel,
          cartViewModel: widget.cartViewModel,
          themeViewModel: widget.themeViewModel,
          initialIsSignUp: isSignUp,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToMain() {
    if (_hasNavigated) return;
    _hasNavigated = true;
    _autoTransitionTimer?.cancel();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => MainScreen(
          foodViewModel: widget.foodViewModel,
          authViewModel: widget.authViewModel,
          cartViewModel: widget.cartViewModel,
          themeViewModel: widget.themeViewModel,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Fully rich, vibrant orange background gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF3E00), // Vibrant fiery orange
              Color(0xFFFF5722), // Deep food-grade warm orange
              Color(0xFFFF6D00), // Bright amber orange
              Color(0xFFFF7A00), // Luscious glowing orange
            ],
            stops: [0.0, 0.35, 0.75, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 1. Concentric Expanding Ripple Waves Animation (centered on logo)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _rippleController,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _RippleWavePainter(
                          progress: _rippleController.value,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 2. Ambient Floating Decorative Food Motes
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _floatingController,
                    builder: (context, _) {
                      final val = _floatingController.value;
                      return Stack(
                        children: [
                          // Top-left floating spark/bubble
                          Positioned(
                            top: size.height * 0.12 + math.sin(val * math.pi) * 12,
                            left: 28,
                            child: _buildGlowingMote(size: 14, opacity: 0.25),
                          ),
                          // Top-right floating spark/bubble
                          Positioned(
                            top: size.height * 0.18 + math.cos(val * math.pi) * 15,
                            right: 36,
                            child: _buildGlowingMote(size: 20, opacity: 0.30),
                          ),
                          // Bottom-left floating spark
                          Positioned(
                            bottom: size.height * 0.22 + math.sin(val * math.pi * 1.5) * 10,
                            left: 42,
                            child: _buildGlowingMote(size: 16, opacity: 0.22),
                          ),
                          // Bottom-right floating spark
                          Positioned(
                            bottom: size.height * 0.28 + math.cos(val * math.pi * 1.2) * 14,
                            right: 30,
                            child: _buildGlowingMote(size: 24, opacity: 0.28),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // 3. Top Action Bar with Frosted Glass "Skip to App"
              Positioned(
                top: 14,
                right: 18,
                child: FadeTransition(
                  opacity: _buttonsFade,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(45),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withAlpha(90),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _navigateToMain,
                        borderRadius: BorderRadius.circular(22),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Skip to App',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Main Animated Interactive Center Content
              Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Dynamic Floating Badges + Hero Logo Cluster
                        SizedBox(
                          width: 280,
                          height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Central Rotating Halo Aura
                              AnimatedBuilder(
                                animation: _haloController,
                                builder: (context, _) {
                                  return Transform.rotate(
                                    angle: _haloController.value * 2 * math.pi,
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: SweepGradient(
                                          colors: [
                                            Colors.white.withAlpha(90),
                                            Colors.amber.shade200.withAlpha(40),
                                            Colors.white.withAlpha(120),
                                            Colors.white.withAlpha(30),
                                            Colors.white.withAlpha(90),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Central Hero Logo Emblem
                              FadeTransition(
                                opacity: _logoFade,
                                child: ScaleTransition(
                                  scale: _logoScale,
                                  child: Container(
                                    width: 108,
                                    height: 108,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(45),
                                          blurRadius: 28,
                                          offset: const Offset(0, 10),
                                        ),
                                        BoxShadow(
                                          color: const Color(0xFFFF3D00).withAlpha(100),
                                          blurRadius: 18,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Subtle inner decorative ring
                                        Container(
                                          width: 92,
                                          height: 92,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFFFF5722).withAlpha(30),
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                        // Hero Chef Burger Icon in Rich Orange
                                        const Icon(
                                          Icons.lunch_dining_rounded,
                                          size: 54,
                                          color: Color(0xFFFF3E00),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Floating Culinary Badge 1: Top-Left (Hot & Fresh)
                              AnimatedBuilder(
                                animation: _floatingController,
                                builder: (context, _) {
                                  final offset = math.sin((_floatingController.value * 2 * math.pi)) * 6;
                                  return Positioned(
                                    top: 14 + offset,
                                    left: 4,
                                    child: FadeTransition(
                                      opacity: _badgesFade,
                                      child: _buildFloatingBadge(
                                        icon: Icons.local_fire_department_rounded,
                                        label: 'Hot & Fresh',
                                        iconColor: const Color(0xFFFFD54F),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Floating Culinary Badge 2: Top-Right (Under 25 Mins)
                              AnimatedBuilder(
                                animation: _floatingController,
                                builder: (context, _) {
                                  final offset = math.cos((_floatingController.value * 2 * math.pi)) * 6;
                                  return Positioned(
                                    top: 18 + offset,
                                    right: 4,
                                    child: FadeTransition(
                                      opacity: _badgesFade,
                                      child: _buildFloatingBadge(
                                        icon: Icons.bolt_rounded,
                                        label: 'Under 25 Mins',
                                        iconColor: const Color(0xFFFFE082),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Floating Culinary Badge 3: Bottom-Left (4.9 Rating)
                              AnimatedBuilder(
                                animation: _floatingController,
                                builder: (context, _) {
                                  final offset = math.cos((_floatingController.value * 2 * math.pi) + 1) * 6;
                                  return Positioned(
                                    bottom: 12 + offset,
                                    left: 12,
                                    child: FadeTransition(
                                      opacity: _badgesFade,
                                      child: _buildFloatingBadge(
                                        icon: Icons.star_rounded,
                                        label: '4.9 Rated',
                                        iconColor: const Color(0xFFFFD700),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Floating Culinary Badge 4: Bottom-Right (₹150 OFF)
                              AnimatedBuilder(
                                animation: _floatingController,
                                builder: (context, _) {
                                  final offset = math.sin((_floatingController.value * 2 * math.pi) + 1) * 6;
                                  return Positioned(
                                    bottom: 10 + offset,
                                    right: 12,
                                    child: FadeTransition(
                                      opacity: _badgesFade,
                                      child: _buildFloatingBadge(
                                        icon: Icons.confirmation_number_rounded,
                                        label: '₹150 OFF',
                                        iconColor: const Color(0xFFB9F6CA),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Animated Brand Title & Tagline in High-Contrast White
                        FadeTransition(
                          opacity: _titleFade,
                          child: SlideTransition(
                            position: _titleSlide,
                            child: Column(
                              children: [
                                // Brand Name in Crisp Bold White
                                const Text(
                                  'Kaka Food',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.8,
                                    height: 1.1,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 6),

                                // Tagline in Warm Cream
                                const Text(
                                  'Artisanal Flavors • Instant Hot Delivery',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFFF3E0),
                                    letterSpacing: 0.2,
                                  ),
                                ),

                                const SizedBox(height: 22),

                                // Animated Dish Preparation Indicator
                                AnimatedBuilder(
                                  animation: _rippleController,
                                  builder: (context, _) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(35),
                                        borderRadius: BorderRadius.circular(22),
                                        border: Border.all(
                                          color: Colors.white.withAlpha(70),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 13,
                                            height: 13,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1.8,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          ),
                                          SizedBox(width: 7),
                                          Text(
                                            'Fresh menu ready...',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: 0.1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Action Buttons in Pristine Contrast
                        FadeTransition(
                          opacity: _buttonsFade,
                          child: Column(
                            children: [
                              // Hero Solid White Button with Vibrant Orange Text
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: () => _navigateToAuth(isSignUp: false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFFFF3E00),
                                    elevation: 6,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    shadowColor: Colors.black.withAlpha(70),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Continue to Sign In',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18,
                                        color: Color(0xFFFF3E00),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Secondary Action: Create Account
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(30),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withAlpha(60),
                                    width: 1,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _navigateToAuth(isSignUp: true),
                                    borderRadius: BorderRadius.circular(14),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            'New here? ',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              color: Color(0xFFFFF3E0),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'Create Account',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              decoration: TextDecoration.underline,
                                              decorationColor: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Floating culinary badge chip
  Widget _buildFloatingBadge({
    required IconData icon,
    required String label,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withAlpha(95),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  // Soft glowing ambient mote
  Widget _buildGlowingMote({required double size, required double opacity}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: opacity * 0.8),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Concentric Glowing Ripple Waves radiating from center
class _RippleWavePainter extends CustomPainter {
  final double progress;

  _RippleWavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.38);
    final maxRadius = size.width * 0.65;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw 3 staggered expanding wave rings
    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress + (i / 3.0)) % 1.0;
      final radius = 55 + (ringProgress * maxRadius);
      final alpha = ((1.0 - ringProgress) * 70).clamp(0, 70).toInt();

      paint.color = Colors.white.withAlpha(alpha);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RippleWavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
