import 'package:flutter/material.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/cart_view_model.dart';
import '../../view_models/food_view_model.dart';
import '../../view_models/theme_view_model.dart';
import '../../main_screen.dart';

class AuthPage extends StatefulWidget {
  final AuthViewModel authViewModel;
  final FoodViewModel foodViewModel;
  final CartViewModel cartViewModel;
  final ThemeViewModel themeViewModel;
  final bool initialIsSignUp;

  const AuthPage({
    super.key,
    required this.authViewModel,
    required this.foodViewModel,
    required this.cartViewModel,
    required this.themeViewModel,
    this.initialIsSignUp = false,
  });

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late bool _isSignUp;
  late final TabController _tabController;

  // Sign In controllers
  final _signInEmailController = TextEditingController(text: 'alex.vance@example.com');
  final _signInPasswordController = TextEditingController(text: 'secret123');
  bool _signInObscurePassword = true;
  bool _rememberMe = true;

  // Sign Up controllers
  final _signUpNameController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPhoneController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  bool _signUpObscurePassword = true;
  bool _agreedToTerms = true;

  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialIsSignUp;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _isSignUp ? 1 : 0,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && _tabController.index != (_isSignUp ? 1 : 0)) {
        setState(() {
          _isSignUp = _tabController.index == 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPhoneController.dispose();
    _signUpPasswordController.dispose();
    super.dispose();
  }

  void _onSuccessNavigate(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, anim, secAnim) => MainScreen(
            foodViewModel: widget.foodViewModel,
            authViewModel: widget.authViewModel,
            cartViewModel: widget.cartViewModel,
            themeViewModel: widget.themeViewModel,
          ),
          transitionsBuilder: (context, anim, secAnim, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  Future<void> _handleSignIn() async {
    if (!_signInFormKey.currentState!.validate()) return;

    final success = await widget.authViewModel.login(
      _signInEmailController.text.trim(),
      _signInPasswordController.text,
    );

    if (success && mounted) {
      final name = widget.authViewModel.currentUser?.fullName ?? 'Foodie';
      _onSuccessNavigate('Welcome back, $name! Enjoy ₹150 off your order.');
    }
  }

  Future<void> _handleSignUp() async {
    if (!_signUpFormKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the Terms & Conditions to register.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final success = await widget.authViewModel.signup(
      name: _signUpNameController.text.trim(),
      email: _signUpEmailController.text.trim(),
      phone: _signUpPhoneController.text.trim().isEmpty ? '9876543210' : _signUpPhoneController.text.trim(),
      password: _signUpPasswordController.text,
    );

    if (success && mounted) {
      final name = widget.authViewModel.currentUser?.fullName ?? 'Foodie';
      _onSuccessNavigate('Welcome to Kaka Food, $name! ₹150 coupon unlocked.');
    }
  }

  void _handleQuickDemoLogin() {
    widget.authViewModel.quickDemoLogin();
    _onSuccessNavigate('Logged in as Alex Vance (Verified Chef/Foodie).');
  }

  void _skipToMainScreen() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, anim, secAnim) => MainScreen(
            foodViewModel: widget.foodViewModel,
            authViewModel: widget.authViewModel,
            cartViewModel: widget.cartViewModel,
            themeViewModel: widget.themeViewModel,
          ),
          transitionsBuilder: (context, anim, secAnim, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final resetController = TextEditingController(text: _signInEmailController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4B26).withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_reset_rounded, color: Color(0xFFFF4B26), size: 22),
            ),
            const SizedBox(width: 12),
            const Text('Reset Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your registered email address and we will send a password reset link.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                hintText: 'name@example.com',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  content: Text('Reset link sent to ${resetController.text.trim()}!'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4B26),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              // Header with Back, Brand, and Guest shortcut
              _buildTopBar(isDark),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      // Brand Hero Visual
                      _buildHeroCard(isDark),

                      const SizedBox(height: 18),

                      // Welcome Discount Banner (₹ INR)
                      _buildPromoBanner(isDark),

                      const SizedBox(height: 20),

                      // Animated Segmented Tab Bar (Sign In / Sign Up)
                      _buildTabBar(isDark),

                      const SizedBox(height: 20),

                      // Error Banner if AuthViewModel has error
                      ListenableBuilder(
                        listenable: widget.authViewModel,
                        builder: (context, _) {
                          final err = widget.authViewModel.errorMessage;
                          if (err == null) return const SizedBox.shrink();
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFEF4444).withAlpha(80)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    err,
                                    style: const TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Active Form (Sign In or Sign Up)
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: _isSignUp ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        firstChild: _buildSignInForm(isDark),
                        secondChild: _buildSignUpForm(isDark),
                      ),

                      const SizedBox(height: 20),

                      // Social Logins & Guest Link
                      _buildSocialAndGuestRow(isDark),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button if popped, else App logo
          if (Navigator.of(context).canPop())
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: isDark ? Colors.white70 : const Color(0xFF1E293B),
              ),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
            )
          else
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF4B26), Color(0xFFFF7A45)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.lunch_dining_rounded, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'Kaka Food',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

          // Guest Mode Shortcut
          Flexible(
            child: TextButton.icon(
              onPressed: _skipToMainScreen,
              icon: const Icon(Icons.storefront_outlined, size: 16),
              label: const Text(
                'Skip as Guest',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? const Color(0xFFFF7A45) : const Color(0xFFFF4B26),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [Colors.white, const Color(0xFFFFF7ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(15) : const Color(0xFFFFE0D6),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4B26).withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF4B26), Color(0xFFFF8A00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF4B26).withAlpha(90),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.restaurant_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isSignUp ? 'Join Kaka Foodies Club' : 'Welcome Back Chef!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isSignUp
                      ? 'Sign up to unlock ₹150 credits & express delivery.'
                      : 'Sign in to access your orders, points & favorites.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withAlpha(isDark ? 30 : 20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF10B981).withAlpha(isDark ? 80 : 60),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.confirmation_number_rounded, color: Color(0xFF10B981), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12.5,
                  color: isDark ? Colors.white : const Color(0xFF0F5132),
                ),
                children: const [
                  TextSpan(text: 'Special Offer: '),
                  TextSpan(
                    text: 'Flat ₹150 OFF ',
                    style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                  ),
                  TextSpan(text: 'on your first 3 orders above ₹499!'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: isDark ? const Color(0xFFFF4B26) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF4B26).withAlpha(90),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        labelColor: isDark ? Colors.white : const Color(0xFFFF4B26),
        unselectedLabelColor: isDark ? Colors.white60 : const Color(0xFF64748B),
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        tabs: const [
          Tab(text: 'Sign In'),
          Tab(text: 'Create Account'),
        ],
      ),
    );
  }

  Widget _buildSignInForm(bool isDark) {
    return Form(
      key: _signInFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Field
          _buildInputLabel('Email Address', isDark),
          TextFormField(
            controller: _signInEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration(
              hint: 'alex.vance@example.com',
              icon: Icons.alternate_email_rounded,
              isDark: isDark,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Email is required';
              if (!value.contains('@')) return 'Enter a valid email address';
              return null;
            },
          ),

          const SizedBox(height: 14),

          // Password Field
          _buildInputLabel('Password', isDark),
          TextFormField(
            controller: _signInPasswordController,
            obscureText: _signInObscurePassword,
            decoration: _inputDecoration(
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              isDark: isDark,
              suffixIcon: IconButton(
                icon: Icon(
                  _signInObscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 20,
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                ),
                onPressed: () => setState(() => _signInObscurePassword = !_signInObscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password is required';
              if (value.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),

          const SizedBox(height: 10),

          // Remember Me & Forgot Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        activeColor: const Color(0xFFFF4B26),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        onChanged: (val) => setState(() => _rememberMe = val ?? true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Remember me',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _showForgotPasswordDialog,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF4B26),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Sign In Primary Button
          _buildPrimaryButton(
            title: 'Sign In to Kaka Food',
            icon: Icons.login_rounded,
            onPressed: _handleSignIn,
          ),

          const SizedBox(height: 12),

          // 1-Tap Quick Demo Login Button
          _buildDemoLoginButton(isDark),
        ],
      ),
    );
  }

  Widget _buildSignUpForm(bool isDark) {
    return Form(
      key: _signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Name Field
          _buildInputLabel('Full Name', isDark),
          TextFormField(
            controller: _signUpNameController,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration(
              hint: 'e.g. Alex Vance',
              icon: Icons.person_outline_rounded,
              isDark: isDark,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter your full name';
              return null;
            },
          ),

          const SizedBox(height: 14),

          // Email Field
          _buildInputLabel('Email Address', isDark),
          TextFormField(
            controller: _signUpEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration(
              hint: 'alex@example.com',
              icon: Icons.alternate_email_rounded,
              isDark: isDark,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter your email';
              if (!value.contains('@')) return 'Enter a valid email address';
              return null;
            },
          ),

          const SizedBox(height: 14),

          // Phone Number Field with Indian Country Flag & +91 prefix
          _buildInputLabel('Mobile Number', isDark),
          TextFormField(
            controller: _signUpPhoneController,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration(
              hint: '98765 43210',
              icon: Icons.phone_android_rounded,
              prefixBadge: '🇮🇳 +91',
              isDark: isDark,
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty && value.trim().length < 10) {
                return 'Enter a 10-digit mobile number';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          // Password Field
          _buildInputLabel('Password', isDark),
          TextFormField(
            controller: _signUpPasswordController,
            obscureText: _signUpObscurePassword,
            decoration: _inputDecoration(
              hint: 'Min. 6 characters',
              icon: Icons.lock_outline_rounded,
              isDark: isDark,
              suffixIcon: IconButton(
                icon: Icon(
                  _signUpObscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 20,
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                ),
                onPressed: () => setState(() => _signUpObscurePassword = !_signUpObscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password is required';
              if (value.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),

          const SizedBox(height: 12),

          // Terms and Privacy Checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _agreedToTerms,
                  activeColor: const Color(0xFFFF4B26),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  onChanged: (val) => setState(() => _agreedToTerms = val ?? true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'I agree to the Kaka Food Terms of Service, Privacy Policy & Cookie Policy.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Create Account Button
          _buildPrimaryButton(
            title: 'Create Account & Get ₹150',
            icon: Icons.card_giftcard_rounded,
            onPressed: _handleSignUp,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ListenableBuilder(
      listenable: widget.authViewModel,
      builder: (context, _) {
        final isLoading = widget.authViewModel.isLoading;
        return Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF4B26), Color(0xFFFF7A45)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF4B26).withAlpha(100),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDemoLoginButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: _handleQuickDemoLogin,
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
          backgroundColor: isDark ? const Color(0xFF1E293B).withAlpha(120) : Colors.white,
          side: BorderSide(
            color: isDark ? Colors.white.withAlpha(30) : const Color(0xFFCBD5E1),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flash_on_rounded, color: Color(0xFFFFB300), size: 18),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                '1-Tap Demo Login (Chef Alex)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialAndGuestRow(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'or continue with',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(child: Divider(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialCircle(
              icon: Icons.g_mobiledata_rounded,
              label: 'Google',
              color: const Color(0xFFEA4335),
              onTap: _handleQuickDemoLogin,
              isDark: isDark,
            ),
            const SizedBox(width: 16),
            _buildSocialCircle(
              icon: Icons.apple_rounded,
              label: 'Apple',
              color: isDark ? Colors.white : Colors.black,
              onTap: _handleQuickDemoLogin,
              isDark: isDark,
            ),
            const SizedBox(width: 16),
            _buildSocialCircle(
              icon: Icons.sms_outlined,
              label: 'OTP',
              color: const Color(0xFF10B981),
              onTap: _handleQuickDemoLogin,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialCircle({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 60,
        height: 50,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withAlpha(20) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 30 : 10),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }

  Widget _buildInputLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white.withAlpha(220) : const Color(0xFF334155),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required bool isDark,
    String? prefixBadge,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 13.5,
        color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
      ),
      prefixIcon: prefixBadge != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 14, right: 6),
                  child: Text(
                    prefixBadge,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
                Container(
                  width: 1,
                  height: 20,
                  color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                ),
                const SizedBox(width: 8),
              ],
            )
          : Icon(icon, size: 20, color: isDark ? Colors.white54 : const Color(0xFF64748B)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? Colors.white.withAlpha(20) : const Color(0xFFE2E8F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? Colors.white.withAlpha(20) : const Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF4B26), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }
}
