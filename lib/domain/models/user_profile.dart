class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String avatarUrl;
  final String membershipTier;
  final int totalOrders;
  final int savedFavoritesCount;
  final int loyaltyPoints;
  final double walletBalance;
  final String address;
  final String preferredPayment;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.membershipTier,
    required this.totalOrders,
    required this.savedFavoritesCount,
    required this.loyaltyPoints,
    required this.walletBalance,
    required this.address,
    required this.preferredPayment,
  });

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? membershipTier,
    int? totalOrders,
    int? savedFavoritesCount,
    int? loyaltyPoints,
    double? walletBalance,
    String? address,
    String? preferredPayment,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      membershipTier: membershipTier ?? this.membershipTier,
      totalOrders: totalOrders ?? this.totalOrders,
      savedFavoritesCount: savedFavoritesCount ?? this.savedFavoritesCount,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      walletBalance: walletBalance ?? this.walletBalance,
      address: address ?? this.address,
      preferredPayment: preferredPayment ?? this.preferredPayment,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Gourmet User',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      membershipTier: json['membershipTier'] as String? ?? 'Welcome Foodie ⭐',
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      savedFavoritesCount: (json['savedFavoritesCount'] as num?)?.toInt() ?? 0,
      loyaltyPoints: (json['loyaltyPoints'] as num?)?.toInt() ?? 0,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String? ?? '',
      preferredPayment: json['preferredPayment'] as String? ?? 'UPI / Google Pay',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'membershipTier': membershipTier,
      'totalOrders': totalOrders,
      'savedFavoritesCount': savedFavoritesCount,
      'loyaltyPoints': loyaltyPoints,
      'walletBalance': walletBalance,
      'address': address,
      'preferredPayment': preferredPayment,
    };
  }
}
