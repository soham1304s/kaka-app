import 'package:flutter/material.dart';
import '../view_models/auth_view_model.dart';
import 'app_network_image.dart';

class AuthCard extends StatelessWidget {
  final AuthViewModel authViewModel;
  final VoidCallback onOpenAuth;
  final VoidCallback onOpenProfile;

  const AuthCard({
    super.key,
    required this.authViewModel,
    required this.onOpenAuth,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = authViewModel.currentUser;
    final isAuthenticated = authViewModel.isAuthenticated && user != null;

    if (!isAuthenticated) {
      // Guest / Not logged in banner on Dashboard
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF2E1A16),
                    const Color(0xFF1E222A),
                  ]
                : [
                    const Color(0xFFFFF1EE),
                    const Color(0xFFFFFAF8),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: theme.colorScheme.primary.withAlpha(50),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withAlpha(20),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.card_giftcard_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Unlock 20% Off Your First Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sign in or create an account to earn reward points & track live deliveries.',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onOpenAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Sign In / Register',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {
                    authViewModel.quickDemoLogin();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF1F2937),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                            SizedBox(width: 10),
                            Text('Signed in with Demo Account!'),
                          ],
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    side: BorderSide(
                      color: isDark ? Colors.white30 : const Color(0xFFD1D5DB),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Demo Login',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : const Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Authenticated user summary card on Dashboard
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E222A) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF2B323D) : const Color(0xFFEEF0F4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              AppNetworkImage(
                imageUrl: user.avatarUrl,
                width: 46,
                height: 46,
                borderRadius: BorderRadius.circular(24),
                fit: BoxFit.cover,
                fallbackWidget: CircleAvatar(
                  radius: 23,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0] : 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Hi, ${user.fullName.split(' ').first}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('👋', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.membershipTier,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onOpenProfile,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('My Profile', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252B35) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, size: 16, color: Color(0xFF10B981)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Wallet: ₹${user.walletBalance.toStringAsFixed(2)}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 14, width: 1, color: isDark ? Colors.white24 : Colors.black12),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stars_rounded, size: 16, color: Color(0xFFFFB300)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Points: ${user.loyaltyPoints} pts',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
