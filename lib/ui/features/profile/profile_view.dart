import 'package:flutter/material.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/cart_view_model.dart';
import '../../view_models/food_view_model.dart';
import '../../view_models/theme_view_model.dart';
import '../auth/auth_page.dart';
import 'package:kaka_app/ui/widgets/app_network_image.dart';
import 'edit_profile_dialog.dart';

class ProfileView extends StatelessWidget {
  final AuthViewModel authViewModel;
  final ThemeViewModel themeViewModel;
  final FoodViewModel foodViewModel;
  final CartViewModel? cartViewModel;

  const ProfileView({
    super.key,
    required this.authViewModel,
    required this.themeViewModel,
    required this.foodViewModel,
    this.cartViewModel,
  });

  void _openAuthPage(BuildContext context, {bool isSignUp = false}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, anim, secAnim) => AuthPage(
          authViewModel: authViewModel,
          foodViewModel: foodViewModel,
          cartViewModel: cartViewModel ?? CartViewModel(),
          themeViewModel: themeViewModel,
          initialIsSignUp: isSignUp,
        ),
        transitionsBuilder: (context, anim, secAnim, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of your Kaka account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              authViewModel.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: Listenable.merge([authViewModel, themeViewModel]),
      builder: (context, _) {
        final user = authViewModel.currentUser;
        final isAuthenticated = authViewModel.isAuthenticated && user != null;

        if (!isAuthenticated) {
          // Logged out state in Profile
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
            ),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_pin_rounded,
                        size: 50,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Welcome to Kaka Food',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to see your profile details, track active orders, and redeem your VIP rewards points.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _openAuthPage(context),
                        child: const Text('Sign In or Register'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => authViewModel.quickDemoLogin(),
                        child: const Text('Quick Demo Login (Alex Vance)'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_note_rounded),
                tooltip: 'Edit Profile',
                onPressed: () => EditProfileDialog.show(context, authViewModel: authViewModel),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info Header Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E222A) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2C323E) : const Color(0xFFEFF0F3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          AppNetworkImage(
                            imageUrl: user.avatarUrl,
                            width: 70,
                            height: 70,
                            borderRadius: BorderRadius.circular(35),
                            fit: BoxFit.cover,
                            fallbackWidget: CircleAvatar(
                              radius: 35,
                              backgroundColor: theme.colorScheme.primary,
                              child: Text(
                                user.fullName.isNotEmpty ? user.fullName[0] : 'U',
                                style: const TextStyle(color: Colors.white, fontSize: 24),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? const Color(0xFF1E222A) : Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                user.membershipTier,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Stats Metrics Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Orders Placed',
                        value: '${user.totalOrders}',
                        icon: Icons.receipt_long_rounded,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Favorites',
                        value: '${foodViewModel.favoriteIds.length}',
                        icon: Icons.favorite_rounded,
                        color: Colors.pink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Loyalty Points',
                        value: '${user.loyaltyPoints} pts',
                        icon: Icons.stars_rounded,
                        color: Colors.amber.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Wallet Balance',
                        value: '₹${user.walletBalance.toStringAsFixed(2)}',
                        icon: Icons.account_balance_wallet_rounded,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Active Live Delivery Tracker Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1E2822), const Color(0xFF181C22)]
                          : [const Color(0xFFE8F5E9), const Color(0xFFF1F8E9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.two_wheeler_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live Delivery • On the way 🛵',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Smokey BBQ Bacon Burger',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Estimated arrival: 12 mins',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section: Personal Details & Contact
                const Text(
                  'Account Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                _buildInfoTile(
                  context,
                  icon: Icons.phone_outlined,
                  title: 'Phone Number',
                  value: user.phoneNumber,
                  onTap: () => EditProfileDialog.show(context, authViewModel: authViewModel),
                ),
                _buildInfoTile(
                  context,
                  icon: Icons.location_on_outlined,
                  title: 'Default Delivery Address',
                  value: user.address,
                  onTap: () => EditProfileDialog.show(context, authViewModel: authViewModel),
                ),
                _buildInfoTile(
                  context,
                  icon: Icons.credit_card_outlined,
                  title: 'Payment Method',
                  value: user.preferredPayment,
                  onTap: () {},
                ),
                const SizedBox(height: 24),

                // Section: Preferences
                const Text(
                  'App Preferences',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2C323E) : const Color(0xFFEFF0F3),
                    ),
                  ),
                  child: Material(
                    color: isDark ? const Color(0xFF1E222A) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: themeViewModel.isDarkMode,
                          onChanged: (val) => themeViewModel.toggleTheme(),
                          title: const Text('Dark Mode Theme', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: const Text('Switch between light and dark interface', style: TextStyle(fontSize: 12)),
                          secondary: Icon(
                            themeViewModel.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
                        SwitchListTile(
                          value: true,
                          onChanged: (val) {},
                          title: const Text('Push Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: const Text('Receive order tracking and exclusive discounts', style: TextStyle(fontSize: 12)),
                          secondary: Icon(Icons.notifications_active_outlined, color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Support & Logout
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout_rounded, color: Colors.red),
                    label: const Text('Log Out of Account', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E222A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2C323E) : const Color(0xFFEFF0F3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2C323E) : const Color(0xFFEFF0F3),
        ),
      ),
      child: Material(
        color: isDark ? const Color(0xFF1E222A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: theme.colorScheme.primary, size: 22),
          title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          subtitle: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        ),
      ),
    );
  }
}
