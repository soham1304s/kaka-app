import 'package:flutter/material.dart';
import '../../view_models/auth_view_model.dart';

class AuthView extends StatefulWidget {
  final AuthViewModel authViewModel;

  const AuthView({
    super.key,
    required this.authViewModel,
  });

  static void show(BuildContext context, {required AuthViewModel authViewModel}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AuthView(authViewModel: authViewModel),
    );
  }

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  bool _isSignUp = false;
  bool _obscurePassword = true;

  // Controllers
  final _emailController = TextEditingController(text: 'alex.vance@example.com');
  final _passwordController = TextEditingController(text: 'secret123');
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final authVM = widget.authViewModel;
    bool success = false;

    if (_isSignUp) {
      success = await authVM.signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      success = await authVM.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (mounted && success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1F2937),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
              const SizedBox(width: 10),
              Text(_isSignUp ? 'Account created successfully! Welcome to Kaka!' : 'Welcome back! Logged in successfully.'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Password'),
        content: const Text(
          'Enter your email address and we will send a password reset link to your inbox.',
          style: TextStyle(fontSize: 14),
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
                  backgroundColor: const Color(0xFF1F2937),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: const Text('Password reset instructions sent to your email!'),
                ),
              );
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181B20) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Brand
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withAlpha(25),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '🍽️',
                                style: const TextStyle(fontSize: 30),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'KAKA FOOD',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isSignUp
                                ? 'Create an account to order gourmet delicacies'
                                : 'Sign in to access your profile & rewards',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Toggle Tabs: Sign In / Sign Up
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF22262F) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _isSignUp = false),
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !_isSignUp
                                      ? (isDark ? const Color(0xFF2E3440) : Colors.white)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: !_isSignUp
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(15),
                                            blurRadius: 6,
                                          )
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  'Sign In',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: !_isSignUp ? FontWeight.w700 : FontWeight.w500,
                                    color: !_isSignUp
                                        ? theme.colorScheme.primary
                                        : (isDark ? Colors.white60 : Colors.black54),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _isSignUp = true),
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _isSignUp
                                      ? (isDark ? const Color(0xFF2E3440) : Colors.white)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _isSignUp
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(15),
                                            blurRadius: 6,
                                          )
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  'Create Account',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: _isSignUp ? FontWeight.w700 : FontWeight.w500,
                                    color: _isSignUp
                                        ? theme.colorScheme.primary
                                        : (isDark ? Colors.white60 : Colors.black54),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Error Message
                    ListenableBuilder(
                      listenable: widget.authViewModel,
                      builder: (context, _) {
                        final err = widget.authViewModel.errorMessage;
                        if (err == null) return const SizedBox.shrink();
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withAlpha(60)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  err,
                                  style: const TextStyle(color: Colors.red, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Sign Up: Name Field
                    if (_isSignUp) ...[
                      const Text(
                        'Full Name',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Alex Vance',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Phone Number',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: '+1 (555) 000-0000',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Email Field
                    const Text(
                      'Email Address',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'alex.vance@example.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Password Field
                    const Text(
                      'Password',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),

                    if (!_isSignUp) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ] else
                      const SizedBox(height: 18),

                    // Submit Button
                    ListenableBuilder(
                      listenable: widget.authViewModel,
                      builder: (context, _) {
                        final isLoading = widget.authViewModel.isLoading;
                        return ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isSignUp ? 'Create My Account' : 'Sign In to Kaka',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // Fast Demo Access
                    OutlinedButton.icon(
                      onPressed: () {
                        widget.authViewModel.quickDemoLogin();
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF1F2937),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            content: const Text('Signed in as Demo User Alex!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.flash_on_rounded, size: 18),
                      label: const Text('Quick Demo Login (1-Tap)'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Social Options
                    Row(
                      children: [
                        Expanded(child: Divider(color: isDark ? Colors.white12 : Colors.black12)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR CONTINUE WITH',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: isDark ? Colors.white12 : Colors.black12)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              widget.authViewModel.quickDemoLogin();
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.g_mobiledata_rounded, size: 24, color: Colors.red),
                            label: const Text('Google', style: TextStyle(color: null)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: isDark ? Colors.white24 : const Color(0xFFE5E7EB)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              widget.authViewModel.quickDemoLogin();
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.apple_rounded, size: 20),
                            label: const Text('Apple', style: TextStyle(color: null)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: isDark ? Colors.white24 : const Color(0xFFE5E7EB)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
